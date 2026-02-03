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
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 24) {
                        Image(systemName: "globe")
                            .font(Font.custom("Roboto-Regular", size: 64))
                            .foregroundStyle(Color("dsPrimary"))
                        
                        Text("DexLens")
                            .textStyle(.title1, color: .textPrimary)
                        
                        Text("Design System Preview")
                            .textStyle(.subheadline, color: .textSecondary)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Examples")
                            .textStyle(.title2, color: .textPrimary)
                        
                        VStack(spacing: 12) {
                            primaryButton
                            successCard
                            errorCard
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Welcome")
            .background(Color("dsSurface"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Colors") {
                        ColorPreviewView()
                    }
                }
            }
        }
    }
    
    private var primaryButton: some View {
        Button(action: {}) {
            Text("Connect Wallet")
                .frame(maxWidth: .infinity)
                .padding()
                .cornerRadius(12)
        }
        .textStyle(.bodyBold, color: .white)
        .padding(.horizontal)
        .background(LinearGradient.primaryGradient)
        .cornerRadius(12)
    }
    
    private var successCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("+12.5%")
                    .textStyle(.title2, color: .success)
                Text("Portfolio Gains")
                    .textStyle(.caption1, color: .textSecondary)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.title2)
                .foregroundStyle(Color("dsSuccess"))
        }
        .padding()
        .background(Color.surfaceSecondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }
    
    private var errorCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("-3.2%")
                    .textStyle(.title2, color: .error)
                Text("Daily Loss")
                    .textStyle(.caption1, color: .textSecondary)
            }
            Spacer()
            Image(systemName: "arrow.down.right")
                .font(.title2)
                .foregroundStyle(Color.error)
        }
        .padding()
        .background(Color("dsSurfaceSecondary"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
