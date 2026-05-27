import Foundation
import UIKit
import Darwin

// MARK: - Device Identifier

final class DeviceIdentifier {
    static let shared = DeviceIdentifier()
    private init() {}
    
    var hwMachine: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "unknown"
            }
        }
    }
    
    var modelName: String {
        deviceDatabase[hwMachine]?.name ?? UIDevice.current.model
    }
    
    var screenPoints: CGSize {
        let id = hwMachine
        if let info = deviceDatabase[id] {
            return CGSize(width: info.screenWidth, height: info.screenHeight)
        }
        let screen = UIScreen.main.bounds.size
        return screen
    }
    
    var cornerRadius: CGFloat {
        deviceDatabase[hwMachine]?.cornerRadius ?? 39
    }
    
    var displayFeature: DisplayFeature {
        deviceDatabase[hwMachine]?.feature ?? .notch
    }
    
    var dynamicIslandWidth: CGFloat {
        deviceDatabase[hwMachine]?.dynamicIslandWidth ?? 52
    }
    
    var scale: Int {
        deviceDatabase[hwMachine]?.scale ?? Int(UIScreen.main.scale)
    }
}

// MARK: - Display Feature

enum DisplayFeature: String {
    case homeButton     = "homeButton"
    case notch          = "notch"
    case dynamicIsland  = "dynamicIsland"
}

// MARK: - Device Info Model

struct DeviceInfo {
    let name: String
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let scale: Int
    let cornerRadius: CGFloat
    let feature: DisplayFeature
    let dynamicIslandWidth: CGFloat
    let bezelMm: CGFloat
    let year: Int
}

// MARK: - Device Database

let deviceDatabase: [String: DeviceInfo] = [
    // iPhone 17 series
    "iPhone18,2": DeviceInfo(name: "iPhone 17 Pro Max", screenWidth: 440, screenHeight: 956, scale: 3, cornerRadius: 62, feature: .dynamicIsland, dynamicIslandWidth: 62, bezelMm: 1.36, year: 2025),
    "iPhone18,1": DeviceInfo(name: "iPhone 17 Pro", screenWidth: 402, screenHeight: 874, scale: 3, cornerRadius: 62, feature: .dynamicIsland, dynamicIslandWidth: 52, bezelMm: 1.44, year: 2025),
    "iPhone18,3": DeviceInfo(name: "iPhone 17", screenWidth: 402, screenHeight: 874, scale: 3, cornerRadius: 62, feature: .dynamicIsland, dynamicIslandWidth: 52, bezelMm: 1.8, year: 2025),
    "iPhone18,4": DeviceInfo(name: "iPhone Air", screenWidth: 420, screenHeight: 912, scale: 3, cornerRadius: 62, feature: .dynamicIsland, dynamicIslandWidth: 52, bezelMm: 1.6, year: 2025),
    
    // iPhone 16 series
    "iPhone17,2": DeviceInfo(name: "iPhone 16 Pro Max", screenWidth: 440, screenHeight: 956, scale: 3, cornerRadius: 62, feature: .dynamicIsland, dynamicIslandWidth: 62, bezelMm: 1.36, year: 2024),
    "iPhone17,1": DeviceInfo(name: "iPhone 16 Pro", screenWidth: 402, screenHeight: 874, scale: 3, cornerRadius: 62, feature: .dynamicIsland, dynamicIslandWidth: 52, bezelMm: 1.44, year: 2024),
    "iPhone17,4": DeviceInfo(name: "iPhone 16 Plus", screenWidth: 430, screenHeight: 932, scale: 3, cornerRadius: 55, feature: .dynamicIsland, dynamicIslandWidth: 52, bezelMm: 2.275, year: 2024),
    "iPhone17,3": DeviceInfo(name: "iPhone 16", screenWidth: 393, screenHeight: 852, scale: 3, cornerRadius: 55, feature: .dynamicIsland, dynamicIslandWidth: 52, bezelMm: 2.275, year: 2024),
    
    // iPhone 15 series
    "iPhone16,2": DeviceInfo(name: "iPhone 15 Pro Max", screenWidth: 430, screenHeight: 932, scale: 3, cornerRadius: 55, feature: .dynamicIsland, dynamicIslandWidth: 62, bezelMm: 1.55, year: 2023),
    "iPhone16,1": DeviceInfo(name: "iPhone 15 Pro", screenWidth: 393, screenHeight: 852, scale: 3, cornerRadius: 55, feature: .dynamicIsland, dynamicIslandWidth: 52, bezelMm: 1.55, year: 2023),
    "iPhone15,5": DeviceInfo(name: "iPhone 15 Plus", screenWidth: 430, screenHeight: 932, scale: 3, cornerRadius: 55, feature: .dynamicIsland, dynamicIslandWidth: 52, bezelMm: 2.2, year: 2023),
    "iPhone15,4": DeviceInfo(name: "iPhone 15", screenWidth: 393, screenHeight: 852, scale: 3, cornerRadius: 55, feature: .dynamicIsland, dynamicIslandWidth: 52, bezelMm: 2.2, year: 2023),
    
    // iPhone 14 series
    "iPhone15,3": DeviceInfo(name: "iPhone 14 Pro Max", screenWidth: 430, screenHeight: 932, scale: 3, cornerRadius: 55, feature: .dynamicIsland, dynamicIslandWidth: 62, bezelMm: 1.95, year: 2022),
    "iPhone15,2": DeviceInfo(name: "iPhone 14 Pro", screenWidth: 393, screenHeight: 852, scale: 3, cornerRadius: 55, feature: .dynamicIsland, dynamicIslandWidth: 52, bezelMm: 1.95, year: 2022),
    "iPhone14,8": DeviceInfo(name: "iPhone 14 Plus", screenWidth: 428, screenHeight: 926, scale: 3, cornerRadius: 53.33, feature: .notch, dynamicIslandWidth: 0, bezelMm: 2.2, year: 2022),
    "iPhone14,7": DeviceInfo(name: "iPhone 14", screenWidth: 390, screenHeight: 844, scale: 3, cornerRadius: 47.33, feature: .notch, dynamicIslandWidth: 0, bezelMm: 2.2, year: 2022),
    
    // iPhone 13 series
    "iPhone14,3": DeviceInfo(name: "iPhone 13 Pro Max", screenWidth: 428, screenHeight: 926, scale: 3, cornerRadius: 53.33, feature: .notch, dynamicIslandWidth: 0, bezelMm: 2.4, year: 2021),
    "iPhone14,2": DeviceInfo(name: "iPhone 13 Pro", screenWidth: 390, screenHeight: 844, scale: 3, cornerRadius: 47.33, feature: .notch, dynamicIslandWidth: 0, bezelMm: 2.4, year: 2021),
    "iPhone14,5": DeviceInfo(name: "iPhone 13", screenWidth: 390, screenHeight: 844, scale: 3, cornerRadius: 47.33, feature: .notch, dynamicIslandWidth: 0, bezelMm: 2.4, year: 2021),
    "iPhone14,4": DeviceInfo(name: "iPhone 13 mini", screenWidth: 375, screenHeight: 812, scale: 3, cornerRadius: 44, feature: .notch, dynamicIslandWidth: 0, bezelMm: 2.4, year: 2021),
    
    // iPhone 12 series
    "iPhone13,4": DeviceInfo(name: "iPhone 12 Pro Max", screenWidth: 428, screenHeight: 926, scale: 3, cornerRadius: 53.33, feature: .notch, dynamicIslandWidth: 0, bezelMm: 2.8, year: 2020),
    "iPhone13,3": DeviceInfo(name: "iPhone 12 Pro", screenWidth: 390, screenHeight: 844, scale: 3, cornerRadius: 47.33, feature: .notch, dynamicIslandWidth: 0, bezelMm: 2.8, year: 2020),
    "iPhone13,2": DeviceInfo(name: "iPhone 12", screenWidth: 390, screenHeight: 844, scale: 3, cornerRadius: 47.33, feature: .notch, dynamicIslandWidth: 0, bezelMm: 2.8, year: 2020),
    "iPhone13,1": DeviceInfo(name: "iPhone 12 mini", screenWidth: 375, screenHeight: 812, scale: 3, cornerRadius: 44, feature: .notch, dynamicIslandWidth: 0, bezelMm: 2.8, year: 2020),
    
    // iPhone 11 series
    "iPhone12,5": DeviceInfo(name: "iPhone 11 Pro Max", screenWidth: 414, screenHeight: 896, scale: 3, cornerRadius: 39, feature: .notch, dynamicIslandWidth: 0, bezelMm: 3.5, year: 2019),
    "iPhone12,3": DeviceInfo(name: "iPhone 11 Pro", screenWidth: 375, screenHeight: 812, scale: 3, cornerRadius: 39, feature: .notch, dynamicIslandWidth: 0, bezelMm: 3.5, year: 2019),
    "iPhone12,1": DeviceInfo(name: "iPhone 11", screenWidth: 414, screenHeight: 896, scale: 2, cornerRadius: 41.5, feature: .notch, dynamicIslandWidth: 0, bezelMm: 3.5, year: 2019),
    
    // iPhone X / XS / XR
    "iPhone11,4": DeviceInfo(name: "iPhone XS Max", screenWidth: 414, screenHeight: 896, scale: 3, cornerRadius: 39, feature: .notch, dynamicIslandWidth: 0, bezelMm: 3.8, year: 2018),
    "iPhone11,2": DeviceInfo(name: "iPhone XS", screenWidth: 375, screenHeight: 812, scale: 3, cornerRadius: 39, feature: .notch, dynamicIslandWidth: 0, bezelMm: 3.8, year: 2018),
    "iPhone11,8": DeviceInfo(name: "iPhone XR", screenWidth: 414, screenHeight: 896, scale: 2, cornerRadius: 41.5, feature: .notch, dynamicIslandWidth: 0, bezelMm: 3.8, year: 2018),
    "iPhone10,6": DeviceInfo(name: "iPhone X", screenWidth: 375, screenHeight: 812, scale: 3, cornerRadius: 39, feature: .notch, dynamicIslandWidth: 0, bezelMm: 4.0, year: 2017),
    
    // Classic (Home Button)
    "iPhone10,1": DeviceInfo(name: "iPhone 8", screenWidth: 375, screenHeight: 667, scale: 2, cornerRadius: 0, feature: .homeButton, dynamicIslandWidth: 0, bezelMm: 5.0, year: 2017),
    "iPhone9,1":  DeviceInfo(name: "iPhone 7", screenWidth: 375, screenHeight: 667, scale: 2, cornerRadius: 0, feature: .homeButton, dynamicIslandWidth: 0, bezelMm: 5.0, year: 2016),
    "iPhone8,1":  DeviceInfo(name: "iPhone 6s", screenWidth: 375, screenHeight: 667, scale: 2, cornerRadius: 0, feature: .homeButton, dynamicIslandWidth: 0, bezelMm: 5.0, year: 2015),
]
