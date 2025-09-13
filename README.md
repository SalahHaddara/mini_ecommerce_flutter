# Mini Ecommerce Flutter App

A Flutter e-commerce app with user and admin functionality, built with Material 3, Provider, and clean architecture.

## Features

### User

* Authentication (register/login)
* Product catalog & details
* Shopping cart with totals & tax
* Order placement & history
* Responsive UI with loading/error states

### Admin

* Add & manage products
* View/manage all orders
* Low stock monitoring (<5 items)
* Dashboard with tabbed navigation

## Tech Stack

* **Flutter** (null-safe Dart)
* **Provider** (state management)
* **HTTP** (API communication)
* **SharedPreferences** (token persistence)
* **form\_validator**, **shimmer**, **pull\_to\_refresh**

## Setup

1. Clone repo & install deps

   ```bash
   git clone
   cd mini_ecommerce
   flutter pub get
   ```
2. Update API URL in `lib/constants/api_constants.dart`
3. Run the app:

   ```bash
   flutter run
   ```

## Testing

```bash
flutter test
```

## Future Improvements

* Offline support & sync
* Image upload for products
* Push notifications
* Search & filters
* Dark mode & i18n
