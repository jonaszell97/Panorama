
import SwiftUI
import Toolbox

/// A checkmark whose stroke can be animated.
///
/// Example usage:
/// ```swift
/// AnimatableCheckmark(progress: progress)
///     .stroke(Color.green, lineWidth: 5)
///     .frame(width: 30, height: 30)
/// ```
/// ![An animated checkmark.](AnimatableCheckmark)
public struct AnimatableCheckmark: Shape {
    /// The animation progress.
    var progress: CGFloat
    
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    /// The first point in the checkmark.
    static let point1: CGPoint = CGPoint(x: 0,   y: 0.6)
    
    /// The second point in the checkmark.
    static let point2: CGPoint = CGPoint(x: 0.35, y: 0.95)
    
    /// The third point in the checkmark.
    static let point3: CGPoint = CGPoint(x: 1,   y: 0.1)
    
    /// Initialize with a given progress percentage.
    ///
    /// - Parameter progress: The animation progress percentage in [0, 1].
    public init(progress: CGFloat) {
        self.progress = progress
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let p1 = Self.point1.projectUnitPoint(onto: rect)
        let p2 = Self.point2.projectUnitPoint(onto: rect)
        let p3 = Self.point3.projectUnitPoint(onto: rect)
        let d1 = p2 - p1
        let d2 = p3 - p2
        let m1 = d1.magnitude
        let m2 = d2.magnitude
        let total = m1 + m2
        
        path.move(to: p1)
        
        let drawnDistance = progress * total
        if drawnDistance >= m1 {
            // Draw the first line completely
            path.addLine(to: p2)
            
            if drawnDistance >= total {
                // Draw the second line completely
                path.addLine(to: p3)
            }
            else {
                // Draw second line partially
                path.addLine(to: p2 + (d2.normalized * (drawnDistance - m1)))
            }
        }
        else {
            // Draw first line partially
            path.addLine(to: p1 + (d1.normalized * drawnDistance))
        }
        
        return path
    }
}

/// A X-mark whose stroke can be animated.
///
/// Example usage:
/// ```swift
/// AnimatableXMark(progress: progress)
///     .stroke(Color.red, lineWidth: 5)
///     .frame(width: 30, height: 30)
/// ```
/// ![An animated X-mark.](AnimatableXmark)
public struct AnimatableXMark: Shape {
    /// The animation progress.
    var progress: CGFloat
    
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    /// The first point in the xmark.
    static let point1: CGPoint = CGPoint(x: 0,   y: 0)
    
    /// The second point in the xmark.
    static let point2: CGPoint = CGPoint(x: 1, y: 1)
    
    /// The third point in the xmark.
    static let point3: CGPoint = CGPoint(x: 0,   y: 1)
    
    /// The fourth point in the xmark.
    static let point4: CGPoint = CGPoint(x: 1,   y: 0)
    
    /// Initialize with a given progress percentage.
    ///
    /// - Parameter progress: The animation progress percentage in [0, 1].
    public init(progress: CGFloat) {
        self.progress = progress
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let p1 = Self.point1.projectUnitPoint(onto: rect)
        let p2 = Self.point2.projectUnitPoint(onto: rect)
        let p3 = Self.point3.projectUnitPoint(onto: rect)
        let p4 = Self.point4.projectUnitPoint(onto: rect)
        let d1 = p2 - p1
        let d2 = p4 - p3
        let m1 = d1.magnitude
        let m2 = d2.magnitude
        let total = m1 + m2
        
        path.move(to: p1)
        
        let drawnDistance = progress * total
        if drawnDistance >= m1 {
            // Draw the first line completely
            path.addLine(to: p2)
        }
        else {
            // Draw first line partially
            path.addLine(to: p1 + (d1.normalized * drawnDistance))
        }
        
        path.move(to: p3)
        
        if drawnDistance >= total {
            // Draw the second line completely
            path.addLine(to: p4)
        }
        else if drawnDistance >= m1 {
            // Draw second line partially
            path.addLine(to: p3 + (d2.normalized * (drawnDistance - m1)))
        }
        
        return path
    }
}

/// A circle whose stroke can be animated.
///
/// Example usage:
/// ```swift
/// AnimatableCircle(progress: progress)
///     .stroke(Color.black, lineWidth: 5)
///     .frame(width: 30, height: 30)
/// ```
/// ![An animated circle.](AnimatableCircle)
public struct AnimatableCircle: Shape {
    /// The animation progress.
    var progress: CGFloat
    
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    /// Initialize with a given progress percentage.
    ///
    /// - Parameter progress: The animation progress percentage in [0, 1].
    public init(progress: CGFloat) {
        self.progress = progress
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: rect.center, radius: rect.height*0.5,
                    startAngle: .init(degrees: -90),
                    endAngle: .init(degrees: -90 + progress * 360),
                    clockwise: false)
        
        return path
    }
}

struct AnimatableShapePreviews: PreviewProvider {
    struct Preview: View {
        @State var progress: CGFloat = 0
        var body: some View {
            VStack(spacing: 50) {
                AnimatableCheckmark(progress: progress)
                    .stroke(Color.green, lineWidth: 5)
                    .frame(width: 30, height: 30)
                
                AnimatableXMark(progress: progress)
                    .stroke(Color.red, lineWidth: 5)
                    .frame(width: 30, height: 30)
                
                AnimatableCircle(progress: progress)
                    .stroke(Color.black, lineWidth: 5)
                    .frame(width: 30, height: 30)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1)) {
                    self.progress = 1
                }
            }
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
