
import SwiftUI
import Toolbox

#if canImport(UIKit)
import UIKit
#endif

public extension Color {
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        #if canImport(UIKit)
        if #available(iOS 14.0, *) {
            guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
                return (0, 0, 0, 0)
            }
        } else {
            let components = self._components()
            let uiColor = UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
            guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &o) else {
                return (0, 0, 0, 0)
            }
        }
        #elseif canImport(AppKit)
        NSColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        #endif
        
        return (Double(r), Double(g), Double(b), Double(o))
    }
    
    static func Lerp(from c1: Color, to c2: Color, progress: Double) -> Color {
        let c1 = c1.components
        let c2 = c2.components
        
        return Color(red: (1.0 - progress) * c1.red + progress * c2.red,
                     green: (1.0 - progress) * c1.green + progress * c2.green,
                     blue: (1.0 - progress) * c1.blue + progress * c2.blue,
                     opacity: 1)
    }
    
    fileprivate func _components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        
        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
    
    fileprivate func adjust(by percentage: Double) -> Color {
        let components = self.components
        return Color(red: min(components.red + percentage, 1.0),
                     green: min(components.green + percentage, 1.0),
                     blue: min(components.blue + percentage, 1.0))
    }
    
    func brightened(by percentage: Double) -> Color {
        adjust(by: abs(percentage))
    }
    
    func darkened(by percentage: Double) -> Color {
        adjust(by: -abs(percentage))
    }
    
    // https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
    var contrastColor: Color {
        let components = self.components
        let luminance = (0.299 * components.red + 0.587 * components.green + 0.114 * components.blue)
        
        return luminance > 0.5 ? .black : .white
    }
    
    func applyOpacity(_ opacity: Double, background: Color = .white) -> Color {
        return merge(with: background, weight: opacity)
    }
    
    func merge(with: Color, weight: Double = 0.5) -> Color {
        let components = self.components
        let other = with.components
        let inv = 1.0 - weight
        
        return Color(red: components.red * weight + other.red * inv,
                     green: components.green * weight + other.green * inv,
                     blue: components.blue * weight + other.blue * inv)
    }
    
    static func random(using rng: inout ARC4RandomNumberGenerator) -> Color {
        Color(red: Double.random(in: 0...1, using: &rng),
              green: Double.random(in: 0...1, using: &rng),
              blue: Double.random(in: 0...1, using: &rng))
    }
    
    static func random() -> Color {
        Color(red: Double.random(in: 0...1),
              green: Double.random(in: 0...1),
              blue: Double.random(in: 0...1))
    }
    
    static func random(seed: UInt64) -> Color {
        var rng = ARC4RandomNumberGenerator(seed: seed)
        return .random(using: &rng)
    }
}

extension Color: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        let components = self.components
        
        try container.encode(components.red)
        try container.encode(components.green)
        try container.encode(components.blue)
        try container.encode(components.opacity)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let red = try container.decode(Double.self)
        let green = try container.decode(Double.self)
        let blue = try container.decode(Double.self)
        let opacity = try container.decode(Double.self)
        
        self = Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}

#if canImport(UIKit)

public extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red: red, green: green, blue: blue, alpha: alpha)
    }
}

public extension UIColor {
    static func random(alpha: UInt8 = 255) -> UIColor {
        .init(red: UInt8.random(in: 0...255),
              green: .random(in: 0...255),
              blue: .random(in: 0...255),
              alpha: alpha)
    }
}

public extension UIColor {
    convenience init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.init(
            red: CGFloat(red)/255,
            green: CGFloat(green)/255,
            blue: CGFloat(blue)/255,
            alpha: CGFloat(alpha)/255)
    }
}

public extension UIColor {
    // https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
    var contrastColor: UIColor {
        let (r, g, b, _) = self.components
        let luminance = (0.299 * r + 0.587 * g + 0.114 * b)
        
        return luminance > 0.5 ? .black : .white
    }
}

#endif
