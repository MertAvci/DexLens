//
//  DexLensApp.swift
//  DexLens
//
//  Created by Mert Avci on 2026-02-03.
//

import SwiftUI

@main
struct DexLensApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isInitialized = false

    init() {
        DIContainer.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
        .backgroundTask(.appRefresh("com.dexlens.walletdiscovery")) {
            // Background refresh task - runs every 15 minutes
            await performWalletDiscovery()
        }
    }

    // MARK: - Scene Phase Handling

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            Task {
                await performWalletDiscovery()
            }
        case .background:
            // App entered background - backgroundTask handles scheduling
            break
        default:
            break
        }
    }

    // MARK: - Wallet Discovery

    private func performWalletDiscovery() async {
        let discoveryService: WalletDiscoveryServiceProtocol = DIContainer.shared.resolve(
            WalletDiscoveryServiceProtocol.self
        )
        _ = await discoveryService.discoverWalletsCombined()
    }
}
