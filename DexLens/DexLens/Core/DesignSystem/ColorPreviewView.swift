import SwiftUI

struct ColorPreviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                solidColorsSection
                Divider()
                gradientsSection
                Divider()
                uiComponentsSection
            }
            .padding()
        }
        .navigationTitle("Color Preview")
        .background(Color.surface)
    }

    private var solidColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Solid Colors", subtitle: "Semantic color palette")

            VStack(spacing: 8) {
                ColorSwatch(name: "primary", color: Color.primary)
                ColorSwatch(name: "primaryMuted", color: Color.primaryMuted)
                ColorSwatch(name: "success", color: Color.success)
                ColorSwatch(name: "error", color: Color.error)
                ColorSwatch(name: "warning", color: Color.warning)
                ColorSwatch(name: "surface", color: Color.surface)
                ColorSwatch(name: "surfaceSecondary", color: Color.surfaceSecondary)
                ColorSwatch(name: "textPrimary", color: Color.textPrimary)
                ColorSwatch(name: "textSecondary", color: Color.textSecondary)
                ColorSwatch(name: "border", color: Color.border)
            }
        }
    }

    private var gradientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Gradients", subtitle: "Predefined gradient styles")

            VStack(spacing: 12) {
                GradientPreview(name: "Primary Gradient", gradient: LinearGradient.primaryGradient)
                GradientPreview(name: "Success Gradient", gradient: LinearGradient.successGradient)
                GradientPreview(name: "Deep Ocean Gradient", gradient: LinearGradient.deepOceanGradient)
            }
        }
    }

    private var uiComponentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "UI Components", subtitle: "Real-world usage examples")

            VStack(spacing: 12) {
                successCard
                errorCard
                primaryButton
                textExample
            }
        }
    }

    private var successCard: some View {
        HStack {
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
                .foregroundStyle(Color.success)
                .font(.title2)
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }

    private var errorCard: some View {
        HStack {
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
                .foregroundStyle(Color.error)
                .font(.title2)
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }

    private var primaryButton: some View {
        Button(action: {}) {
            Text("Connect Wallet")
                .font(Font.custom("Roboto-Bold", size: 17))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient.primaryGradient)
                .cornerRadius(12)
        }
    }

    private var textExample: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Typography Examples")
                .font(Font.custom("Roboto-Medium", size: 20))
                .foregroundStyle(Color.textPrimary)

            Text("This is primary text in Roboto.")
                .font(Font.custom("Roboto-Regular", size: 17))
                .foregroundStyle(Color.textPrimary)

            Text("This is secondary text for captions.")
                .font(Font.custom("Roboto-Regular", size: 15))
                .foregroundStyle(Color.textSecondary)

            Text("Success color")
                .font(Font.custom("Roboto-Regular", size: 17))
                .foregroundStyle(Color.success)

            Text("Error color")
                .font(Font.custom("Roboto-Regular", size: 17))
                .foregroundStyle(Color.error)
        }
        .padding()
        .background(Color.surfaceSecondary)
        .cornerRadius(12)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Font.custom("Roboto-Bold", size: 22))
            Text(subtitle)
                .font(Font.custom("Roboto-Regular", size: 15))
                .foregroundStyle(Color.textSecondary)
        }
    }
}

struct ColorSwatch: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 48, height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.border, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(Font.custom("Roboto-Regular", size: 17))
                    .foregroundStyle(Color.textPrimary)
                Text("Sample text color")
                    .font(Font.custom("Roboto-Regular", size: 12))
                    .foregroundStyle(color)
            }
            Spacer()
        }
    }
}

struct GradientPreview: View {
    let name: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(Font.custom("Roboto-Medium", size: 15))
                .foregroundStyle(Color.textPrimary)

            RoundedRectangle(cornerRadius: 12)
                .fill(gradient)
                .frame(height: 80)
                .overlay(
                    Text("Gradient")
                        .font(Font.custom("Roboto-Bold", size: 17))
                        .foregroundStyle(.white)
                )
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ColorPreviewView()
    }
}
