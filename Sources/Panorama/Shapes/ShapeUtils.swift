
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

public struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

#endif

public extension View {
    func border<S>(_ content: S, width: CGFloat, radius: CGFloat) -> some View where S : ShapeStyle {
        return self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(content, lineWidth: width)
        )
    }
}

public struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]
    
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
    func border(_ color: Color, width: CGFloat, edges: [Edge]) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
    
    func border(_ color: Color, style: StrokeStyle, edges: [Edge]) -> some View {
        overlay(EdgeBorder(width: style.lineWidth, edges: edges).stroke(style: style).foregroundColor(color))
    }
}
