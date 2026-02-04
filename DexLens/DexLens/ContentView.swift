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

    init(
        homeService: HomeServiceProtocol = DIContainer.shared.resolve(HomeServiceProtocol.self),
        perpetualService: PerpetualServiceProtocol = DIContainer.shared.resolve(PerpetualServiceProtocol.self)
    ) {
        _homeViewModel = StateObject(
            wrappedValue: HomeViewModel(service: homeService)
        )

        _perpetualViewModel = StateObject(
            wrappedValue: PerpetualViewModel(service: perpetualService)
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
        }
    }
}

#Preview {
    ContentView()
}
