# Design System

Provides the design foundation for DexLens including typography, fonts, colors, and gradients.

## Components

| File | Description |
|------|-------------|
| `Fonts/` | Roboto font files (TTF) - 6 weights |
| `Font+Roboto.swift` | Font extension for easy Roboto access |
| `Typography.swift` | Typography scale with predefined styles |
| `FontPreviewView.swift` | Preview view to verify all font weights and styles |
| `Color+DesignSystem.swift` | Color extension for semantic color access |
| `Gradient+DesignSystem.swift` | Gradient extension with predefined gradients |
| `ColorPreviewView.swift` | Preview view for all colors, gradients, and UI components |

## Font Weights

| Weight | Size | PostScript Name |
|--------|------|-----------------|
| Thin | 100 | Roboto-Thin |
| Light | 300 | Roboto-Light |
| Regular | 400 | Roboto-Regular |
| Medium | 500 | Roboto-Medium |
| Bold | 700 | Roboto-Bold |
| Black | 900 | Roboto-Black |

## Typography Scale

### Display / Headings
- `largeTitle` - 34pt Bold
- `title1` - 28pt Bold
- `title2` - 22pt Bold
- `title3` - 20pt Medium

### Body
- `headline` - 17pt Medium
- `body` - 17pt Regular
- `bodyBold` - 17pt Bold
- `callout` - 16pt Regular

### Subheadline
- `subheadline` - 15pt Regular
- `subheadlineBold` - 15pt Medium

### Footnote & Caption
- `footnote` - 13pt Regular
- `footnoteBold` - 13pt Medium
- `caption1` - 12pt Regular
- `caption2` - 11pt Regular

## Colors (Deep Ocean Theme)

### Semantic Colors

| Color | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `primary` | `#0891B2` (Cyan 600) | `#06B6D4` (Cyan 500) | Brand, buttons, active states |
| `primaryMuted` | `#67E8F9` (Cyan 200) | `#22D3EE` (Cyan 400) | Secondary buttons |
| `success` | `#059669` (Emerald 600) | `#10B981` (Emerald 500) | Gains, positive values |
| `error` | `#DC2626` (Red 600) | `#EF4444` (Red 500) | Losses, negative values |
| `warning` | `#D97706` (Amber 600) | `#F59E0B` (Amber 500) | Alerts, warnings |
| `surface` | `#FFFFFF` (White) | `#0F172A` (Dark Slate 900) | Backgrounds, cards |
| `surfaceSecondary` | `#ECFEFF` (Sky 50) | `#111827` (Slate 900) | Alternating backgrounds |
| `textPrimary` | `#083344` (Cyan 950) | `#CFFAFE` (Cyan 100) | Headings, body |
| `textSecondary` | `#64748B` (Slate 500) | `#94A3B8` (Slate 400) | Captions, placeholders |
| `border` | `#E0F2FE` (Sky 100) | `#155E75` (Cyan 900) | Dividers, borders |
| `overlay` | `#000000` (60% opacity) | `#FFFFFF` (20% opacity) | Modals, sheets |

## Gradients

| Gradient | Colors | Usage |
|----------|---------|-------|
| `primaryGradient` | Cyan 500 → Cyan 600 | Hero sections, major buttons |
| `successGradient` | Emerald 500 → Emerald 600 | Success cards, positive highlights |
| `deepOceanGradient` | Cyan 500 → Sky 950 | Backgrounds, cards |

## Usage

### Using Font Extension
```swift
Text("Hello, World!")
    .font(.roboto(17, weight: .medium))
```

### Using Typography
```swift
Text("Welcome to DexLens")
    .font(Font.custom("Roboto-Bold", size: Typography.title1))
```

### Using Colors
```swift
// Access via Color extension
Text("Welcome")
    .foregroundStyle(Color.primary)

Button("Connect") {}
    .background(Color.primary)

Card()
    .background(Color.surface)
    .border(Color.border, width: 1)
```

### Using Gradients
```swift
// Access via LinearGradient extension
VStack {
    Text("Hero")
}
.background(LinearGradient.primaryGradient)

Button("Primary Action") {}
    .background(LinearGradient.successGradient)
```

### Using ColorPreviewView
Run the app and tap "Color Preview" to see all colors, gradients, and UI components.

## Font Source

Roboto font by Google Fonts
- License: Apache License 2.0
- Downloaded from: https://github.com/googlefonts/roboto
