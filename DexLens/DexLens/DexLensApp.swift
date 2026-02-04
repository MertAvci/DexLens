//
//  DexLensApp.swift
//  DexLens
//
//  Created by Mert Avci on 2026-02-03.
//

import SwiftUI

@main
struct DexLensApp: App {
    init() {
        DIContainer.shared.register()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
