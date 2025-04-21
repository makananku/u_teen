# U-Teen: UMN Canteen Management System

## Project Overview
U-Teen is a comprehensive mobile application designed to streamline food ordering and management processes for UMN (Universitas Multimedia Nusantara) canteens. The app features two main user roles:
- Customer: Students/staff can browse menus, place orders, and track order status
- Seller: Canteen vendors can manage products, process orders, and view sales analytics

## Technical Specifications

### Development Environment
- Flutter SDK: 3.7.2+
- Dart SDK: 3.0.0+
- Android: minSdk 21, targetSdk 35
- IDE: Recommended - Android Studio or VS Code with Flutter extensions
- State Management: Provider
- Local Storage: SharedPreferences
-vArchitecture: MVVM (Model-View-ViewModel) pattern

--------------------------------------------------------------------------------
Setup Instructions
Prerequisites

Flutter 3.29.2 • channel stable • https://github.com/flutter/flutter.git
Framework • revision c236373904 (5 weeks ago) • 2025-03-13 16:17:06 -0400
Engine • revision 18b71d647a
Tools • Dart 3.7.2 • DevTools 2.42.3

Java
openjdk 17.0.14 2025-01-21
OpenJDK Runtime Environment Temurin-17.0.14+7 (build 17.0.14+7)
OpenJDK 64-Bit Server VM Temurin-17.0.14+7 (build 17.0.14+7, mixed mode, sharing)

Dart SDK version: 3.7.2 (stable) (Tue Mar 11 04:27:50 2025 -0700) on "windows_x64"
Android Studio/Xcode

git version 2.48.1.windows.1

gradle-8.9-all (yang ini instalasi langsung dari VSCode)

Environment Variables Path 
Cara akses: Windows + R, sysdm.cpl, Advanced, Environment Variables, System Variables, Path, Edit.
--HARUS URUT--
C:\flutter\bin
C:\Program Files\Git\cmd
C:\Program Files\Git\bin
C:\Windows\System32
C:\Users\Acer\AppData\Local\Pub\Cache\bin
%USERPROFILE%\AppData\Local\Pub\Cache\bin
C:\Program Files\nodejs (untuk flutterfire apabila diperlukan)
C:\Program Files\dotnet (untuk flutterfire apabila diperlukan)
C:\Windows\System32\WindowsPowerShell\v1.0\ (kalau powershell tidak terdeteksi windows)
C:\Program Files\Eclipse Adoptium\jdk-17.0.14+7
C:\Program Files\Eclipse Adoptium\jdk-17.0.14+7\bin
C:\Program Files\dotnet\ (untuk flutterfire apabila diperlukan)

------------------------------------------------------------------------------------------
### Project Structure
u_teen/
├── android/ # Android platform-specific code
├── assets/ # All static assets
│ ├── animation/ # Lottie animation files
│ ├── asset/ # General assets (images, etc.)
│ ├── drink/ # Drink product images
│ ├── food/ # Food product images
│ ├── payment/ # Payment method icons
│ └── snack/ # Snack product images
├── lib/ # Main application code
│ ├── auth/ # Authentication related files
│ ├── data/ # Data sources and static data
│ ├── models/ # Data models
│ ├── providers/ # State management providers
│ ├── screens/ # All application screens
│ │ ├── customer/ # Customer-facing screens
│ │ └── seller/ # Seller/admin screens
│ ├── services/ # Business logic services
│ ├── widgets/ # Reusable UI components
│ │ ├── customer/ # Customer-specific widgets
│ │ ├── seller/ # Seller-specific widgets
│ │ └── common/ # Shared widgets
│ └── main.dart # Application entry point
├── test/ # Unit and widget tests
└── pubspec.yaml # Project dependencies and metadata

------------------------------------------------------
Core Components
1. Authentication System

auth_provider.dart
Manages user authentication state
Handles login/logout functionality
Persists user data using SharedPreferences
Provides user type checks (isSeller/isCustomer)

auth_service.dart
Contains dummy user data for development
Validates UMN email domains (@student.umn.ac.id, @seller.umn.ac.id)
Implements login logic with simulated API delay

logout_service.dart
Centralized logout functionality
Clears auth state and navigates to login screen
Includes confirmation dialog

2. Data Models

user_model.dart
Base user model with email, name, and userType
Used across authentication and profile systems

product_model.dart
Represents food items with:
ID, title, price, preparation time
Image URL and seller information

order_model.dart
Comprehensive order tracking system:
Order status lifecycle (pending → processing → completed)
Payment method tracking
Merchant and customer information
Order items with quantities

cart_item.dart / favorite_item.dart
Specialized models for shopping cart and favorites
Includes quantity management and price calculations

Customer Features
1. Home Screen (home_screen.dart)
Dynamic food browsing with category filters
Interactive search functionality
Product detail overlay with:
Add to cart/favorites
Quantity selection
Recent search history

2. Shopping System
cart_provider.dart
Manages cart state with:
Item grouping by merchant
Quantity adjustments
Total price calculation

shopping_cart_screen.dart
Displays cart items with swipe-to-delete
Quantity modification controls
Checkout button

payment_screen.dart
Order finalization with:
Time picker with validation
Payment method selection
Notes field

3. Order Management
order_provider.dart
Tracks order history
Filters orders by status
Generates order IDs
Persists orders locally
my_orders_screen.dart

Tabbed interface for:

Ongoing orders
Order history
Detailed order tracking

Seller Features
1. Seller Dashboard (home_screen.dart)
Sales metrics display
Order status overview
UMN academic calendar integration

2. Product Management
food_provider.dart
Manages product inventory
Handles CRUD operations
Filters products by seller

my_product_screen.dart
Product listing with edit/delete
Add new product flow

edit_product_screen.dart
Form for product details
Image picker integration
Preparation time slider

3. Order Processing
on_process_screen.dart
Order queue management
Status updates (mark as ready/cancel)
Customer notes display

Shared Components
1. UI Widgets
custom_bottom_navigation.dart
Animated navigation bar
Role-specific variants (customer/seller)
Keyboard-aware positioning

food_list.dart
Responsive food item grid
Category filtering
Image loading with error handling

payment_method_card.dart
Interactive payment selector
Visual feedback on selection
Supports multiple payment types

2. Utility Services
calendar_service.dart
Fetches UMN academic events
Handles date formatting
Fallback data for offline use

email_service.dart
Simulates order notifications
Formats order details for email

navigation_utils.dart
Standardized page transitions
Directional slide animations


------------------------------------------------------
##Key Features

### Customer Features
1. User Authentication
   - Email-based login with UMN domain validation
   - Persistent session management
   - Role-based access (customer/seller)

2. Food Discovery
   - Categorized menu browsing (Food, Drinks, Snacks)
   - Search functionality with recent/popular searches
   - Favorite items management

3. Order Management
   - Cart system with quantity adjustment
   - Order placement with pickup time selection
   - Multiple payment methods (GoPay, OVO)
   - Order history tracking

4. User Interface
   - Interactive food detail panels
   - Smooth animations and transitions
   - Responsive design for various screen sizes

### Seller Features
1. Product Management
   - Add/edit/delete food items
   - Product image upload
   - Preparation time configuration

2. Order Processing
   - Real-time order notifications
   - Order status management (pending/ready/completed)
   - Cancellation handling with reason tracking

3. Sales Analytics
   - Daily/weekly/monthly sales metrics
   - Transaction history
   - Balance management and withdrawal

4. Event Calendar
   - University event integration
   - Holiday and special day indicators

-----------------------------------------
## Dependencies

### Core Dependencies
- `provider: ^6.0.5` - State management
- `shared_preferences: ^2.2.2` - Local storage
- `intl: ^0.19.0` - Internationalization
- `http: ^1.1.0` - HTTP requests

### UI/UX Dependencies
- `lottie: ^3.3.1` - Animation support
- `flutter_keyboard_visibility: ^6.0.0` - Keyboard handling
- `cached_network_image: ^3.3.0` - Image caching

### Device Integration
- `image_picker: ^1.1.2` - Image selection
- `path_provider: ^2.1.1` - Filesystem access
- `flutter_plugin_android_lifecycle: ^2.0.27` - Android lifecycle

## Setup Instructions

### Prerequisites
1. Install Flutter SDK (v3.7.2 or later)
2. Install Android Studio/Xcode for platform-specific tools
3. Set up an emulator or physical device for testing



-----------------------------------------------------
Clean dependencies:
flutter clean

Install dependencies:
flutter pub get

Update depencencies:
flutter pub upgrade

Generate localization files:
flutter gen-l10n

Run the application:
flutter run

---------------------------------------------------------------
Configuration

Environment Variables

Bisa digunakan untuk Android
Belum dikonfigurasi ulang untuk iOS, kemungkinan besar akan error

