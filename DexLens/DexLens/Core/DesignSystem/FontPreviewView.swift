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
            FontSectionHeader(title: "Font Weights", subtitle: "Roboto 17pt")
            
            FontWeightRow(fontName: "Roboto-Thin", label: "Thin (100)")
            FontWeightRow(fontName: "Roboto-Light", label: "Light (300)")
            FontWeightRow(fontName: "Roboto-Regular", label: "Regular (400)")
            FontWeightRow(fontName: "Roboto-Medium", label: "Medium (500)")
            FontWeightRow(fontName: "Roboto-Bold", label: "Bold (700)")
            FontWeightRow(fontName: "Roboto-Black", label: "Black (900)")
        }
    }
    
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            FontSectionHeader(title: "Typography Scale", subtitle: "System Typography Styles")
            
            FontTypographyRow(font: Font.custom("Roboto-Bold", size: 34), label: "Large Title", size: "34pt")
            FontTypographyRow(font: Font.custom("Roboto-Bold", size: 28), label: "Title 1", size: "28pt")
            FontTypographyRow(font: Font.custom("Roboto-Bold", size: 22), label: "Title 2", size: "22pt")
            FontTypographyRow(font: Font.custom("Roboto-Medium", size: 20), label: "Title 3", size: "20pt")
            Divider()
            FontTypographyRow(font: Font.custom("Roboto-Medium", size: 17), label: "Headline", size: "17pt")
            FontTypographyRow(font: Font.custom("Roboto-Regular", size: 17), label: "Body", size: "17pt")
            FontTypographyRow(font: Font.custom("Roboto-Bold", size: 17), label: "Body Bold", size: "17pt")
            FontTypographyRow(font: Font.custom("Roboto-Regular", size: 16), label: "Callout", size: "16pt")
            Divider()
            FontTypographyRow(font: Font.custom("Roboto-Regular", size: 15), label: "Subheadline", size: "15pt")
            FontTypographyRow(font: Font.custom("Roboto-Medium", size: 15), label: "Subheadline Bold", size: "15pt")
            Divider()
            FontTypographyRow(font: Font.custom("Roboto-Regular", size: 13), label: "Footnote", size: "13pt")
            FontTypographyRow(font: Font.custom("Roboto-Medium", size: 13), label: "Footnote Bold", size: "13pt")
            Divider()
            FontTypographyRow(font: Font.custom("Roboto-Regular", size: 12), label: "Caption 1", size: "12pt")
            FontTypographyRow(font: Font.custom("Roboto-Regular", size: 11), label: "Caption 2", size: "11pt")
        }
    }
}

struct FontSectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Font.custom("Roboto-Bold", size: 22))
            Text(subtitle)
                .font(Font.custom("Roboto-Regular", size: 15))
                .foregroundStyle(.secondary)
        }
    }
}

struct FontWeightRow: View {
    let fontName: String
    let label: String
    
    var body: some View {
        HStack {
            Text("The quick brown fox jumps over the lazy dog")
                .font(Font.custom(fontName, size: 17))
            Spacer()
            Text(label)
                .font(Font.custom("Roboto-Regular", size: 11))
                .foregroundStyle(.secondary)
        }
    }
}

struct FontTypographyRow: View {
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
                    .font(Font.custom("Roboto-Regular", size: 12))
                Text(size)
                    .font(Font.custom("Roboto-Regular", size: 11))
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
