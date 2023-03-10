
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

/// A `RoundedRectangle` that allows rounding only some corners.
public struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    /// Create a rounded rectangle shape.
    ///
    /// - Parameters:
    ///   - radius: The corner radius.
    ///   - corners: The corners that should be rounded.
    public init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }
    
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

public extension View {
    /// Apply a corner radius to this view.
    ///
    /// - Parameters:
    ///   - radius: The corner radius.
    ///   - corners: The corners that should be rounded.
    /// - Returns: The `self` view clipped with a corner radius.
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

#endif

public extension View {
    /// Apply a border with a specific radius to this view.
    ///
    /// - Parameters:
    ///   - content: The style of the border.
    ///   - width: The width of the border.
    ///   - radius: The corner radius of the border.
    /// - Returns: The `self` view with a rounded corner.
    func border<S>(_ content: S, width: CGFloat, radius: CGFloat) -> some View where S : ShapeStyle {
        return self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(content, lineWidth: width)
        )
    }
}

/// A shape that draws one or more edges of a rectangle.
public struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]
    
    /// Create an edge shape.
    ///
    /// - Parameters:
    ///   - width: The edge width.
    ///   - edges: The edges to draw.
    public init(width: CGFloat, edges: [Edge]) {
        self.width = width
        self.edges = edges
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }
            
            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }
            
            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }
            
            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

public extension View {
    /// Apply a border to this view.
    ///
    /// - Parameters:
    ///   - color: The border color.
    ///   - width: The border width.
    ///   - edges: The edges to draw.
    /// - Returns: The `self` view with a border.
    func border(_ color: Color, width: CGFloat, edges: [Edge]) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
    
    /// Apply a border to this view.
    ///
    /// - Parameters:
    ///   - color: The border color.
    ///   - style: The border style.
    ///   - edges: The edges to draw.
    /// - Returns: The `self` view with a border.
    func border(_ color: Color, style: StrokeStyle, edges: [Edge]) -> some View {
        overlay(EdgeBorder(width: style.lineWidth, edges: edges).stroke(style: style).foregroundColor(color))
    }
}
