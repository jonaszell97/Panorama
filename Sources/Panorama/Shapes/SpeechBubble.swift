
import SwiftUI

public struct SpeechBubble: Shape {
    public enum ArrowPosition {
        case Top, Bottom, Left, Right
    }
    
    /// The position to draw the arrow in.
    let arrowPosition: ArrowPosition
    
    /// The size of the arrow.
    let arrowSize: CGPoint
    
    public init(arrowPosition: ArrowPosition, arrowSize: CGPoint) {
        self.arrowPosition = arrowPosition
        self.arrowSize = arrowSize
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let arrowHalfWidth = arrowSize.x * 0.5
        let arrowHalfHeight = arrowSize.y * 0.5
        
        // Move to top left corner.
        path.move(to: .init(x: 0, y: 0))
        
        // Top border
        if arrowPosition == .Top {
            path.addLine(to: .init(x: (rect.width * 0.5) - arrowHalfWidth, y: 0))
            path.addLine(to: .init(x: (rect.width * 0.5),                  y: -arrowSize.y))
            path.addLine(to: .init(x: (rect.width * 0.5) + arrowHalfWidth, y: 0))
            path.addLine(to: .init(x: rect.width,                          y: 0))
        }
        else {
            path.addLine(to: .init(x: rect.width, y: 0))
        }
        
        // Right border
        if arrowPosition == .Right {
            path.addLine(to: .init(x: rect.width,               y: (rect.height * 0.5) - arrowHalfHeight))
            path.addLine(to: .init(x: rect.width + arrowSize.x, y: (rect.height * 0.5)))
            path.addLine(to: .init(x: rect.width,               y: (rect.height * 0.5) + arrowHalfHeight))
            path.addLine(to: .init(x: rect.width,               y: rect.height))
        }
        else {
            path.addLine(to: .init(x: rect.width, y: rect.height))
        }
        
        // Bottom border
        if arrowPosition == .Bottom {
            path.addLine(to: .init(x: (rect.width * 0.5) + arrowHalfWidth, y: rect.height))
            path.addLine(to: .init(x: (rect.width * 0.5),                  y: rect.height + arrowSize.y))
            path.addLine(to: .init(x: (rect.width * 0.5) - arrowHalfWidth, y: rect.height))
            path.addLine(to: .init(x: 0,                                   y: rect.height))
        }
        else {
            path.addLine(to: .init(x: 0, y: rect.height))
        }
        
        // left border
        if arrowPosition == .Left {
            path.addLine(to: .init(x: 0,               y: (rect.height * 0.5) + arrowHalfHeight))
            path.addLine(to: .init(x: 0 - arrowSize.x, y: (rect.height * 0.5)))
            path.addLine(to: .init(x: 0,               y: (rect.height * 0.5) - arrowHalfHeight))
            path.addLine(to: .init(x: 0,               y: rect.height))
        }
        else {
            path.addLine(to: .init(x: 0, y: rect.height))
        }
        
        return path
    }
}
