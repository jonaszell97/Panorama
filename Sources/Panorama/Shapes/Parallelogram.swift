
import SwiftUI

/// A parallelogram shape with a customizable edge offset.
public struct Parallelogram: Shape {
    var edgeOffset: CGFloat
    
    public var animatableData: CGFloat {
        get { return edgeOffset }
        set { edgeOffset = newValue }
    }
    
    var points: [CGPoint] {
        [
            CGPoint(x: 0, y: 1),
            CGPoint(x: edgeOffset, y: 0),
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1 - edgeOffset, y: 1)
        ]
    }
    
    /// Create a parallelogram shape.
    ///
    /// - Parameter edgeOffset: The horizontal edge offset of the upper right corner.
    public init(edgeOffset: CGFloat) {
        self.edgeOffset = edgeOffset
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = self.points
        
        path.move(to: CGPoint(x: points[3].x * rect.width, y: points[3].y * rect.height))
        
        for pt in points {
            path.addLine(to: CGPoint(x: pt.x * rect.width, y: pt.y * rect.height))
        }
        
        return path
    }
}
