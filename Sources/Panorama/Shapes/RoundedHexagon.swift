
import SwiftUI

public struct RoundedHexagon: Shape {
    var cornerAdjustment: CGFloat
    
    public var animatableData: CGFloat {
        get { return cornerAdjustment }
        set { cornerAdjustment = newValue }
    }
    
    public init(cornerAdjustment: CGFloat) {
        self.cornerAdjustment = cornerAdjustment
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        var width: CGFloat = min(rect.width, rect.height)
        let height = width
        let xScale: CGFloat = 0.832
        let xOffset = (width * (1.0 - xScale)) / 2.0
        width *= xScale
        path.move(
            to: CGPoint(
                x: xOffset + width * 0.95,
                y: height * (0.20 + cornerAdjustment)
            )
        )
        
        let points = self.points
        points.forEach {
            path.addLine(
                to: .init(
                    x: xOffset + width * $0.useWidth.0 * $0.xFactors.0,
                    y: height * $0.useHeight.0 * $0.yFactors.0
                )
            )
            
            path.addQuadCurve(
                to: .init(
                    x: xOffset + width * $0.useWidth.1 * $0.xFactors.1,
                    y: height * $0.useHeight.1 * $0.yFactors.1
                ),
                control: .init(
                    x: xOffset + width * $0.useWidth.2 * $0.xFactors.2,
                    y: height * $0.useHeight.2 * $0.yFactors.2
                )
            )
        }
        
        return path
    }
    
    struct Segment {
        let useWidth: (CGFloat, CGFloat, CGFloat)
        let xFactors: (CGFloat, CGFloat, CGFloat)
        let useHeight: (CGFloat, CGFloat, CGFloat)
        let yFactors: (CGFloat, CGFloat, CGFloat)
    }
    
    var points: [Segment] {
        [
            Segment(
                useWidth:  (1.00, 1.00, 1.00),
                xFactors:  (0.60, 0.40, 0.50),
                useHeight: (1.00, 1.00, 0.00),
                yFactors:  (0.05, 0.05, 0.00)
            ),
            Segment(
                useWidth:  (1.00, 1.00, 0.00),
                xFactors:  (0.05, 0.00, 0.00),
                useHeight: (1.00, 1.00, 1.00),
                yFactors:  (0.20 + cornerAdjustment, 0.30 + cornerAdjustment, 0.25 + cornerAdjustment)
            ),
            Segment(
                useWidth:  (1.00, 1.00, 0.00),
                xFactors:  (0.00, 0.05, 0.00),
                useHeight: (1.00, 1.00, 1.00),
                yFactors:  (0.70 - cornerAdjustment, 0.80 - cornerAdjustment, 0.75 - cornerAdjustment)
            ),
            Segment(
                useWidth:  (1.00, 1.00, 1.00),
                xFactors:  (0.40, 0.60, 0.50),
                useHeight: (1.00, 1.00, 1.00),
                yFactors:  (0.95, 0.95, 1.00)
            ),
            Segment(
                useWidth:  (1.00, 1.00, 1.00),
                xFactors:  (0.95, 1.00, 1.00),
                useHeight: (1.00, 1.00, 1.00),
                yFactors:  (0.80 - cornerAdjustment, 0.70 - cornerAdjustment, 0.75 - cornerAdjustment)
            ),
            Segment(
                useWidth:  (1.00, 1.00, 1.00),
                xFactors:  (1.00, 0.95, 1.00),
                useHeight: (1.00, 1.00, 1.00),
                yFactors:  (0.30 + cornerAdjustment, 0.20 + cornerAdjustment, 0.25 + cornerAdjustment)
            )
        ]
    }
}

public struct HexagonParameters {
    struct Segment {
        let useWidth: (CGFloat, CGFloat, CGFloat)
        let xFactors: (CGFloat, CGFloat, CGFloat)
        let useHeight: (CGFloat, CGFloat, CGFloat)
        let yFactors: (CGFloat, CGFloat, CGFloat)
    }
    
    static let adjustment: CGFloat = 0.085
    
    static let points = [
        Segment(
            useWidth:  (1.00, 1.00, 1.00),
            xFactors:  (0.60, 0.40, 0.50),
            useHeight: (1.00, 1.00, 0.00),
            yFactors:  (0.05, 0.05, 0.00)
        ),
        Segment(
            useWidth:  (1.00, 1.00, 0.00),
            xFactors:  (0.05, 0.00, 0.00),
            useHeight: (1.00, 1.00, 1.00),
            yFactors:  (0.20 + adjustment, 0.30 + adjustment, 0.25 + adjustment)
        ),
        Segment(
            useWidth:  (1.00, 1.00, 0.00),
            xFactors:  (0.00, 0.05, 0.00),
            useHeight: (1.00, 1.00, 1.00),
            yFactors:  (0.70 - adjustment, 0.80 - adjustment, 0.75 - adjustment)
        ),
        Segment(
            useWidth:  (1.00, 1.00, 1.00),
            xFactors:  (0.40, 0.60, 0.50),
            useHeight: (1.00, 1.00, 1.00),
            yFactors:  (0.95, 0.95, 1.00)
        ),
        Segment(
            useWidth:  (1.00, 1.00, 1.00),
            xFactors:  (0.95, 1.00, 1.00),
            useHeight: (1.00, 1.00, 1.00),
            yFactors:  (0.80 - adjustment, 0.70 - adjustment, 0.75 - adjustment)
        ),
        Segment(
            useWidth:  (1.00, 1.00, 1.00),
            xFactors:  (1.00, 0.95, 1.00),
            useHeight: (1.00, 1.00, 1.00),
            yFactors:  (0.30 + adjustment, 0.20 + adjustment, 0.25 + adjustment)
        )
    ]
}
