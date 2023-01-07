
import SwiftUI
import Toolbox

public struct LineShape: Shape {
    /// The edge that should be drawn.
    let edge: Edge
    
    /// Default initializer.
    public init(edge: Edge) {
        self.edge = edge
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        switch edge {
        case .top:
            path.move(to: rect.topLeft)
            path.addLine(to: rect.topRight)
        case .leading:
            path.move(to: rect.topLeft)
            path.addLine(to: rect.bottomLeft)
        case .bottom:
            path.move(to: rect.bottomLeft)
            path.addLine(to: rect.bottomRight)
        case .trailing:
            path.move(to: rect.topRight)
            path.addLine(to: rect.bottomRight)
        }
        
        return path
    }
}
