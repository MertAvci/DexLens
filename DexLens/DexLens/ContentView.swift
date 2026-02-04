//
//  ContentView.swift
//  DexLens
//
//  Created by Mert Avci on 2026-02-03.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var perpetualViewModel: PerpetualViewModel
    @StateObject private var walletDiscoveryViewModel: WalletDiscoveryViewModel

    @State private var showDiscoveryBanner: Bool = false
    @State private var discoveredWalletCount: Int = 0

    init(
        homeService: HomeServiceProtocol = DIContainer.shared.resolve(HomeServiceProtocol.self),
        perpetualService: PerpetualServiceProtocol = DIContainer.shared.resolve(PerpetualServiceProtocol.self),
        walletDiscoveryService: WalletDiscoveryServiceProtocol = DIContainer.shared.resolve(
            WalletDiscoveryServiceProtocol.self
        ),
        walletRepository: WalletRepository = DIContainer.shared.resolve(WalletRepository.self)
    ) {
        _homeViewModel = StateObject(
            wrappedValue: HomeViewModel(service: homeService)
        )

        _perpetualViewModel = StateObject(
            wrappedValue: PerpetualViewModel(service: perpetualService)
        )

        _walletDiscoveryViewModel = StateObject(
            wrappedValue: WalletDiscoveryViewModel(
                discoveryService: walletDiscoveryService,
                repository: walletRepository
            )
        )
    }

    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label("Coins", systemImage: "bitcoinsign.circle.fill")
                }

            PerpetualView(viewModel: perpetualViewModel)
                .tabItem {
                    Label("Positions", systemImage: "chart.bar.fill")
                }

            WalletDiscoveryView(viewModel: walletDiscoveryViewModel)
                .tabItem {
                    Label("Wallets", systemImage: "wallet.bifold")
                }
        }
        .notificationBanner(
            isPresented: $showDiscoveryBanner,
            type: .success,
            title: "Wallets Discovered",
            message: "\(discoveredWalletCount) new wallet\(discoveredWalletCount == 1 ? "" : "s") found",
            duration: 5
        )
        .onAppear {
            setupNotificationObserver()
        }
        .onReceive(walletDiscoveryViewModel.$showDiscoveryBanner) { show in
            showDiscoveryBanner = show
            if show {
                discoveredWalletCount = walletDiscoveryViewModel.lastDiscoveredCount
            }
        }
    }

    // MARK: - Private Methods

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: .walletsDiscovered,
            object: nil,
            queue: .main
        ) { notification in
            guard let count = notification.object as? Int else { return }

            withAnimation {
                discoveredWalletCount = count
                showDiscoveryBanner = true
            }
        }
    }
}

#Preview {
    ContentView()
}
