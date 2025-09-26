# Trap Font Integration Guide

## Step 1: Add Font Files to Xcode Project

1. **Open your Money Manager project in Xcode**
2. **Right-click on the "Money Manager" folder** in the Project Navigator
3. **Select "Add Files to 'Money Manager'"**
4. **Navigate to your Trap font files** and select all 7 font files:
   - `Trap-Black.otf`
   - `Trap-Bold.otf`
   - `Trap-ExtraBold.otf`
   - `Trap-Light.otf`
   - `Trap-Medium.otf`
   - `Trap-Regular.otf`
   - `Trap-SemiBold.otf`
5. **Make sure "Add to target" is checked** for "Money Manager"
6. **Click "Add"**

## Step 2: Add Fonts to Info.plist

1. **Open `Info.plist`** in your project
2. **Add a new key** called `Fonts provided by application` (or `UIAppFonts`)
3. **Add each font file** as a string item:
   - `Trap-Black.otf`
   - `Trap-Bold.otf`
   - `Trap-ExtraBold.otf`
   - `Trap-Light.otf`
   - `Trap-Medium.otf`
   - `Trap-Regular.otf`
   - `Trap-SemiBold.otf`

## Step 3: Verify Font Loading

The app will automatically check if the fonts are loaded when it starts. You can also add this code to test:

```swift
// Add this to your App.swift or ContentView.swift for testing
.onAppear {
    TrapFontUtility.verifyFontsLoaded()
}
```

## Step 4: Build and Test

1. **Clean your project** (Product → Clean Build Folder)
2. **Build the project** (⌘+B)
3. **Run on simulator or device**

## Font Weights Mapping

| Trap Font File | SwiftUI Weight | Usage |
|----------------|----------------|-------|
| Trap-Light.otf | .light | Light text, subtle elements |
| Trap-Regular.otf | .regular | Body text, descriptions |
| Trap-Medium.otf | .medium | Medium emphasis text |
| Trap-SemiBold.otf | .semibold | Headers, important text |
| Trap-Bold.otf | .bold | Main titles, strong emphasis |
| Trap-ExtraBold.otf | .heavy | Large numbers, display text |
| Trap-Black.otf | .black | Hero text, maximum emphasis |

## Fallback System

The app includes a fallback system that will use system fonts if Trap fonts fail to load, ensuring your app continues to work properly.

## Troubleshooting

- **Fonts not loading?** Check that all 7 font files are added to the target
- **Build errors?** Make sure the font names in Info.plist match exactly
- **Fonts not displaying?** Verify the font names in TrapFontUtility.swift match your actual font files

## Testing Different Weights

You can test different font weights by temporarily changing the weight in Constants.swift:

```swift
// Example: Change H1 to use ExtraBold instead of Bold
static let font = TrapFontUtility.safeTrapFont(size: size, weight: .extraBold)
```


















