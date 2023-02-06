
import SwiftUI

/// A generic shape that forwards its `path` function to a closure parameter.
public struct ShapeFromPath: Shape {
    /// Callback to create the shape's path.
    let createPath: (CGRect) -> Path
    
    /// Create a generic shape with a given `path` closure.
    ///
    /// - Parameter createPath: Closure used to create the shape's path.
    public init(createPath: @escaping (CGRect) -> Path) {
        self.createPath = createPath
    }
    
    public func path(in rect: CGRect) -> Path {
        return createPath(rect)
    }
}
