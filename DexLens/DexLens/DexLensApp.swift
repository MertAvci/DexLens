//
//  DexLensApp.swift
//  DexLens
//
//  Created by Mert Avci on 2026-02-03.
//

import BackgroundTasks
import SwiftUI

@main
struct DexLensApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        DIContainer.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - App Delegate

/// AppDelegate for handling background tasks and lifecycle events.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        registerBackgroundTasks()
        return true
    }

    func applicationDidEnterBackground(_: UIApplication) {
        scheduleWalletDiscoveryBackgroundTask()
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Start discovery when app becomes active
        Task {
            let discoveryService: WalletDiscoveryServiceProtocol = DIContainer.shared.resolve(
                WalletDiscoveryServiceProtocol.self
            )
            _ = await discoveryService.discoverWallets(fromCoins: [])
        }
    }

    // MARK: - Background Tasks

    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.dexlens.walletdiscovery",
            using: nil
        ) { [weak self] task in
            self?.handleWalletDiscoveryBackgroundTask(task)
        }
    }

    private func scheduleWalletDiscoveryBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.dexlens.walletdiscovery")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule wallet discovery: \(error)")
        }
    }

    private func handleWalletDiscoveryBackgroundTask(_ task: BGTask) {
        scheduleWalletDiscoveryBackgroundTask() // Schedule next task

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let discoveryOperation = BlockOperation { [weak self] in
            guard let self else { return }

            let semaphore = DispatchSemaphore(value: 0)

            Task {
                let discoveryService: WalletDiscoveryServiceProtocol = DIContainer.shared.resolve(
                    WalletDiscoveryServiceProtocol.self
                )
                _ = await discoveryService.discoverWallets(fromCoins: [])
                semaphore.signal()
            }

            semaphore.wait()
        }

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        discoveryOperation.completionBlock = {
            task.setTaskCompleted(success: !discoveryOperation.isCancelled)
        }

        queue.addOperations([discoveryOperation], waitUntilFinished: false)
    }
}
