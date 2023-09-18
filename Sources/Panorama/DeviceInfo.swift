
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(IOKit)
import IOKit
#endif

import SwiftUI

/// This enumeration contains all released iPod and iPhone models.
public enum DeviceModel: String, CaseIterable {
    case iPodTouch5 = "iPod touch (5th generation)",
         iPodTouch6 = "iPod touch (6th generation)",
         iPodTouch7 = "iPod touch (7th generation)"
    
    case iPhone4 = "iPhone 4",
         iPhone4s = "iPhone 4s",
         iPhone5 = "iPhone 5",
         iPhone5c = "iPhone 5c",
         iPhone5s = "iPhone 5s",
         iPhone6 = "iPhone 6",
         iPhone6Plus = "iPhone 6 Plus",
         iPhone6s = "iPhone 6s",
         iPhone6sPlus = "iPhone 6s Plus",
         iPhoneSE = "iPhone SE (1st generation)",
         iPhone7 = "iPhone 7",
         iPhone7Plus = "iPhone 7 Plus",
         iPhone8 = "iPhone 8",
         iPhone8Plus = "iPhone 8 Plus",
         iPhoneX = "iPhone X",
         iPhoneXS = "iPhone XS",
         iPhoneXSMax = "iPhone XS Max",
         iPhoneXR = "iPhone XR",
         iPhone11 = "iPhone 11",
         iPhone11Pro = "iPhone 11 Pro",
         iPhone11ProMax = "iPhone 11 Pro Max",
         iPhoneSE2 = "iPhone SE (2nd generation)",
         iPhone12mini = "iPhone 12 mini",
         iPhone12 = "iPhone 12",
         iPhone12Pro = "iPhone 12 Pro",
         iPhone12ProMax = "iPhone 12 Pro Max",
         iPhone13mini = "iPhone 13 mini",
         iPhone13 = "iPhone 13",
         iPhone13Pro = "iPhone 13 Pro",
         iPhone13ProMax = "iPhone 13 Pro Max",
         iPhoneSE3 = "iPhone SE (3rd generation)",
         iPhone14 = "iPhone 14",
         iPhone14Plus = "iPhone 14 Plus",
         iPhone14Pro = "iPhone 14 Pro",
         iPhone14ProMax = "iPhone 14 Pro Max",
         iPhone15 = "iPhone 15",
         iPhone15Plus = "iPhone 15 Plus",
         iPhone15Pro = "iPhone 15 Pro",
         iPhone15ProMax = "iPhone 15 Pro Max"
    
    case simulator = "Simulator"
    case other = "Other"
}

/// This enumeration covers all screen types that have been present in released iPods and iPhones.
public enum ScreenType: String, RawRepresentable, CaseIterable {
    case iPhone4 = "iPhone 4"
    case iPhone5 = "iPhone 5"
    case iPhone6 = "iPhone 6"
    case iPhone6Plus = "iPhone 6 Plus"
    case iPhone8Plus = "iPhone 8 Plus" // The 8 Plus has a different logical size than the 6 Plus
    case iPhoneX = "iPhone X"
    case iPhoneXSMax = "iPhone XS Max"
    case iPhoneXR = "iPhone XR"
    case iPhone12mini = "iPhone 12 mini"
    case iPhone12 = "iPhone 12"
    case iPhone12ProMax = "iPhone 12 Pro Max"
    case iPhone14Pro = "iPhone 14 Pro"
    case iPhone14ProMax = "iPhone 14 Pro Max"
    case other = "Other"
    
    /// Whether or not this screen type is an iPhone 5 or smaller.
    var iPhone5OrSmaller: Bool {
        switch self {
        case .iPhone4:
            fallthrough
        case .iPhone5:
            return true
        default:
            return false
        }
    }
}

/// - Returns: A unique identifier for the current model of Mac.
public func getMacModelIdentifier() -> String? {
    #if canImport(IOKit)
    // https://stackoverflow.com/a/50008492/7564976
    let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                              IOServiceMatching("IOPlatformExpertDevice"))
    
    var modelIdentifier: String? = nil
    if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
        modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
    }
    
    IOObjectRelease(service)
    return modelIdentifier
    #else
    return nil
    #endif
}

#if canImport(UIKit)
public extension UIDevice {
    static var uuidString: String? {
        current.identifierForVendor?.uuidString
    }
    
    /// The unique device model identifier, e.g. `iPhone13,1` for the iPhone 12 mini.
    static var deviceIdentifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }()
    
    /// An estimate for the device of the current simulator based on its screen dimensions.
    static func simulatorDeviceModel() -> DeviceModel {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let screenScale = UIScreen.main.scale
        
        for screenType in ScreenType.allCases {
            guard let (width, height) = screenType.logicalSize else {
                continue
            }
            
            guard let scalingFactor = screenType.scalingFactor else {
                continue
            }
            
            if width.isEqual(to: screenWidth) && height.isEqual(to: screenHeight) && scalingFactor.isEqual(to: screenScale)  {
                for model in DeviceModel.allCases {
                    if model.screenType == screenType {
                        return model
                    }
                }
            }
        }
        
        return .simulator
    }
    
    /// The device model defined by a model identifier.
    static func deviceModel(for identifier: String) -> DeviceModel { // swiftlint:disable:this cyclomatic_complexity
        switch identifier {
        case "iPod5,1":                                 return .iPodTouch5
        case "iPod7,1":                                 return .iPodTouch6
        case "iPod9,1":                                 return .iPodTouch7
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return .iPhone4
        case "iPhone4,1":                               return .iPhone4s
        case "iPhone5,1", "iPhone5,2":                  return .iPhone5
        case "iPhone5,3", "iPhone5,4":                  return .iPhone5c
        case "iPhone6,1", "iPhone6,2":                  return .iPhone5s
        case "iPhone7,2":                               return .iPhone6
        case "iPhone7,1":                               return .iPhone6Plus
        case "iPhone8,1":                               return .iPhone6s
        case "iPhone8,2":                               return .iPhone6sPlus
        case "iPhone8,4":                               return .iPhoneSE
        case "iPhone9,1", "iPhone9,3":                  return .iPhone7
        case "iPhone9,2", "iPhone9,4":                  return .iPhone7Plus
        case "iPhone10,1", "iPhone10,4":                return .iPhone8
        case "iPhone10,2", "iPhone10,5":                return .iPhone8Plus
        case "iPhone10,3", "iPhone10,6":                return .iPhoneX
        case "iPhone11,2":                              return .iPhoneXS
        case "iPhone11,4", "iPhone11,6":                return .iPhoneXSMax
        case "iPhone11,8":                              return .iPhoneXR
        case "iPhone12,1":                              return .iPhone11
        case "iPhone12,3":                              return .iPhone11Pro
        case "iPhone12,5":                              return .iPhone11ProMax
        case "iPhone12,8":                              return .iPhoneSE2
        case "iPhone13,1":                              return .iPhone12mini
        case "iPhone13,2":                              return .iPhone12
        case "iPhone13,3":                              return .iPhone12Pro
        case "iPhone13,4":                              return .iPhone12ProMax
        case "iPhone14,4":                              return .iPhone13mini
        case "iPhone14,5":                              return .iPhone13
        case "iPhone14,2":                              return .iPhone13Pro
        case "iPhone14,3":                              return .iPhone13ProMax
        case "iPhone14,6":                              return .iPhoneSE3
        case "iPhone14,7", "iPhone14,1":                return .iPhone14
        case "iPhone14,8", "iPhone14,9":                return .iPhone14Plus
        case "iPhone15,2":                              return .iPhone14Pro
        case "iPhone15,3":                              return .iPhone14ProMax
        case "iPhone15,4":                              return .iPhone15
        case "iPhone15,5":                              return .iPhone15Plus
        case "iPhone16,1":                              return .iPhone15Pro
        case "iPhone16,2":                              return .iPhone15ProMax
        case "i386", "x86_64", "arm64":                 return Self.simulatorDeviceModel()
        default:                                        return .other
        }
    }
    
    static let model: DeviceModel = deviceModel(for: deviceIdentifier)
    static let screenType = model.screenType
}
#endif

public extension DeviceModel {
    /// Whether or not this device has a home button.
    var hasHomeButton: Bool {
        switch self {
        case .iPodTouch5:
            fallthrough
        case .iPodTouch6:
            fallthrough
        case .iPodTouch7:
            fallthrough
        case .iPhone4:
            fallthrough
        case .iPhone4s:
            fallthrough
        case .iPhone5:
            fallthrough
        case .iPhone5s:
            fallthrough
        case .iPhone5c:
            fallthrough
        case .iPhone6:
            fallthrough
        case .iPhone6Plus:
            fallthrough
        case .iPhone6s:
            fallthrough
        case .iPhone6sPlus:
            fallthrough
        case .iPhoneSE:
            fallthrough
        case .iPhone7:
            fallthrough
        case .iPhone7Plus:
            fallthrough
        case .iPhone8:
            fallthrough
        case .iPhone8Plus:
            fallthrough
        case .iPhoneSE2:
            fallthrough
        case .iPhoneSE3:
            return true
        default:
            return false
        }
    }
    
    /// Whether or not this device supports haptics.
    var supportsHaptics: Bool {
        switch self {
        case .iPodTouch5:
            fallthrough
        case .iPodTouch6:
            fallthrough
        case .iPodTouch7:
            fallthrough
        case .iPhone4:
            fallthrough
        case .iPhone4s:
            fallthrough
        case .iPhone5:
            fallthrough
        case .iPhone5c:
            fallthrough
        case .iPhone5s:
            fallthrough
        case .iPhone6:
            fallthrough
        case .iPhone6Plus:
            fallthrough
        case .iPhone6s:
            fallthrough
        case .iPhone6sPlus:
            fallthrough
        case .iPhoneSE:
            fallthrough
        case .simulator:
            fallthrough
        case .other:
            return false
        default:
            return true
        }
    }
    
    /// Whether or not this device supports ProMotion (a dynamic refresh rate up to 120Hz).
    var supportsProMotion: Bool {
        switch self {
        case .iPhone13Pro:
            fallthrough
        case .iPhone13ProMax:
            fallthrough
        case .iPhone14Pro:
            fallthrough
        case .iPhone14ProMax:
            fallthrough
        case .iPhone15Pro:
            fallthrough
        case .iPhone15ProMax:
            return true
        default:
            return false
        }
    }
    
    /// Whether or not this device has limited processing power.
    var hasLimitedPerformance: Bool {
        switch self {
        case .iPodTouch5:
            fallthrough
        case .iPodTouch6:
            fallthrough
        case .iPodTouch7:
            fallthrough
        case .iPhone4:
            fallthrough
        case .iPhone4s:
            fallthrough
        case .iPhone5:
            fallthrough
        case .iPhone5s:
            fallthrough
        case .iPhone5c:
            fallthrough
        case .iPhone6:
            fallthrough
        case .iPhone6Plus:
            fallthrough
        case .iPhone6s:
            fallthrough
        case .iPhone6sPlus:
            fallthrough
        case .iPhoneSE:
            return true
        default:
            return false
        }
    }
    
    /// Whether or not this is an 'old' iPhone.
    var isOldDevice: Bool {
        switch self {
        case .iPodTouch5:
            fallthrough
        case .iPodTouch6:
            fallthrough
        case .iPodTouch7:
            fallthrough
        case .iPhone4:
            fallthrough
        case .iPhone4s:
            fallthrough
        case .iPhone5:
            fallthrough
        case .iPhone5s:
            fallthrough
        case .iPhone5c:
            fallthrough
        case .iPhone6:
            fallthrough
        case .iPhone6Plus:
            fallthrough
        case .iPhoneSE:
            return true
        default:
            return false
        }
    }
    
    /// Whether or not this is an expensive phone.
    var isExpensiveDevice: Bool {
        rawValue.contains("Pro")
    }
    
    
    /// The screen type of this device.
    var screenType: ScreenType {
        switch self {
        case .iPhone4:
            fallthrough
        case .iPhone4s:
            return .iPhone4
        case .iPodTouch5:
            fallthrough
        case .iPodTouch6:
            fallthrough
        case .iPodTouch7:
            fallthrough
        case .iPhone5:
            fallthrough
        case .iPhone5s:
            fallthrough
        case .iPhone5c:
            fallthrough
        case .iPhoneSE:
            return .iPhone5
        case .iPhone6:
            fallthrough
        case .iPhone6s:
            fallthrough
        case .iPhone7:
            fallthrough
        case .iPhone8:
            fallthrough
        case .iPhoneSE2:
            fallthrough
        case .iPhoneSE3:
            return .iPhone6
        case .iPhone6Plus:
            fallthrough
        case .iPhone6sPlus:
            fallthrough
        case .iPhone7Plus:
            return .iPhone6Plus
        case .iPhone8Plus:
            return .iPhone8Plus
        case .iPhoneX:
            fallthrough
        case .iPhoneXS:
            fallthrough
        case .iPhone11Pro:
            return .iPhoneX
        case .iPhoneXSMax:
            fallthrough
        case .iPhone11ProMax:
            return .iPhoneXSMax
        case .iPhoneXR:
            fallthrough
        case .iPhone11:
            return .iPhoneXR
        case .iPhone12mini:
            fallthrough
        case .iPhone13mini:
            return .iPhone12mini
        case .iPhone12:
            fallthrough
        case .iPhone12Pro:
            fallthrough
        case .iPhone13:
            fallthrough
        case .iPhone13Pro:
            fallthrough
        case .iPhone14:
            return .iPhone12
        case .iPhone14Pro:
            fallthrough
        case .iPhone15:
            fallthrough
        case .iPhone15Pro:
            return .iPhone14Pro
        case .iPhone12ProMax:
            fallthrough
        case .iPhone13ProMax:
            fallthrough
        case .iPhone14Plus:
            return .iPhone12ProMax
        case .iPhone14ProMax:
            fallthrough
        case .iPhone15Plus:
            fallthrough
        case .iPhone15ProMax:
            return .iPhone14ProMax
        case .simulator:
            fallthrough
        case .other:
            return .other
        }
    }
    
    /// Whether this device has an OLED screen.
    var hasSuperRetinaDisplay: Bool {
        self.screenType.scalingFactor?.isEqual(to: 3) ?? false
    }
    
    /// Whether or not this device has a small screen.
    var hasSmallScreen: Bool {
        if case .simulator = self {
#if canImport(UIKit)
            return UIScreen.main.bounds.width.isEqual(to: 320)
#elseif canImport(AppKit)
            return NSScreen.main?.frame.width.isEqual(to: 320) ?? false
#endif
        }
        
        switch self.screenType {
        case .iPhone4:
            fallthrough
        case .iPhone5:
            return true
        default:
            return false
        }
    }
    
    /// The approximate corner radius of the device's screen.
    var screenCornerRadius: CGFloat {
        self.screenType.cornerRadius
    }
}

public extension ScreenType {
    /// The approximate corner radius of the device's screen.
    var cornerRadius: CGFloat {
        // https://kylebashour.com/posts/finding-the-real-iphone-x-corner-radius
        switch self {
        case .iPhoneX:
            fallthrough
        case .iPhoneXSMax:
            return 39.0
        case .iPhoneXR:
            return 41.5
        case .iPhone12mini:
            return 43.0
        case .iPhone12:
            return 47.33
        case .iPhone12ProMax:
            return 53.33
        case .iPhone14Pro:
            return 55
        case .iPhone14ProMax:
            return 55
        case .iPhone4:
            fallthrough
        case .iPhone5:
            fallthrough
        case .iPhone6:
            fallthrough
        case .iPhone6Plus:
            fallthrough
        case .iPhone8Plus:
            fallthrough
        case .other:
            return 0
        }
    }
    
    /// The point dimensions of this screen.
    /// https://www.ios-resolution.com
    var logicalSize: (width: CGFloat, height: CGFloat)? {
        switch self {
        case .iPhone4:
            return (width: 320, height: 480)
        case .iPhone5:
            return (width: 320, height: 568)
        case .iPhone6:
            return (width: 375, height: 667)
        case .iPhone6Plus:
            return (width: 476, height: 847)
        case .iPhone8Plus:
            return (width: 414, height: 736)
        case .iPhoneX:
            return (width: 375, height: 812)
        case .iPhoneXSMax:
            return (width: 414, height: 896)
        case .iPhoneXR:
            return (width: 414, height: 896)
        case .iPhone12mini:
            return (width: 375, height: 812)
        case .iPhone12:
            return (width: 390, height: 844)
        case .iPhone12ProMax:
            return (width: 428, height: 926)
        case .iPhone14Pro:
            return (width: 393, height: 852)
        case .iPhone14ProMax:
            return (width: 430, height: 932)
        case .other:
            return nil
        }
    }
    
    /// The scaling factor associated with this screen.
    var scalingFactor: CGFloat? {
        switch self {
        case .iPhone4:
            return 2
        case .iPhone5:
            return 2
        case .iPhone6:
            return 2
        case .iPhone6Plus:
            return 3
        case .iPhone8Plus:
            return 3
        case .iPhoneX:
            return 3
        case .iPhoneXSMax:
            return 3
        case .iPhoneXR:
            return 2
        case .iPhone12mini:
            return 3
        case .iPhone12:
            return 3
        case .iPhone12ProMax:
            return 3
        case .iPhone14Pro:
            return 3
        case .iPhone14ProMax:
            return 3
        case .other:
            return nil
        }
    }
    
    /// The safe area insets per device in points.
    var safeAreaInsets: EdgeInsets {
        switch self {
        case .iPhoneX:
            return EdgeInsets(top: 44, leading: 0, bottom: 34, trailing: 0)
        case .iPhoneXSMax:
            return EdgeInsets(top: 44, leading: 0, bottom: 34, trailing: 0)
        case .iPhoneXR:
            return EdgeInsets(top: 48, leading: 0, bottom: 34, trailing: 0)
        case .iPhone12mini:
            return EdgeInsets(top: 50, leading: 0, bottom: 34, trailing: 0)
        case .iPhone12:
            return EdgeInsets(top: 47, leading: 0, bottom: 34, trailing: 0)
        case .iPhone12ProMax:
            return EdgeInsets(top: 47, leading: 0, bottom: 34, trailing: 0)
        case .iPhone14Pro:
            return EdgeInsets(top: 59, leading: 0, bottom: 34, trailing: 0)
        case .iPhone14ProMax:
            return EdgeInsets(top: 59, leading: 0, bottom: 34, trailing: 0)
        case .iPhone4:
            fallthrough
        case .iPhone5:
            fallthrough
        case .iPhone6:
            fallthrough
        case .iPhone6Plus:
            fallthrough
        case .iPhone8Plus:
            fallthrough
        case .other:
            return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
    }
}

/// The current full iOS version string with major, minor, and patch versions, e.g. `16.2.1`.
public func getiOSVersionString() -> String {
    let os = ProcessInfo.processInfo.operatingSystemVersion
    return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
}

/// Whether or not iOS 16 is available.
public var iOS16Available: Bool {
    if #available(iOS 16, *) {
        return true
    }
    
    return false
}

#if DEBUG
/// True iff the App is running in an Xcode preview window.
public var isRunningInXcodePreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
#else
/// True iff the App is running in an Xcode preview window.
public let isRunningInXcodePreview: Bool = false
#endif

#if canImport(UIKit)

/// Scale a value relative to the screen height, using the iPhone mini 5.4" screen as a base.
public func scaleByScreenHeight(_ value: Double) -> Double {
    guard let baselineHeight = ScreenType.iPhone12mini.logicalSize?.height else {
        return value
    }
    
    return Double(UIScreen.main.bounds.height / baselineHeight) * value
}

/// Scale a value relative to the screen height, using the iPhone mini 5.4" screen as a base.
public func scaleByScreenWidth(_ value: Double) -> Double {
    guard let baselineWidth = ScreenType.iPhone12mini.logicalSize?.width else {
        return value
    }
    
    return Double(UIScreen.main.bounds.width / baselineWidth) * value
}

#if DEBUG

extension UIScreen {
    private static let cornerRadiusKey: String = {
        let components = ["Radius", "Corner", "display", "_"]
        return components.reversed().joined()
    }()
    
    /// The corner radius of the display. Uses a private property of `UIScreen`,
    /// and may report 0 if the API changes.
    public var displayCornerRadiusComputed: CGFloat {
        guard let cornerRadius = self.value(forKey: Self.cornerRadiusKey) as? CGFloat else {
            return 0
        }
        
        return cornerRadius
    }
}

#endif
#endif
