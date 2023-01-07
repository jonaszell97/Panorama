
import SwiftUI

public struct Triangle: Shape {
    public enum Direction {
        case Up, Down, Left, Right
    }
    
    public enum BorderMode {
        case All, Arrow
    }
    
    /// The direction the triangle is pointing.
    var direction: Direction
    
    /// The border mode.
    var borderMode: BorderMode = .All
    
    public init(direction: Direction, borderMode: BorderMode) {
        self.direction = direction
        self.borderMode = borderMode
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        var points: [CGPoint] = []
        
        switch direction {
        case .Up:
            points.append(.init(x: rect.width * 0.5, y: 0))
            points.append(.init(x: rect.width, y: rect.height))
            points.append(.init(x: 0, y: rect.height))
        case .Down:
            points.append(.init(x: rect.width * 0.5, y: rect.height))
            points.append(.init(x: rect.width, y: 0))
            points.append(.init(x: 0, y: 0))
        case .Left:
            points.append(.init(x: 0, y: rect.height * 0.5))
            points.append(.init(x: rect.width, y: 0))
            points.append(.init(x: rect.width, y: rect.height))
        case .Right:
            points.append(.init(x: rect.width, y: rect.height * 0.5))
            points.append(.init(x: 0, y: 0))
            points.append(.init(x: 0, y: rect.height))
        }
        
        path.move(to: points.last!)
        if borderMode == .Arrow {
            _ = points.popLast()
        }
        
        for pt in points {
            path.addLine(to: CGPoint(x: pt.x, y: pt.y))
        }
        
        return path
    }
}
