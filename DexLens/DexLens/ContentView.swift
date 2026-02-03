//
//  ContentView.swift
//  DexLens
//
//  Created by Mert Avci on 2026-02-03.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("DexLens")
                    .font(Typography.title1)
                
                Text("Design System Preview")
                    .font(Typography.subheadline)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Welcome")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Font Preview") {
                        FontPreviewView()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
