import SwiftUI

/// View for wallet discovery functionality.
///
/// This view displays:
/// - A list of discovered wallets
/// - A refresh/discover button
/// - Discovery status
struct WalletDiscoveryView: View {
    @StateObject private var viewModel: WalletDiscoveryViewModel

    init(viewModel: WalletDiscoveryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Discovery status header
                discoveryStatusHeader

                // Wallet list
                walletList
            }
            .navigationTitle("Wallet Discovery")
            .task {
                await viewModel.loadWallets()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.startDiscovery()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(viewModel.isDiscovering ? 360 : 0))
                            .animation(
                                viewModel.isDiscovering ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                                value: viewModel.isDiscovering
                            )
                    }
                    .disabled(viewModel.isDiscovering)
                }
            }
        }
    }

    // MARK: - View Components

    private var discoveryStatusHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Total Wallets")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.totalWalletCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }

            if viewModel.isDiscovering {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Discovering wallets...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
        .padding(.top)
    }

    private var walletList: some View {
        List {
            if viewModel.wallets.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Wallets Discovered",
                        systemImage: "wallet.bifold",
                        description: Text("Pull to refresh or tap the refresh button to start discovering wallets.")
                    )
                }
            } else {
                Section(header: Text("Discovered Wallets")) {
                    ForEach(viewModel.wallets, id: \.walletAddress) { wallet in
                        WalletRow(wallet: wallet)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Wallet Row

/// Row view for displaying a single wallet.
struct WalletRow: View {
    let wallet: WalletEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Wallet address (truncated)
            Text(truncateAddress(wallet.walletAddress))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)

            // Category badge
            if let category = wallet.category {
                Text(category)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(categoryColor(for: category))
                    .foregroundStyle(.white)
                    .cornerRadius(4)
            }

            // Metadata
            HStack {
                Text("First seen: \(formatDate(wallet.firstSeen))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Updated: \(formatDate(wallet.lastSeen))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helper Methods

    private func truncateAddress(_ address: String) -> String {
        guard address.count > 12 else { return address }
        let prefix = address.prefix(6)
        let suffix = address.suffix(4)
        return "\(prefix)...\(suffix)"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func categoryColor(for category: String) -> Color {
        switch category {
        case "0-1 BTC":
            .gray
        case "1-2 BTC":
            .blue
        case "2-3 BTC":
            .green
        case "3-5 BTC":
            .orange
        case "5-8 BTC":
            .purple
        case "8-13 BTC":
            .pink
        case "13-21 BTC":
            .red
        case "21+ BTC":
            .yellow
        default:
            .gray
        }
    }
}

// MARK: - Preview

#Preview {
    // Preview will work once ViewModel is properly initialized
    Text("WalletDiscoveryView Preview")
}
