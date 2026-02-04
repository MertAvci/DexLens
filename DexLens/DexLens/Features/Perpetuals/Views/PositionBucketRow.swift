import SwiftUI

struct PositionBucketRow: View {
    let bucket: PositionSizeBucket

    var body: some View {
        VStack(spacing: 12) {
            // Header with tier name
            HStack {
                Text(bucket.tier)
                    .textStyle(.headline, color: .textPrimary)
                Spacer()
                Text("\(bucket.totalAddresses) addresses")
                    .textStyle(.subheadline, color: .textSecondary)
            }

            // Long/Short distribution bar
            distributionBarView

            // Stats
            statsView
        }
        .padding()
        .background(Color.surfaceSecondary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }

    private var distributionBarView: some View {
        HStack(spacing: 8) {
            // Long bar
            VStack(alignment: .leading, spacing: 4) {
                Text("Long")
                    .textStyle(.caption1, color: .textSecondary)

                GeometryReader { geometry in
                    let width = bucket.totalCount > 0 ?
                        (geometry.size.width * CGFloat(bucket.longPercentage) / 100.0) : 0

                    Rectangle()
                        .fill(Color.success)
                        .frame(width: width, height: 24)
                        .cornerRadius(4)
                }
                .frame(height: 24)

                Text("\(bucket.longCount)")
                    .textStyle(.caption2, color: .textSecondary)
            }

            // Short bar
            VStack(alignment: .trailing, spacing: 4) {
                Text("Short")
                    .textStyle(.caption1, color: .textSecondary)

                GeometryReader { geometry in
                    let width = bucket.totalCount > 0 ?
                        (geometry.size.width * CGFloat(bucket.shortPercentage) / 100.0) : 0

                    Rectangle()
                        .fill(Color.error)
                        .frame(width: width, height: 24)
                        .cornerRadius(4)
                }
                .frame(height: 24)

                Text("\(bucket.shortCount)")
                    .textStyle(.caption2, color: .textSecondary)
            }
        }
        .frame(height: 48)
    }

    private var statsView: some View {
        HStack(spacing: 16) {
            // Long value
            VStack(alignment: .leading, spacing: 2) {
                Text("Long Value")
                    .textStyle(.caption1, color: .textSecondary)
                Text(bucket.formattedLongValue)
                    .textStyle(.subheadlineBold, color: .success)
            }

            // Short value
            VStack(alignment: .trailing, spacing: 2) {
                Text("Short Value")
                    .textStyle(.caption1, color: .textSecondary)
                Text(bucket.formattedShortValue)
                    .textStyle(.subheadlineBold, color: .error)
            }

            Spacer()

            // Total value
            VStack(alignment: .trailing, spacing: 2) {
                Text("Total Value")
                    .textStyle(.caption1, color: .textSecondary)
                Text(bucket.formattedTotalValue)
                    .textStyle(.subheadlineBold, color: .textPrimary)
            }
        }
    }
}
