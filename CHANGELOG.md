
# Changelog

## [v2.0.0] - 2024-12-18
### Added
- Batch processing for multiple Access Points (APs).
- UUID history view and export feature.
- QR code generation for fetched UUIDs.
- AP signal strength visualization during Wi-Fi scanning.
- Customizable SSID filters to scan APs based on user-defined patterns.
- Retry mechanism for failed UUID fetch attempts.
- Enhanced error messages for user-friendly troubleshooting.
- Dark mode support toggle in settings.
- Push notifications for new detected APs with "Juice" in the SSID.

### Changed
- Improved layout for AP list display with signal strength indicators.
- Optimized UUID fetching with additional threading for asynchronous operations.

### Fixed
- Minor bugs in the email sending functionality.
- Prevented duplicate processing of APs in some edge cases.
