# IOS In App Purchase SDK

In App Purchase custom implementation using Storekit 2 for iOS 15+

## 🛠 Technologies

- **SwiftUI**: The declarative UI framework from Apple.

## 🚀 Getting Started

### Prerequisites
- AppStore Connect access to create Bundle Identifier and App
- **Xcode 15** and later
- iOS  15 or later
- Please make sure that the project bundle ID is the same as the bundle identifier you added while creating the app in AppStore connect.

### Installation
1. In your Xcode project go to File -> Add Package Dependencies then search for this repo and add -

```bash
https://github.com/nathMonisankar/IOS-IAP-store.git
```

2. Import the package

```swift
import IosIapStore

```

3. Add the store view anywhere you want

```swift
    var body: some View {
        RootStoreView(userId: "example@gmail.com", apiKey: "YOUR_API_KEY")
    }
```

4. Now the products must be visible if you have them in **Ready for Submit** state in AppStore connect.

