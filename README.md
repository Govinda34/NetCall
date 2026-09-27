# Work Time & Billing Manager

Flutter Material 3 offline-first application foundation with SQLite.

## Included
- Work categories, customers, work entries
- Per-minute / per-hour / per-day billing
- Automatic duration and earnings
- Payment status and outstanding amount
- Expenses, employees, attendance-ready schema
- Profiles, invoices, receipts, payments, attachments-ready schema
- Search/filterable master screens
- Dashboard income/expense/profit/outstanding cards
- Reports and CSV export
- PDF export service
- GPS capture service
- Biometric security service
- Local notification service
- JSON backup service
- Light/dark theme

## Run
flutter pub get
flutter run

## Production configuration
Configure Android/iOS permissions for location, notifications, camera/photos and biometrics. Configure Firebase/Google Drive credentials only when cloud sync is enabled. The local database remains the source of truth for offline operation.
