
import SwiftUI
import Toolbox

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
/// Add static UIColors to Color.
public extension Color {
    /// The base gray color.
    static let systemGray: Color = Color(uiColor: .systemGray)
    
    /// Slightly lighter than systemGray in light mode, slightly darker in dark mode.
    static let systemGray2: Color = Color(uiColor: .systemGray2)
    
    /// Slightly lighter than systemGray2 in light mode, slightly darker in dark mode.
    static let systemGray3: Color = Color(uiColor: .systemGray3)
    
    /// Slightly lighter than systemGray3 in light mode, slightly darker in dark mode.
    static let systemGray4: Color = Color(uiColor: .systemGray4)
    
    /// Slightly lighter than systemGray4 in light mode, slightly darker in dark mode.
    static let systemGray5: Color = Color(uiColor: .systemGray5)
    
    /// Slightly lighter than systemGray5 in light mode, slightly darker in dark mode.
    static let systemGray6: Color = Color(uiColor: .systemGray6)
    
    /// This color represents the tint color of a view.
    ///
    /// Like other dynamic colors, UIColor.tintColor relies on UITraitCollection.currentTraitCollection
    /// being set to a view's trait collection when it is used, so that it can resolve to that view's
    /// tint color. If you use UIColor.tintColor outside a view's context, and do not resolve it
    /// manually with a view's trait collection, it will return the system default tint color.
    ///
    /// Setting UIColor.tintColor directly to a view's tintColor property behaves the same as setting nil.
    /// However, you cannot set a custom dynamic color (e.g. using +[UIColor colorWithDynamicProvider:])
    /// that can resolve to UIColor.tintColor to a view's tintColor property.
    static let tintColor: Color = Color(uiColor: .tintColor)
    
    /// Foreground colors for static text and related elements.
    static let label: Color = Color(uiColor: .label)
    
    /// Foreground colors for static text and related elements.
    static let secondaryLabel: Color = Color(uiColor: .secondaryLabel)
    
    /// Foreground colors for static text and related elements.
    static let tertiaryLabel: Color = Color(uiColor: .tertiaryLabel)
    
    /// Foreground colors for static text and related elements.
    static let quaternaryLabel: Color = Color(uiColor: .quaternaryLabel)
    
    /// Foreground color for standard system links.
    static let link: Color = Color(uiColor: .link)
    
    
    /// Foreground color for placeholder text in controls or text fields or text views.
    static let placeholderText: Color = Color(uiColor: .placeholderText)
    
    
    /// Foreground colors for separators (thin border or divider lines).
    ///
    /// `separatorColor` may be partially transparent, so it can go on top of any content.
    static let separator: Color = Color(uiColor: .separator)
    
    /// Foreground colors for separators (thin border or divider lines).
    ///
    /// `opaqueSeparatorColor` is intended to look similar, but is guaranteed to be opaque, so it will
    /// completely cover anything behind it. Depending on the situation, you may need one or the other.
    static let opaqueSeparator: Color = Color(uiColor: .opaqueSeparator)
    
    /// We provide two design systems (also known as "stacks") for structuring an iOS app's backgrounds.
    ///
    /// Each stack has three "levels" of background colors. The first color is intended to be the
    /// main background, farthest back. Secondary and tertiary colors are layered on top
    /// of the main background, when appropriate.
    ///
    /// Inside of a discrete piece of UI, choose a stack, then use colors from that stack.
    /// We do not recommend mixing and matching background colors between stacks.
    /// The foreground colors above are designed to work in both stacks.
    ///
    /// 1. systemBackground
    ///    Use this stack for views with standard table views, and designs which have a white
    ///    primary background in light mode.
    static let systemBackground: Color = Color(uiColor: .systemBackground)
    
    /// Secondary and tertiary colors are layered on top of the main background, when appropriate.
    static let secondarySystemBackground: Color = Color(uiColor: .secondarySystemBackground)
    
    /// Secondary and tertiary colors are layered on top of the main background, when appropriate.
    static let tertiarySystemBackground: Color = Color(uiColor: .tertiarySystemBackground)
    
    /// We provide two design systems (also known as "stacks") for structuring an iOS app's backgrounds.
    ///
    /// Each stack has three "levels" of background colors. The first color is intended to be the
    /// main background, farthest back. Secondary and tertiary colors are layered on top
    /// of the main background, when appropriate.
    ///
    /// Inside of a discrete piece of UI, choose a stack, then use colors from that stack.
    /// We do not recommend mixing and matching background colors between stacks.
    /// The foreground colors above are designed to work in both stacks.
    ///
    /// 2. systemGroupedBackground
    ///    Use this stack for views with grouped content, such as grouped tables and
    ///    platter-based designs. These are like grouped table views, but you may use these
    ///    colors in places where a table view wouldn't make sense.
    static let systemGroupedBackground: Color = Color(uiColor: .systemGroupedBackground)
    
    /// Secondary and tertiary colors are layered on top of the main background, when appropriate.
    static let secondarySystemGroupedBackground: Color = Color(uiColor: .secondarySystemGroupedBackground)
    
    /// Secondary and tertiary colors are layered on top of the main background, when appropriate.
    static let tertiarySystemGroupedBackground: Color = Color(uiColor: .tertiarySystemGroupedBackground)
    
    /// Fill colors for UI elements.
    /// These are meant to be used over the background colors, since their alpha component is less than 1.
    ///
    /// systemFillColor is appropriate for filling thin and small shapes.
    /// Example: The track of a slider.
    static let systemFill: Color = Color(uiColor: .systemFill)
    
    /// secondarySystemFillColor is appropriate for filling medium-size shapes.
    /// Example: The background of a switch.
    static let secondarySystemFill: Color = Color(uiColor: .secondarySystemFill)
    
    /// tertiarySystemFillColor is appropriate for filling large shapes.
    /// Examples: Input fields, search bars, buttons.
    static let tertiarySystemFill: Color = Color(uiColor: .tertiarySystemFill)
    
    /// quaternarySystemFillColor is appropriate for filling large areas containing complex content.
    /// Example: Expanded table cells.
    static let quaternarySystemFill: Color = Color(uiColor: .quaternarySystemFill)
    
    /// lightTextColor is always light, and darkTextColor is always dark, regardless of the current UIUserInterfaceStyle.
    /// When possible, we recommend using `labelColor` and its variants, instead.
    static let lightText: Color = Color(uiColor: .lightText) // for a dark background
    
    /// lightTextColor is always light, and darkTextColor is always dark, regardless of the current UIUserInterfaceStyle.
    /// When possible, we recommend using `labelColor` and its variants, instead.
    static let darkText: Color = Color(uiColor: .darkText) // for a light background
}
#endif

extension Color {
    /// The red, green, blue, and alpha components of this color.
    public var components: (red: Double, green: Double, blue: Double, opacity: Double) {
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
    
    /// Lerp between two colors.
    /// - Parameters:
    ///   - c1: The starting color.
    ///   - c2: The target color.
    ///   - progress: The lerp percentage in [0, 1].
    /// - Returns: A lerped color that is a distance determined by `progress` between `c1` and `c2`.
    public static func Lerp(from c1: Color, to c2: Color, progress: Double) -> Color {
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
    
    /// Brighten a color by a given amount.
    ///
    /// - Parameter percentage: The amount to brighten the color by.
    /// - Returns: A brightened version of this color.
    public func brightened(by percentage: Double) -> Color {
        adjust(by: abs(percentage))
    }
    
    /// Darken a color by a given amount.
    ///
    /// - Parameter percentage: The amount to darken the color by.
    /// - Returns: A darkened version of this color.
    public func darkened(by percentage: Double) -> Color {
        adjust(by: -abs(percentage))
    }
    
    /// Create a color that contrasts well with the color represented by `self`.
    ///
    /// - Returns: `Color.white` if `self` is dark, and `Color.black` if `self` is bright.
    public var contrastColor: Color {
        // https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
        let components = self.components
        let luminance = (0.299 * components.red + 0.587 * components.green + 0.114 * components.blue)
        
        return luminance > 0.5 ? .black : .white
    }
    
    /// Create a new color that is equivalent to applying the given opacity to `self`, but with no transparency.
    ///
    /// - Parameters:
    ///   - opacity: The opacity to apply.
    ///   - background: The background color to bake in.
    /// - Returns: A new color that is equivalent to applying the given opacity to `self`, but with no transparency.
    public func applyOpacity(_ opacity: Double, background: Color = .white) -> Color {
        return merge(with: background, weight: opacity)
    }
    
    /// Merge this color with another one, with a given weight.
    ///
    /// - Parameters:
    ///   - other: The color to merge with.
    ///   - weight: The weight to apply to this color.
    /// - Returns: A merged version of the two colors.
    public func merge(with other: Color, weight: Double = 0.5) -> Color {
        let components = self.components
        let other = other.components
        let inv = 1.0 - weight
        
        return Color(red: components.red * weight + other.red * inv,
                     green: components.green * weight + other.green * inv,
                     blue: components.blue * weight + other.blue * inv)
    }
    
    /// - Returns: A random color using the given RNG.
    public static func random(using rng: inout ARC4RandomNumberGenerator) -> Color {
        Color(red: Double.random(in: 0...1, using: &rng),
              green: Double.random(in: 0...1, using: &rng),
              blue: Double.random(in: 0...1, using: &rng))
    }
    
    /// - Returns: A random color using the system RNG.
    public static func random() -> Color {
        Color(red: Double.random(in: 0...1),
              green: Double.random(in: 0...1),
              blue: Double.random(in: 0...1))
    }
    
    /// - Returns: A random color determined by the given seed.
    public static func random(seed: UInt64) -> Color {
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
