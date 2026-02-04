//
//  ContentView.swift
//  DexLens
//
//  Created by Mert Avci on 2026-02-03.
//

import SwiftUI

struct ContentView: View {
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel = DIContainer.shared.resolve(HomeViewModel.self)!) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HomeView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
