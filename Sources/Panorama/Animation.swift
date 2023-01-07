
import enum Accelerate.vDSP
import SwiftUI
import Toolbox

public struct AnimatableVector: VectorArithmetic {
    public static var zero = AnimatableVector(values: [0.0])
    
    public static func + (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        var copy = lhs
        copy += rhs
        return copy
    }
    
    public static func += (lhs: inout AnimatableVector, rhs: AnimatableVector) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.add(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }
    
    public static func - (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        var copy = lhs
        copy -= rhs
        return copy
    }
    
    public static func -= (lhs: inout AnimatableVector, rhs: AnimatableVector) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }
    
    public var values: [Double]
    
    public init(values: [Double]) {
        self.values = values
    }
    
    public mutating func scale(by rhs: Double) {
        values = vDSP.multiply(rhs, values)
    }
    
    public var magnitudeSquared: Double {
        vDSP.sum(vDSP.multiply(values, values))
    }
}

public extension CGRect {
    /// A random point on one of the edges.
    func randomPointOnEdge(using rng: inout ARC4RandomNumberGenerator) -> CGPoint {
        let x: CGFloat, y: CGFloat
        
        let edge = Edge.allCases.randomElement(using: &rng)!
        switch edge {
        case .top:
            x = CGFloat.random(in: 0..<self.width)
            y = 0
        case .leading:
            x = 0
            y = CGFloat.random(in: 0..<self.height)
        case .bottom:
            x = CGFloat.random(in: 0..<self.width)
            y = height
        case .trailing:
            x = width
            y = CGFloat.random(in: 0..<self.height)
        }
        
        return .init(x: x, y: y)
    }
}

extension CGPoint: VectorArithmetic {
}

extension CGSize: VectorArithmetic {
}

public struct AnimatableTuple3<A: VectorArithmetic, B: VectorArithmetic, C: VectorArithmetic>: VectorArithmetic {
    public var first: A
    public var second: B
    public var third: C
    
    public init(_ first: A, _ second: B, _ third: C) {
        self.first = first
        self.second = second
        self.third = third
    }
    
    public static var zero: Self { .init(.zero, .zero, .zero) }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        var copy = lhs
        copy += rhs
        return copy
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.first += rhs.first
        lhs.second += rhs.second
        lhs.third += rhs.third
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        var copy = lhs
        copy -= rhs
        return copy
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.first -= rhs.first
        lhs.second -= rhs.second
        lhs.third -= rhs.third
    }
    
    public mutating func scale(by rhs: Double) {
        first.scale(by: rhs)
        second.scale(by: rhs)
        third.scale(by: rhs)
    }
    
    public var magnitudeSquared: Double {
        first.magnitudeSquared + second.magnitudeSquared + third.magnitudeSquared
    }
}

public struct AnimatableTuple4<A: VectorArithmetic, B: VectorArithmetic, C: VectorArithmetic, D: VectorArithmetic>: VectorArithmetic {
    public var first: A
    public var second: B
    public var third: C
    public var fourth: D
    
    public init(_ first: A, _ second: B, _ third: C, _ fourth: D) {
        self.first = first
        self.second = second
        self.third = third
        self.fourth = fourth
    }
    
    public static var zero: Self { .init(.zero, .zero, .zero, .zero) }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        var copy = lhs
        copy += rhs
        return copy
    }
    
    public static func += (lhs: inout Self, rhs: Self) {
        lhs.first += rhs.first
        lhs.second += rhs.second
        lhs.third += rhs.third
        lhs.fourth += rhs.fourth
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        var copy = lhs
        copy -= rhs
        return copy
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.first -= rhs.first
        lhs.second -= rhs.second
        lhs.third -= rhs.third
        lhs.fourth -= rhs.fourth
    }
    
    public mutating func scale(by rhs: Double) {
        first.scale(by: rhs)
        second.scale(by: rhs)
        third.scale(by: rhs)
        fourth.scale(by: rhs)
    }
    
    public var magnitudeSquared: Double {
        first.magnitudeSquared + second.magnitudeSquared + third.magnitudeSquared + fourth.magnitudeSquared
    }
}
