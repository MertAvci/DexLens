# Design System

Provides the design foundation for DexLens including typography and fonts.

## Components

| File | Description |
|------|-------------|
| `Fonts/` | Roboto font files (TTF) - 6 weights |
| `Font+Roboto.swift` | Font extension for easy Roboto access |
| `Typography.swift` | Typography scale with predefined styles |
| `FontPreviewView.swift` | Preview view to verify all font weights and styles |

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

## Usage

### Using Font Extension
```swift
Text("Hello, World!")
    .font(.roboto(17, weight: .medium))
```

### Using Typography Scale
```swift
Text("Welcome to DexLens")
    .font(Typography.title1)

Text("This is body text")
    .font(Typography.body)
```

## Setup Instructions

To complete the font integration, you need to add the font files to the Xcode project:

1. **Open `DexLens.xcodeproj` in Xcode**

2. **Add font files to the target:**
   - Right-click on `DexLens` folder in the project navigator
   - Select "Add Files to DexLens..."
   - Navigate to `DexLens/Core/DesignSystem/Fonts/`
   - Select all `*.ttf` files
   - Make sure "Copy items if needed" is checked
   - Make sure "Add to target: DexLens" is checked
   - Click "Add"

3. **Register fonts in Info.plist (modern Xcode approach):**
   - Select the `DexLens` project in the navigator
   - Select the `DexLens` target
   - Go to the "Info" tab
   - Add a new entry under "Custom iOS Target Properties":
     - Key: `Fonts provided by application` (Array)
     - Items (add each):
       - `Roboto-Thin.ttf`
       - `Roboto-Light.ttf`
       - `Roboto-Regular.ttf`
       - `Roboto-Medium.ttf`
       - `Roboto-Bold.ttf`
       - `Roboto-Black.ttf`

4. **Build and Run**
   - Clean the build folder (Cmd + Shift + K)
   - Build and run (Cmd + R)

5. **Verify fonts:**
   - Navigate to `FontPreviewView` in the app to see all font weights and typography styles

## Font Source

Roboto font by Google Fonts
- License: Apache License 2.0
- Downloaded from: https://github.com/googlefonts/roboto
