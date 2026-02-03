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
                            .foregroundStyle(Color.primary)
                        
                        Text("DexLens")
                            .font(Font.custom("Roboto-Bold", size: 32))
                            .foregroundStyle(Color.textPrimary)
                        
                        Text("Design System Preview")
                            .font(Font.custom("Roboto-Regular", size: 17))
                            .foregroundStyle(Color.textSecondary)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Examples")
                            .font(Font.custom("Roboto-Medium", size: 22))
                            .foregroundStyle(Color.textPrimary)
                        
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
            .background(Color.surface)
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
                .font(Font.custom("Roboto-Medium", size: 17))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient.primaryGradient)
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var successCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("+12.5%")
                    .font(Font.custom("Roboto-Bold", size: 22))
                    .foregroundStyle(Color.success)
                Text("Portfolio Gains")
                    .font(Font.custom("Roboto-Regular", size: 15))
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.title2)
                .foregroundStyle(Color.success)
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
                    .font(Font.custom("Roboto-Bold", size: 22))
                    .foregroundStyle(Color.error)
                Text("Daily Loss")
                    .font(Font.custom("Roboto-Regular", size: 15))
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer()
            Image(systemName: "arrow.down.right")
                .font(.title2)
                .foregroundStyle(Color.error)
        }
        .padding()
        .background(Color.surfaceSecondary)
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
