# Flight Planner

A comprehensive flight planning application for flight simulators with SimBrief integration.

## Features

- **Flight Management**: Create, edit, and manage flight plans with all essential details
- **Aircraft Database**: Store and search aircraft information
- **Airline Database**: Manage airline profiles
- **Airport Search**: Quick search for departure, arrival, and alternate airports
- **SimBrief Integration**: 
  - Login with your SimBrief account
  - Import flight plans from SimBrief
  - Sync local flights to SimBrief
  - Access OFP (Operational Flight Plan) data
  - View navigation logs
- **Offline Support**: All data is stored locally and syncs when online
- **Search & Filter**: Easily find flights by number, airline, aircraft, or route

## Flight Information

Each flight can include:
- Flight number
- Airline
- Aircraft type and registration
- Departure and arrival airports
- Alternate airport
- Route description
- Cruise altitude and speed
- Departure and arrival times
- Fuel required
- Payload
- Pilot ID
- SimBrief OFP ID

## SimBrief Integration

To use SimBrief features:
1. Create an account at [https://www.simbrief.com](https://www.simbrief.com)
2. Login in the app using your SimBrief credentials
3. Import existing flight plans or create new ones
4. Sync your local flights to SimBrief for backup

## Installation

### From GitHub Releases
Download the latest APK from the [Releases](https://github.com/N9Tech/Flight-Planner/releases) page.

### Building from Source

```bash
# Clone the repository
git clone https://github.com/N9Tech/Flight-Planner.git
cd Flight-Planner

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

## Requirements

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android SDK 24+ (for building)

## Screenshots

![Home Screen](https://via.placeholder.com/400x800?text=Home+Screen)
![Flight List](https://via.placeholder.com/400x800?text=Flight+List)
![Add Flight](https://via.placeholder.com/400x800?text=Add+Flight)
![SimBrief Login](https://via.placeholder.com/400x800?text=SimBrief+Login)

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or support, please open an issue on GitHub.

---

**Flight Planner** - Your companion for virtual aviation
