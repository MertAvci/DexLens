import SwiftUI

struct FontPreviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                fontWeightsSection
                typographySection
            }
            .padding()
        }
        .navigationTitle("Font Preview")
    }
    
    private var fontWeightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Font Weights", subtitle: "Roboto 17pt")
            
            FontRow(weight: .thin, label: "Thin (100)")
            FontRow(weight: .light, label: "Light (300)")
            FontRow(weight: .regular, label: "Regular (400)")
            FontRow(weight: .medium, label: "Medium (500)")
            FontRow(weight: .bold, label: "Bold (700)")
            FontRow(weight: .black, label: "Black (900)")
        }
    }
    
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Typography Scale", subtitle: "System Typography Styles")
            
            TypographyRow(font: Typography.largeTitle, label: "Large Title", size: "34pt")
            TypographyRow(font: Typography.title1, label: "Title 1", size: "28pt")
            TypographyRow(font: Typography.title2, label: "Title 2", size: "22pt")
            TypographyRow(font: Typography.title3, label: "Title 3", size: "20pt")
            Divider()
            TypographyRow(font: Typography.headline, label: "Headline", size: "17pt")
            TypographyRow(font: Typography.body, label: "Body", size: "17pt")
            TypographyRow(font: Typography.bodyBold, label: "Body Bold", size: "17pt")
            TypographyRow(font: Typography.callout, label: "Callout", size: "16pt")
            Divider()
            TypographyRow(font: Typography.subheadline, label: "Subheadline", size: "15pt")
            TypographyRow(font: Typography.subheadlineBold, label: "Subheadline Bold", size: "15pt")
            Divider()
            TypographyRow(font: Typography.footnote, label: "Footnote", size: "13pt")
            TypographyRow(font: Typography.footnoteBold, label: "Footnote Bold", size: "13pt")
            Divider()
            TypographyRow(font: Typography.caption1, label: "Caption 1", size: "12pt")
            TypographyRow(font: Typography.caption2, label: "Caption 2", size: "11pt")
        }
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Typography.title2)
            Text(subtitle)
                .font(Typography.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct FontRow: View {
    let weight: RobotoWeight
    let label: String
    
    var body: some View {
        HStack {
            Text("The quick brown fox jumps over the lazy dog")
                .font(.roboto(17, weight: weight))
            Spacer()
            Text(label)
                .font(Typography.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct TypographyRow: View {
    let font: Font
    let label: String
    let size: String
    
    var body: some View {
        HStack {
            Text("The quick brown fox jumps over the lazy dog")
                .font(font)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(label)
                    .font(Typography.caption1)
                Text(size)
                    .font(Typography.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        FontPreviewView()
    }
}
