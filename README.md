# MacAddress

Implements MAC data type for Swift, also known as EUI-48. This code was influenced by [abaumhauer/eui48](https://github.com/abaumhauer/eui48)

## Installation

### Swift Package Manager

Use swift package manager to install `MacAddress` by adding the proper description to your `Package.swift` file:

```swift
// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/haekelmeister/MacAddress.git", from: "1.0.3"),
    ]
)
```
Then run `swift build` to build your applicaton.

## Usage

```swift
import MacAddress

let eui48_1 = MacAddress(withType: .broadcast)

print("eui48 = \(eui48_1.dotFormat)")

if let eui48_2 = MacAddress(fromString: "0x123456ABCDEF") {
    print("eui48 = \(eui48_2)")
}
```

## References

* [Wikipedia: MAC address](https://en.wikipedia.org/wiki/MAC_address)
