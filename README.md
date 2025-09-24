# Money Manager

A comprehensive iOS personal finance management application built with SwiftUI.

## 📱 Overview

Money Manager is a modern, intuitive iOS app designed to help users take control of their personal finances. The app provides essential budgeting, loan tracking, and financial insights in a clean, user-friendly interface.

## ✨ Features

### Core Functionality
- **Budget Management** - Create, edit, and track personal budgets
- **Loan Tracking** - Monitor loans with detailed payment schedules
- **Financial Overview** - Comprehensive dashboard with key metrics
- **Transaction Management** - Track income and expenses
- **Analytics** - Visual charts and financial insights

### Key Highlights
- Clean, modern SwiftUI interface
- Intuitive navigation and user experience
- Real-time financial calculations
- Comprehensive data visualization
- Offline-first design

## 🛠️ Technical Stack

- **Platform**: iOS 15.0+
- **Framework**: SwiftUI
- **Language**: Swift 5.7+
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: Core Data
- **Charts**: Swift Charts
- **Testing**: XCTest

## 📁 Project Structure

```
Money Manager/
├── App.swift                    # Main app entry point
├── Application/                 # App lifecycle management
├── Features/                    # Feature modules
│   ├── Add/                     # Add transaction functionality
│   ├── Budget/                  # Budget management
│   ├── Loan/                    # Loan tracking
│   ├── Notifications/           # Notification system
│   ├── Overview/                # Dashboard and analytics
│   ├── Settings/                # App settings
│   └── Transaction/             # Transaction management
├── Resources/                   # Assets and resources
│   ├── Assets/                  # Images and icons
│   ├── Fonts/                   # Custom fonts
│   └── Localizations/           # Multi-language support
├── Shared/                      # Shared components and utilities
│   ├── Components/              # Reusable UI components
│   ├── Extensions/              # Swift extensions
│   └── Utilities/               # Helper functions
└── Tests/                       # Unit and UI tests
```

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0 or later
- iOS 15.0 or later
- macOS 12.0 or later (for development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ZukicT/ABC-Budgeting.git
   cd ABC-Budgeting
   ```

2. **Open in Xcode**
   ```bash
   open "Money Manager.xcodeproj"
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### Development Setup

1. **Install Dependencies**
   - The project uses Swift Package Manager
   - Dependencies will be resolved automatically on first build

2. **Configure Signing**
   - Update the development team in project settings
   - Ensure proper code signing certificates

## 🧪 Testing

### Running Tests
```bash
# Run all tests
xcodebuild test -project "Money Manager.xcodeproj" -scheme "Money Manager"

# Run specific test target
xcodebuild test -project "Money Manager.xcodeproj" -scheme "Money Manager" -destination "platform=iOS Simulator,name=iPhone 15"
```

### Test Coverage
- Unit tests for business logic
- UI tests for critical user flows
- Integration tests for data persistence

## 📊 CI/CD

The project includes automated CI/CD pipeline:

- **Build Validation** - Automated builds on every commit
- **Testing** - Comprehensive test suite execution
- **Code Quality** - SwiftLint integration
- **Simulator Testing** - Multi-device testing

## 🎨 Design System

### UI Components
- Consistent design language following Apple HIG
- Reusable components for maintainability
- Dark mode support
- Accessibility compliance

### Color Scheme
- Primary: Modern blue tones
- Secondary: Clean grays and whites
- Accent: Financial green for positive values
- Error: Red for warnings and alerts

## 📱 Screenshots

*Screenshots will be added as the app develops*

## 🔧 Configuration

### Environment Variables
- No external API keys required
- All data stored locally using Core Data

### Build Configurations
- **Debug**: Development with additional logging
- **Release**: Optimized for App Store distribution

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Swift style guidelines
- Use SwiftLint for code formatting
- Write comprehensive tests
- Document public APIs

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Tarik Zukic**
- GitHub: [@ZukicT](https://github.com/ZukicT)
- Email: infotarik5@gmail.com

## 🙏 Acknowledgments

- Apple for SwiftUI and iOS development tools
- Swift Charts for data visualization
- The open-source community for inspiration and tools

## 📈 Roadmap

### Version 1.0 (Current)
- [x] Basic budget management
- [x] Loan tracking
- [x] Transaction management
- [x] Financial overview dashboard

### Future Versions
- [ ] Widget support for quick access
- [ ] Advanced analytics and reporting
- [ ] Cloud sync capabilities
- [ ] Export functionality
- [ ] Multi-currency support

## 🐛 Known Issues

- None currently reported

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/ZukicT/ABC-Budgeting/issues) page
2. Create a new issue with detailed information
3. Contact the maintainer directly

---

**Built with ❤️ using SwiftUI**
