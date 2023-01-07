
import SwiftUI

public struct ShapeFromPath: Shape {
    /// Callback to create the shape's path.
    let createPath: (CGRect) -> Path
    
    /// Default initializer.
    public init(createPath: @escaping (CGRect) -> Path) {
        self.createPath = createPath
    }
    
    public func path(in rect: CGRect) -> Path {
        return createPath(rect)
    }
}
