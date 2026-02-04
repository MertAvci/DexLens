import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.coins) { coin in
                                CoinRow(coin: coin)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Top 20 Coins")
            .task {
                if viewModel.coins.isEmpty {
                    await viewModel.fetchTopCoins()
                }
            }
            .refreshable {
                await viewModel.fetchTopCoins()
            }
            .alert(isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? ""),
                    dismissButton: .default(Text("Dismiss"))
                )
            }
        }
    }
}

struct CoinRow: View {
    let coin: Coin

    var body: some View {
        HStack(spacing: 12) {
            coinImage

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(coin.name)
                        .textStyle(.headline, color: .textPrimary)
                    Text(coin.symbol.uppercased())
                        .textStyle(.caption1, color: .textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.border.opacity(0.3))
                        .cornerRadius(4)
                }
                Text(coin.formattedPrice)
                    .textStyle(.body, color: .textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(coin.priceChange24h >= 0 ? "+" : "")\(String(format: "%.2f", coin.priceChange24h))%")
                    .textStyle(.subheadlineBold, color: coin.priceChange24h >= 0 ? .success : .error)
                Text("#\(coin.rank)")
                    .textStyle(.caption2, color: .textSecondary)
            }
        }
        .padding()
        .background(Color.surfaceSecondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }

    private var coinImage: some View {
        Group {
            if let imageURL = coin.imageURL {
                AsyncImage(url: imageURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
            } else if coin.isImageLoading {
                ProgressView()
            } else {
                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 40, height: 40)
    }
}
