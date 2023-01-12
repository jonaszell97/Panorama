
import SwiftUI

// MARK: CGLineCap extensions

extension SwiftUI.CGLineCap: Codable {
    enum CodingKeys: String, CodingKey {
        case butt, round, square
    }
    
    var codingKey: CodingKeys {
        switch self {
        case .butt: return .butt
        case .round: return .round
        case .square: return .square
        @unknown default:
            fatalError()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .butt:
            try container.encodeNil(forKey: .butt)
        case .round:
            try container.encodeNil(forKey: .round)
        case .square:
            try container.encodeNil(forKey: .square)
        @unknown default:
            fatalError()
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch container.allKeys.first {
        case .butt:
            _ = try container.decodeNil(forKey: .butt)
            self = .butt
        case .round:
            _ = try container.decodeNil(forKey: .round)
            self = .round
        case .square:
            _ = try container.decodeNil(forKey: .square)
            self = .square
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
}

extension SwiftUI.CGLineCap: Equatable {
    public static func ==(lhs: CGLineCap, rhs: CGLineCap) -> Bool {
        guard lhs.codingKey == rhs.codingKey else {
            return false
        }
        
        return true
    }
}

extension SwiftUI.CGLineCap: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.codingKey.rawValue)
    }
}

// MARK: CGLineJoin extensions

extension CGLineJoin: Codable {
    enum CodingKeys: String, CodingKey {
        case miter, round, bevel
    }
    
    var codingKey: CodingKeys {
        switch self {
        case .miter: return .miter
        case .round: return .round
        case .bevel: return .bevel
        @unknown default:
            fatalError()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .miter:
            try container.encodeNil(forKey: .miter)
        case .round:
            try container.encodeNil(forKey: .round)
        case .bevel:
            try container.encodeNil(forKey: .bevel)
        @unknown default:
            fatalError()
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch container.allKeys.first {
        case .miter:
            _ = try container.decodeNil(forKey: .miter)
            self = .miter
        case .round:
            _ = try container.decodeNil(forKey: .round)
            self = .round
        case .bevel:
            _ = try container.decodeNil(forKey: .bevel)
            self = .bevel
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
}

extension CGLineJoin: Equatable {
    public static func ==(lhs: CGLineJoin, rhs: CGLineJoin) -> Bool {
        guard lhs.codingKey == rhs.codingKey else {
            return false
        }
        
        return true
    }
}

extension CGLineJoin: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.codingKey.rawValue)
    }
}

// MARK: StrokeStyle extensions

extension SwiftUI.StrokeStyle: Codable {
    enum CodingKeys: String, CodingKey {
        case lineWidth, lineCap, lineJoin, miterLimit, dash, dashPhase
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lineWidth, forKey: .lineWidth)
        try container.encode(lineCap, forKey: .lineCap)
        try container.encode(lineJoin, forKey: .lineJoin)
        try container.encode(miterLimit, forKey: .miterLimit)
        try container.encode(dash, forKey: .dash)
        try container.encode(dashPhase, forKey: .dashPhase)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            lineWidth: try container.decode(CGFloat.self, forKey: .lineWidth),
            lineCap: try container.decode(CGLineCap.self, forKey: .lineCap),
            lineJoin: try container.decode(CGLineJoin.self, forKey: .lineJoin),
            miterLimit: try container.decode(CGFloat.self, forKey: .miterLimit),
            dash: try container.decode(Array<CGFloat>.self, forKey: .dash),
            dashPhase: try container.decode(CGFloat.self, forKey: .dashPhase)
        )
    }
}

extension SwiftUI.StrokeStyle: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(lineWidth)
        hasher.combine(lineCap)
        hasher.combine(lineJoin)
        hasher.combine(miterLimit)
        hasher.combine(dash)
        hasher.combine(dashPhase)
    }
}

// MARK: Gradient.Stop extensions

extension Gradient.Stop: Codable {
    enum CodingKeys: String, CodingKey {
        case color, location
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try container.encode(location, forKey: .location)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            color: try container.decode(Color.self, forKey: .color),
            location: try container.decode(CGFloat.self, forKey: .location)
        )
    }
}

extension Gradient.Stop: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(color)
        hasher.combine(location)
    }
    
    @available(iOS 14, *)
    public var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        
        return hasher.finalize()
    }
}

// MARK: Path extensions

extension SwiftUI.Path: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        
        guard let path = Path(string) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "String '\(string)' does not describe a valid path."
                )
            )
        }
        
        self = path
    }
}

// MARK: Shape extensions

public struct CodableShape: Shape {
    /// The path of the shape to encode in the unit rectangle.
    let unitPath: Path
    
    /// The unit rectangle.
    static let unitRect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    
    /// Initialize from any shape.
    public init<S: Shape>(shape: S) {
        self.unitPath = shape.path(in: Self.unitRect)
    }
    
    /// Memberwise initializer.
    public init(unitPath: Path) {
        self.unitPath = unitPath
    }
    
    public func path(in rect: CGRect) -> Path {
        var transform = CGAffineTransform(scaleX: rect.width, y: rect.height)
        transform = transform.concatenating(.init(translationX: rect.minX, y: rect.maxX))
        
        return unitPath.applying(transform)
    }
}

extension CodableShape: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(unitPath)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(unitPath: try container.decode(Path.self))
    }
}

// MARK: ColorScheme

extension ColorScheme: Codable, RawRepresentable {
    public enum RawValueType: String, Codable {
        case dark, light, unknown
    }
    
    public var rawValue: RawValueType {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        @unknown default:
            return .unknown
        }
    }
    
    public init?(rawValue: RawValueType) {
        switch rawValue {
        case .light:
            self = .light
        case .dark:
            self = .dark
        case .unknown:
            return nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        
        guard let this = ColorScheme(rawValue: rawValue) else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath,
                                                    debugDescription: "unknown raw value for ColorScheme: \(rawValue)"))
        }
        
        self = this
    }
}
