import SwiftUI

struct PerpetualView: View {
    @StateObject private var viewModel: PerpetualViewModel

    init(viewModel: PerpetualViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading, viewModel.positionBuckets.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                } else {
                    VStack(spacing: 16) {
                        // Header
                        headerView

                        // Position Distribution
                        positionDistributionView
                    }
                    .padding()
                }
            }
            .navigationTitle("Position Distribution")
            .navigationBarTitleDisplayMode(.large)
            .task {
                if viewModel.positionBuckets.isEmpty {
                    await viewModel.fetchPositionDistribution()
                }
            }
            .refreshable {
                await viewModel.fetchPositionDistribution()
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

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("BTC Position Distribution")
                .textStyle(.title2, color: .textPrimary)

            Text("Hyperliquid positions grouped by size")
                .textStyle(.body, color: .textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var positionDistributionView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.positionBuckets) { bucket in
                PositionBucketRow(bucket: bucket)
            }
        }
    }
}
