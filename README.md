# 🚀 PabsApp - Advanced Flutter Multi-Feature Application

<div align="center">
  <img src="assets/icons/icon.jpg" alt="PabsApp Logo" width="120" height="120">

  [![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev/)
</div>

## 📱 Project Overview

PabsApp adalah aplikasi Flutter komprehensif yang menggabungkan monitoring kesehatan sistem, layanan lokasi canggih, dan tools debugging API dalam satu platform yang aman dan user-friendly.

### 🎯 Key Features

- **Health Runtime Monitoring**: Real-time system status, API health checks, weather info
- **Enhanced Location Services**: GPS-based location with offline storage and native maps integration
- **API Debug Tools**: Professional endpoint testing with response analysis
- **Secure Authentication**: Environment-based security with comprehensive user management
- **Profile Management**: User settings, theme customization, and permission handling
- **Dashboard Navigation**: Intuitive quick actions with responsive design

## 🔧 System Requirements

- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+ (if targeting iOS)
- **Development Environment**: Android Studio, VS Code, or IntelliJ IDEA

## 🚀 Installation & Setup Guide

### 1. Repository Setup
```bash
git clone https://github.com/el-pablos/PabsApp.git
cd PabsApp
flutter pub get
```

### 2. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your API keys
nano .env
```

### 3. Required Environment Variables
```env
# App Configuration
APP_NAME=PabsApp
APP_VERSION=1.0.0
APP_AUTHOR=Tamas dari TamsHub

# API Keys (replace with your own)
BOTCAHX_API_KEY=your_botcahx_api_key_here
WEATHER_API_KEY=your_weather_api_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here

# Database Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### 4. Build & Run
```bash
# For Android
flutter run -d android

# For specific device
flutter run -d [device_id]
```

## 👨‍💻 Developer Information

- **Lead Developer**: Tamas (@el-pablos)
- **Contact**: yeteprem.end23juni@gmail.com
- **Repository**: https://github.com/el-pablos/PabsApp
- **License**: MIT License
- **Development Period**: 2024-2025

## 🏗️ Architecture & Technical Implementation

### App Architecture
```
PabsApp/
├── lib/
│   ├── core/                 # Core utilities and services
│   │   ├── models/          # Data models
│   │   ├── services/        # Business logic services
│   │   └── widgets/         # Reusable UI components
│   ├── features/            # Feature-based modules
│   │   ├── auth/           # Authentication system
│   │   ├── dashboard/      # Main dashboard
│   │   ├── health/         # Health monitoring
│   │   ├── maps/           # Location services
│   │   └── debug/          # API debugging tools
│   └── providers/          # State management
```

### Security Implementation
- **Environment-based Configuration**: All sensitive data managed through EnvironmentService
- **Secure Authentication**: Comprehensive session management with proper security
- **Permission Management**: User-friendly permission requests with fallback handling
- **Data Encryption**: Secure local storage and API communication

## 📊 Feature Documentation

### Health Runtime Monitoring
- Real-time system metrics (CPU, memory, battery)
- API endpoint health checking
- Network connectivity monitoring
- Weather information integration
- Auto-refresh every 30 seconds

### Enhanced Location Services
- Device GPS integration without Google Maps API dependency
- Save and manage favorite locations
- Address geocoding using free services
- Native maps app integration for navigation
- Distance calculations and nearby location finder

### API Debug Tools
- Support for GET, POST, PUT, DELETE, PATCH methods
- Preset endpoints for quick testing
- JSON response formatting and syntax highlighting
- Response time monitoring and status code analysis
- Request/response copying and sharing

## 🔐 Security Features

- **Credential Management**: No hardcoded API keys or sensitive data
- **Environment Variables**: Secure configuration through .env files
- **Permission System**: Granular permission requests with user education
- **Data Protection**: Local storage encryption and secure API communication
- **Authentication**: Comprehensive user management with session security

## 🧪 Testing & Verification

### Running the Application
1. Ensure device is connected: `flutter devices`
2. Run application: `flutter run -d [device_id]`
3. Test hot reload: Press 'r' in terminal
4. Access DevTools: Use provided URL for debugging

### Feature Testing Checklist
- [ ] Health monitoring displays correctly
- [ ] Location services work with GPS
- [ ] API debug tools can test endpoints
- [ ] Profile settings save properly
- [ ] All quick actions navigate correctly
- [ ] App icon displays correctly

## 📈 Performance Metrics

- **Startup Time**: Optimized for sub-3-second cold starts
- **Memory Usage**: Efficient memory management with proper disposal
- **Battery Life**: Background service optimization
- **Network Efficiency**: Smart caching and request batching
- **Responsiveness**: 60fps UI with smooth animations

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'add: amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Code Standards
- Follow Dart/Flutter style guidelines
- Use conventional commit messages
- Add comprehensive documentation
- Include unit tests for new features
- Ensure security best practices

## 📝 Changelog

### Version 1.0.0 (2025-01-19)
#### Added
- Initial release with core features
- Health Runtime monitoring system
- Enhanced Location services
- API Debug tools
- Secure authentication system
- Profile and settings management
- Custom app icon implementation

#### Security
- Implemented environment-based credential management
- Removed all hardcoded sensitive data
- Added comprehensive permission system
- Integrated secure authentication

#### Fixed
- UI overflow issues in dashboard
- Compilation errors in location services
- Environment service configuration
- Responsive design improvements

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Open source community for various packages
- Beta testers for valuable feedback

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/el-pablos">Tamas dari TamsHub</a></p>
  <p>© 2025 PabsApp. All rights reserved.</p>
</div>
