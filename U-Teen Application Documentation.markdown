# U-Teen Application Documentation

## Overview

U-Teen is a Flutter-based mobile application designed for the UMN (Universitas Multimedia Nusantara) canteen, streamlining food ordering and management. It supports two user roles: **customers**, who can browse food items, add them to a cart, place orders, schedule pickups, rate experiences, and manage favorites, and **sellers**, who can manage products, track orders, update statuses, monitor financial metrics, and view ratings. The app integrates with Google Calendar for holiday events, supports email notifications (pending backend implementation), and uses a robust authentication system. Built with **Flutter**, it leverages **Provider** for state management, **SharedPreferences** for local storage, and **intl** for Indonesian localization (`id_ID`).

This documentation provides a comprehensive guide to the project’s architecture, file structure, components, functionality, and setup instructions. It is intended for developers, maintainers, and stakeholders to understand the system and facilitate future development or maintenance.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Key Components](#key-components)
   - [Models](#models)
   - [Providers](#providers)
   - [Screens](#screens)
   - [Widgets](#widgets)
   - [Services and Utilities](#services-and-utilities)
   - [Data](#data)
3. [Core Functionality](#core-functionality)
   - [Authentication](#authentication)
   - [Food Browsing and Searching](#food-browsing-and-searching)
   - [Cart Management](#cart-management)
   - [Order Placement and Tracking](#order-placement-and-tracking)
   - [Notifications](#notifications)
   - [Favorites](#favorites)
   - [Calendar Integration](#calendar-integration)
   - [Seller Features](#seller-features)
4. [Dependencies](#dependencies)
5. [Setup and Installation](#setup-and-installation)
6. [Potential Improvements](#potential-improvements)
7. [Known Issues](#known-issues)

---

## Project Structure

The project follows a modular structure for maintainability and scalability. Below is the complete directory structure based on all provided and referenced files:

```
lib/
├── auth/
│   ├── auth_provider.dart
│   ├── auth_service.dart
│   ├── logout_service.dart
├── data/
│   ├── food_data.dart
│   ├── payment_methods_data.dart
│   ├── search_data.dart
├── models/
│   ├── balance_model.dart
│   ├── cart_item.dart
│   ├── favorite_item.dart
│   ├── notification_model.dart
│   ├── order_model.dart
│   ├── payment_method.dart
│   ├── product_model.dart
│   ├── user_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── balance_provider.dart
│   ├── cart_provider.dart
│   ├── favorite_provider.dart
│   ├── food_provider.dart
│   ├── notification_provider.dart
│   ├── order_provider.dart
│   ├── ratings_provider.dart
├── screens/
│   ├── customer/
│   │   ├── favorite_screen.dart
│   │   ├── home_screen.dart
│   │   ├── my_orders_screen.dart
│   │   ├── notification_screen.dart
│   │   ├── payment_screen.dart
│   │   ├── payment_success_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── shopping_cart_screen.dart
│   ├── login_screen.dart
│   ├── seller/
│   │   ├── cancellation_screen.dart
│   │   ├── completed_screen.dart
│   │   ├── edit_product_screen.dart
│   │   ├── home_screen.dart
│   │   ├── my_balance_screen.dart
│   │   ├── my_product_screen.dart
│   │   ├── on_process_screen.dart
│   │   ├── transaction_history_screen.dart
├── widgets/
│   ├── customer/
│   │   ├── cart_item_widget.dart
│   │   ├── cart_summary_widget.dart
│   │   ├── category_selector.dart
│   │   ├── custom_bottom_navigation.dart
│   │   ├── detail_box.dart
│   │   ├── search_widget.dart
│   ├── calendar_service.dart
│   ├── calendar_utils.dart
│   ├── email_service.dart
│   ├── event_card.dart
│   ├── food_list.dart
│   ├── navigation_utils.dart
│   ├── notes_field.dart
│   ├── order_card.dart
│   ├── payment_method_card.dart
│   ├── sales_metric_card.dart
│   ├── seller_custom_bottom_navigation.dart
│   ├── status_button.dart
│   ├── time_picker_widget.dart
├── main.dart
├── order_repository.dart
├── pubspec.yaml
```

### Directory Descriptions

- **auth/**: Authentication logic, including providers and services for login and logout.
- **data/**: Static data sources for food items, payment methods, and search history.
- **models/**: Data models for entities like users, orders, cart items, and products.
- **providers/**: State management classes using the Provider package.
- **screens/**: UI screens for customer and seller functionalities, organized by role.
- **widgets/**: Reusable UI components, services, and utilities for consistent design and functionality.
- **main.dart**: Application entry point, initializing providers and displaying the splash screen.
- **order_repository.dart**: Repository for order-related operations (currently minimal).
- **pubspec.yaml**: Project configuration, dependencies, and assets.

---

## Key Components

### Models

Models define data structures, often with serialization for SharedPreferences persistence.

1. **Balance (`balance_model.dart`)**

   - Represents a seller’s financial balance.
   - Properties: `amount`, `history` (list of `BalanceHistory`).
   - `BalanceHistory`: Tracks transactions with `id`, `date`, `type` (income/withdrawal), `amount`, `description`, `orderId`, `paymentMethod`.

2. **CartItem (`cart_item.dart`)**

   - Represents a cart item.
   - Properties: `name`, `price`, `image`, `subtitle`, `sellerEmail`, `quantity`.
   - Features: Equality and hash code overrides.

3. **FavoriteItem (`favorite_item.dart`)**

   - Represents a favorite food item.
   - Properties: `name`, `price`, `image`, `subtitle`.
   - Features: JSON serialization.

4. **NotificationModel (`notification_model.dart`)**

   - Represents a notification.
   - Properties: `id`, `type` (order/system/promo), `title`, `message`, `timestamp`, `isRead`, `payload`.
   - Features: Can be created from an `Order` for status updates.

5. **Order (`order_model.dart`)**

   - Represents an order.
   - Properties: `id`, `orderTime`, `pickupTime`, `items` (list of `OrderItem`), `status`, `paymentMethod`, `merchantName`, `merchantEmail`, `customerName`, `cancellationReason`, `notes`, `completedTime`, `cancelledTime`, `foodRating`, `appRating`, `foodNotes`, `appNotes`.
   - `OrderItem`: `name`, `image`, `subtitle`, `price`, `quantity`, `sellerEmail`.

6. **PaymentMethod (`payment_method.dart`)**

   - Represents a payment method.
   - Properties: `id`, `name`, `iconPath`, `description`, `primaryColor`, `requiresPhoneNumber`, `supportsTopUp`.

7. **Product (`product_model.dart`)**

   - Represents a food product.
   - Properties: `id`, `title`, `subtitle`, `time`, `imgUrl`, `price`, `sellerEmail`.
   - Note: Contains a syntax error in the constructor (needs correction, see Known Issues).

8. **User (`user_model.dart`, `auth_provider.dart`)**
   - Represents a user.
   - Properties: `email`, `name`, `userType` (customer/seller), optional `password`.
   - Note: Redundant definitions; `auth_provider.dart` version is used.

### Providers

Providers manage state for reactive UI updates.

1. **AuthProvider (`auth_provider.dart`)**

   - Manages authentication, login, logout, and user data persistence.
   - Properties: `user`, `isLoading`, `isLoggedIn`, `isSeller`, `isCustomer`, `sellerEmail`, `customerEmail`, `customerName`.

2. **BalanceProvider (`balance_provider.dart`)**

   - Manages seller balances with SharedPreferences.
   - Functions: Load/save balances, add income, process withdrawals.

3. **CartProvider (`cart_provider.dart`)**

   - Manages cart items, quantities, and totals, grouping by merchant.

4. **FavoriteProvider (`favorite_provider.dart`)**

   - Manages favorite items with SharedPreferences.
   - Functions: Add/remove favorites, check favorite status, clear favorites.

5. **FoodProvider (`food_provider.dart`)**

   - Manages food products from `food_data.dart` with CRUD operations.

6. **NotificationProvider (`notification_provider.dart`)**

   - Manages notifications with SharedPreferences.
   - Functions: Add, mark as read, mark all as read, clear, filter by customer.

7. **OrderProvider (`order_provider.dart`)**

   - Manages orders, status updates, and ratings with SharedPreferences.
   - Functions: Add orders, update status, submit ratings, create orders from cart, calculate earnings.

8. **RatingsProvider (`ratings_provider.dart`)**
   - Manages seller ratings based on completed orders.
   - Functions: Get rated orders, calculate average food rating, retrieve notes.

### Screens

Screens represent primary UI views, organized by role.

1. **Customer Screens**

   - **FavoriteScreen (`favorite_screen.dart`)**
     - Lists favorite food items with swipe-to-remove and detail navigation.
   - **HomeScreen (`home_screen.dart`)**
     - Main interface for browsing food items.
     - Components: `SearchWidget`, `CategorySelector`, `FoodList`, `DetailBox`, `CustomBottomNavigation`.
     - Features: Add to cart/favorites.
   - **MyOrdersScreen (`my_orders_screen.dart`)**
     - Displays orders in Ongoing/History tabs using `OrderCard`.
   - **NotificationScreen (`notification_screen.dart`)**
     - Shows customer notifications with read/order detail options.
   - **PaymentScreen (`payment_screen.dart`)**
     - Handles payment, pickup time, and notes; submits orders via `OrderProvider`.
   - **PaymentSuccessScreen (`payment_success_screen.dart`)**
     - Confirms successful payment with order details.
   - **ProfileScreen (`profile_screen.dart`)**
     - Manages user profile, favorites, ratings, payment methods, security, help, logout.
   - **ShoppingCartScreen (`shopping_cart_screen.dart`)**
     - Manages cart items, notes, payment methods, pickup time.
     - Components: `CartItemWidget`, `CartSummaryWidget`, `NotesField`, `PaymentMethodCard`, `TimePickerWidget`.

2. **Seller Screens**

   - **SellerHomeScreen (`seller/home_screen.dart`)**
     - Dashboard with sales metrics, order statuses, calendar events.
     - Components: `SalesMetricCard`, `StatusButton`, `EventCard`, `SellerCustomBottomNavigation`.
   - **MyProductScreen (`my_product_screen.dart`)**
     - Lists products with edit/delete options; navigates to `edit_product_screen.dart`.
   - **EditProductScreen (`edit_product_screen.dart`)**
     - Form for adding/editing products with image selection.
   - **MyBalanceScreen (`my_balance_screen.dart`)**
     - Displays balance and transaction history.
   - **OnProcessScreen (`on_process_screen.dart`)**
     - Shows pending/processing orders with actions via `OrderCard`.
   - **CompletedScreen (`completed_screen.dart`)**
     - Lists completed orders with ratings.
   - **CancellationScreen (`cancellation_screen.dart`)**
     - Displays cancelled orders with reasons.
   - **TransactionHistoryScreen (`transaction_history_screen.dart`)**
     - Shows transaction history.

3. **Other Screens**
   - **LoginScreen (`login_screen.dart`)**
     - Handles login with email, name, role selection.

### Widgets

Reusable components ensure UI consistency.

1. **CalendarService (`calendar_service.dart`)**

   - Fetches Google Calendar events, merging consecutive holidays.
   - Dependencies: `http`, `intl`.

2. **CalendarUtils (`calendar_utils.dart`)**

   - Provides event icons, colors, and date formatting for Indonesian locale.

3. **CartItemWidget (`cart_item_widget.dart`)**

   - Displays cart item with image, name, price, subtitle, quantity controls.
   - Features: Swipe-to-remove with confirmation.
   - Dependencies: `cart_provider.dart`, `intl`.

4. **CartSummaryWidget (`cart_summary_widget.dart`)**

   - Shows cart total and checkout button (disabled if empty).
   - Dependencies: `cart_provider.dart`.

5. **CategorySelector (`category_selector.dart`)**

   - Horizontal category filter (All, Food, Drinks, Snack).

6. **CustomBottomNavigation (`custom_bottom_navigation.dart`)**

   - Customer navigation bar (Home, Orders, Cart, Profile) with animations.
   - Dependencies: `flutter_keyboard_visibility`.

7. **DetailBox (`detail_box.dart`)**

   - Detailed food item view with cart/favorite buttons, drag-to-close.
   - Dependencies: `favorite_provider.dart`.

8. **EmailService (`email_service.dart`)**

   - Logs order notifications (backend pending).
   - Dependencies: `order_model.dart`, `intl`.

9. **EventCard (`event_card.dart`)**

   - Displays calendar events with date, name, description, icon.

10. **FoodList (`food_list.dart`)**

    - Horizontal list of food items using `FoodCard`.
    - Displays image, title, subtitle, time; supports tap for details.
    - Dependencies: `food_data.dart`.

11. **NavigationUtils (`navigation_utils.dart`)**

    - Slide and fade navigation animations.

12. **NotesField (`notes_field.dart`)**

    - Multi-line text field for order notes.

13. **OrderCard (`order_card.dart`)**

    - Displays order details (status, items, total, notes, ratings, cancellation reasons).
    - Seller: Mark as ready/cancel (pending/processing).
    - Customer: Confirm pickup with `RatingDialog` for ready orders.
    - Dependencies: `order_provider.dart`, `intl`.

14. **PaymentMethodCard (`payment_method_card.dart`)**

    - Displays payment method with icon, name, description, selection animation.
    - Features: Haptic feedback, glowing effect.
    - Dependencies: `payment_method.dart`.

15. **SalesMetricCard (`sales_metric_card.dart`)**

    - Displays sales metrics (revenue, orders) with icon, value, label.

16. **SearchWidget (`search_widget.dart`)**

    - Search bar with recent searches, popular cuisines, results.
    - Dependencies: `food_data.dart`, `search_data.dart`, `food_list.dart`.

17. **SellerCustomBottomNavigation (`seller_custom_bottom_navigation.dart`)**

    - Seller navigation bar (Home, Balance, Products) with animations.

18. **StatusButton (`status_button.dart`)**

    - Filters orders by status with count badge.

19. **TimePickerWidget (`time_picker_widget.dart`)**
    - Time picker (08:00 AM–05:00 PM) with 12-hour format, custom AM/PM buttons.
    - Dependencies: `intl`.

### Services and Utilities

1. **CalendarService (`calendar_service.dart`)**

   - Integrates Google Calendar API for holiday events.
   - Features: Merges consecutive events, fallback events.

2. **CalendarUtils (`calendar_utils.dart`)**

   - Event icons, colors, formatting.

3. **EmailService (`email_service.dart`)**

   - Prepares email notifications (console logging).

4. **LogoutService (`logout_service.dart`)**

   - Displays logout confirmation dialog, clears user data via `AuthProvider`.

5. **NavigationUtils (`navigation_utils.dart`)**
   - Custom navigation animations.

### Data

Static data sources for initial content.

1. **FoodData (`food_data.dart`)**

   - Food items with `title`, `subtitle`, `price`, `time`, `imgUrl`, `sellerEmail`.

2. **PaymentMethodsData (`payment_methods_data.dart`)**

   - Payment methods with `id`, `name`, `icon`, `description`, `requirements`.

3. **SearchData (`search_data.dart`)**
   - Recent searches and popular cuisines with persistence.

---

## Core Functionality

### Authentication

- **Splash Screen**: `main.dart` displays an animated splash screen (`assets/logo/u.png`, text, login button) using Lottie animations. Auto-navigates to `HomeScreen` (customer) or `SellerHomeScreen` (seller) if logged in, else `LoginScreen`.
- **Login**: `LoginScreen` collects email, name, role (`customer`/`seller`). `AuthProvider` persists data in SharedPreferences.
- **Logout**: `LogoutService` shows a confirmation dialog, clears user data via `AuthProvider`.
- **Initialization**: `AuthProvider` checks SharedPreferences for user data on start.

### Food Browsing and Searching

- **Browsing**: `HomeScreen` displays food items via `FoodList`, filtered by `CategorySelector` (All, Food, Drinks, Snack). Tapping opens `DetailBox` for cart/favorite actions.
- **Searching**: `SearchWidget` searches by title/subtitle, shows recent searches and popular cuisines as chips, and displays results as list tiles with `FoodList`.

### Cart Management

- **Adding Items**: Items added from `HomeScreen`, `FavoriteScreen`, or `DetailBox`. `CartProvider` groups by merchant.
- **Modifying Cart**: `ShoppingCartScreen` supports quantity changes, item removal (swipe/button), and totals via `CartSummaryWidget`.
- **Checkout**: Users add notes (`NotesField`), select payment methods (`PaymentMethodCard`, e.g., `assets/payment/gopay.png`), and schedule pickup (`TimePickerWidget`) before proceeding to `PaymentScreen`.

### Order Placement and Tracking

- **Placement**: `PaymentScreen` collects payment method, pickup time, notes, and submits orders via `OrderProvider`. `EmailService` logs notifications (backend pending). Cart is cleared, and users are redirected to `PaymentSuccessScreen`.
- **Tracking**: `MyOrdersScreen` displays orders (pending, processing, ready, completed, cancelled) in Ongoing/History tabs using `OrderCard`.
- **Status Updates**: Sellers mark orders as ready/cancel via `OrderCard` on `OnProcessScreen`. Customers confirm pickup on `MyOrdersScreen`, triggering `RatingDialog`.
- **Ratings**: `RatingDialog` collects 1–5 star ratings for food/app with optional notes, submitted via `OrderProvider`.

### Notifications

- **Generation**: `NotificationProvider` creates notifications for order status changes using `NotificationModel.fromOrder`.
- **Display**: `NotificationScreen` shows customer notifications with read/order detail options.
- **Persistence**: Stored in SharedPreferences.

### Favorites

- **Management**: `FavoriteProvider` adds/removes favorites from `DetailBox` or `FavoriteScreen`, persisted in SharedPreferences.
- **Display**: `FavoriteScreen` lists favorites with swipe-to-remove and detail navigation.

### Calendar Integration

- **Fetching**: `CalendarService` retrieves holiday events from Google Calendar, merging consecutive events.
- **Display**: `EventCard` shows events on `SellerHomeScreen` with date, name, description, icon.
- **Utilities**: `CalendarUtils` provides icons, colors, and formatting.

### Seller Features

- **Product Management**: `MyProductScreen` lists products; `EditProductScreen` adds/edits with `image_picker`. `FoodProvider` handles CRUD.
- **Order Management**: `OnProcessScreen`, `CompletedScreen`, `CancellationScreen` manage orders by status using `OrderCard`.
- **Balance Tracking**: `MyBalanceScreen` and `TransactionHistoryScreen` show earnings/transactions via `BalanceProvider`.
- **Metrics**: `SalesMetricCard` displays revenue, order count on `SellerHomeScreen`.
- **Ratings**: `RatingsProvider` calculates average food ratings and collects feedback.

---

## Dependencies

The `pubspec.yaml` specifies the following dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_keyboard_visibility: ^6.0.0
  shared_preferences: ^2.2.2
  lottie: ^3.3.1
  intl: ^0.19.0
  image_picker: ^1.1.2
  path_provider: ^2.1.1
  path: ^1.8.3
  provider: ^6.0.5
  flutter_plugin_android_lifecycle: ^2.0.27
  http: ^1.1.0
  cached_network_image: ^3.3.0
  cupertino_icons: ^1.0.8
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### Descriptions

- **flutter_localizations**: Indonesian localization (`id_ID`).
- **flutter_keyboard_visibility**: Adjusts UI for keyboard visibility.
- **shared_preferences**: Stores user data, cart, favorites, orders, notifications.
- **lottie**: Animations (e.g., `empty_cart.json`, `success_checkmark.json`).
- **intl**: Date, time, currency formatting.
- **image_picker**: Selects product images in `edit_product_screen.dart`.
- **path_provider**, **path**: File system access for images.
- **provider**: State management.
- **flutter_plugin_android_lifecycle**: Android lifecycle support for `image_picker`.
- **http**: Google Calendar API requests.
- **cached_network_image**: Caches food images (e.g., `mie_ayam.jpg`).
- **cupertino_icons**: Icon assets.
- **flutter_test**, **flutter_lints**: Testing and linting.

---

## Setup and Installation

1. **Prerequisites**:

   - Flutter SDK: ^3.7.2
   - Dart: Included with Flutter
   - IDE: Android Studio or VS Code with Flutter extensions
   - Android: minSdk 21, targetSdk 35
   - iOS: Xcode for iOS builds
   - Emulator or physical device
   - State Management: Provider
   - Local Storage: SharedPreferences
   - Architecture: MVVM (Model-View-ViewModel)

2. **Installation**:

- Flutter 3.29.2 • channel stable • https://github.com/flutter/flutter.git
  Framework • revision c236373904 (5 weeks ago) • 2025-03-13 16:17:06 -0400
  Engine • revision 18b71d647a
  Tools • Dart 3.7.2 • DevTools 2.42.3

- Java
  openjdk 17.0.14 2025-01-21
  OpenJDK Runtime Environment Temurin-17.0.14+7 (build 17.0.14+7)
  OpenJDK 64-Bit Server VM Temurin-17.0.14+7 (build 17.0.14+7, mixed mode, sharing)

  Dart SDK version: 3.7.2 (stable) (Tue Mar 11 04:27:50 2025 -0700) on "windows_x64"
  Android Studio/Xcode

- git version 2.48.1.windows.1

- gradle-8.10-bin

- Environment Variables Path
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

3. **Clone the Repository**:

   ```bash
   git clone <repository-url>
   cd u-teen
   ```

4. **Dependencies Terminal Command**:

- Clean dependencies:
  flutter clean

- Install dependencies:
  flutter pub get

- Update depencencies:
  flutter pub upgrade

- Generate localization files:
  flutter gen-l10n

- Run the application:
  flutter run

- Gradle clean:
  rd /s /q %userprofile%\.gradle\caches
  rd /s /q C:\Users\Acer\u_teen\build

4. **Configure Assets**:

   - Ensure `assets/` contains:
     - Logo: `assets/logo/u.png`
     - Profile: `assets/asset/profile_picture.jpg`
     - Animations: `assets/animation/empty_cart.json`, `empty_order.json`, `success_checkmark.json`, `empty_notification.json`
     - Payment Icons: `assets/payment/gopay.png`, `ovo.png`
     - Food Images: `assets/food/mie_ayam.jpg`, `bakso.jpg`, `soto_ayam.jpg`, `nasi_pecel.jpg`
     - Drink Images: `assets/drink/matcha_latte.jpg`, `cappucino.jpg`
     - Snack Images: `assets/snack/burger.jpg`, `french_fries.jpg`
   - Verify `pubspec.yaml`:
     ```yaml
     flutter:
       assets:
         - assets/logo/
         - assets/asset/
         - assets/animation/
         - assets/payment/
         - assets/food/
         - assets/drink/
         - assets/snack/
     ```

5. **Configure Google Calendar API**:

   - Replace API key in `calendar_service.dart` (`AIzaSyCJubQ43RExEPnbfknWR7KKSQCzzGDeE80`) with a secure key (e.g., environment variable).
   - Verify calendar ID (`id.indonesian#holiday@group.v.calendar.google.com`).

---

## Potential Improvements

1. **Backend Integration**:

   - Replace SharedPreferences with Firebase/Supabase for real-time data synchronization.
   - Implement server-side email notifications via `EmailService`.

2. **Authentication Enhancements**:

   - Add password-based authentication with secure hashing.
   - Support OAuth (e.g., Google Sign-In) and email verification.

3. **Search Improvements**:

   - Implement fuzzy search or server-side search for better performance.
   - Add filters (e.g., price, dietary preferences, ratings).

4. **Order Repository Enhancement**:

   - Expand `order_repository.dart` to centralize order operations, reducing `OrderProvider` redundancy.
   - Integrate with a database for persistent storage.

5. **Seller Dashboard**:

   - Enhance `SellerHomeScreen` with analytics (sales trends, popular items).
   - Add inventory management for products.

6. **UI/UX Enhancements**:

   - Implement dark mode support.
   - Add animations for smoother transitions (e.g., `FoodList`, `OrderCard`).
   - Improve accessibility (screen reader support, larger touch targets).

7. **Testing**:

   - Add unit tests for providers (`OrderProvider`, `CartProvider`, `BalanceProvider`).
   - Implement widget tests for `FoodList`, `PaymentMethodCard`, `OrderCard`.
   - Create integration tests for order placement and tracking workflows.

8. **Error Handling**:

   - Display user-friendly errors for `CalendarService` API failures.
   - Validate inputs more robustly in `NotesField`, `TimePickerWidget`, and `EditProductScreen`.

9. **Code Optimization**:
   - Remove redundant `User` class in `user_model.dart`.
   - Refactor navigation logic in `CustomBottomNavigation` and `SellerCustomBottomNavigation` into a shared utility.
   - Use constants for hardcoded values (e.g., API keys, SharedPreferences keys, asset paths).

---

## Known Issues

1. **Redundant User Class**:

   - `user_model.dart` and `auth_provider.dart` both define a `User` class. The `auth_provider.dart` version is used, making `user_model.dart` obsolete.

2. **Product Model Syntax Error**:

   - `product_model.dart` has a constructor syntax error (`required String ,`, `String: null`). Correct to:
     ```dart
     Product({
       required this.id,
       required this.title,
       required this.subtitle,
       required this.time,
       required this.imgUrl,
       required this.price,
       required this.sellerEmail,
     });
     ```

3. **Hardcoded API Key**:

   - `CalendarService` uses a hardcoded Google Calendar API key, which should be secured (e.g., `.env` file).

4. **Email Backend Missing**:

   - `EmailService` logs notifications to console instead of sending emails. Requires backend integration.

5. **OrderRepository Underutilized**:

   - `order_repository.dart` defines order operations but is not integrated; `OrderProvider` handles most order logic.

6. **Hardcoded Profile Data**:

   - `ProfileScreen` uses a hardcoded name (“Javier Matthew”) instead of `AuthProvider` data.

7. **Navigation Issues**:

   - Frequent use of `pushReplacement` in `WillPopScope` and navigation widgets may disrupt the navigation stack. Consider `push` for non-destructive navigation.

8. **Limited Error Feedback**:

   - Errors in `CalendarService` and JSON parsing in providers are logged without user feedback.

9. **Rating Dialog Restriction**:

   - `RatingDialog` in `order_card.dart` requires both food and app ratings, which may be restrictive for users.

10. **Assumed Files**:
    - Files like `auth_service.dart`, `food_data.dart`, `payment_methods_data.dart`, `search_data.dart`, `balance_provider.dart`, `ratings_provider.dart`, `favorite_screen.dart`, `notification_screen.dart`, `payment_screen.dart`, `payment_success_screen.dart` are referenced but not provided, assumed to exist and function as described.

---

## Conclusion

U-Teen is a robust, well-structured Flutter application for food ordering and seller management at the UMN canteen. The integration of `main.dart`, `food_list.dart`, `notes_field.dart`, `payment_method_card.dart`, `time_picker_widget.dart`, `order_card.dart`, and details from `pubspec.yaml` completes critical functionalities like app initialization, food browsing, order customization, and rating submission. Its modular design, Provider-based state management, and Google Calendar integration provide a strong foundation. However, backend integration, enhanced authentication, comprehensive testing, and fixes for known issues (e.g., redundant classes, hardcoded data) are recommended for production readiness. This merged documentation combines the strengths of both provided versions, offering a clear and comprehensive guide for understanding and extending the application.
