
import SwiftUI
import Toolbox

public struct RegularPolygon: Shape {
    /// The number of sides of this polygon.
    let sideCount: Int
    
    public init(sideCount: Int) {
        self.sideCount = sideCount
    }
    
    public func path(in rect: CGRect) -> Path {
        let radius = min(rect.height, rect.width) * 0.5
        let center = rect.center
        
        var path = Path()
        guard sideCount >= 3 else {
            path.addArc(center: center, radius: radius, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
            
            return path
        }
        
        let angleStep = (2.0 * .pi) / Double(sideCount)
        let firstPt = center + GeometryToolbox.pointOnCircle(radius: radius, angleRadians: .zero)
        
        path.move(to: firstPt)
        
        for i in 1..<sideCount {
            let nextPt = GeometryToolbox.pointOnCircle(radius: radius, angleRadians: Double(i) * angleStep)
            path.addLine(to: center + nextPt)
        }
        
        path.addLine(to: firstPt)
        
        return path
    }
}
