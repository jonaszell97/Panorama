
import SwiftUI
import Toolbox
#if canImport(UIKit)
import CoreGraphics
#endif

/// Wrapper type for icons that can be either SF symbols, custom images, or text.
public enum IconWrapper {
    /// A system icon.
    case System(systemName: String, rotation: Angle = .zero, scale: CGFloat = 1)
    
    /// A custom image icon.
    case Image(name: String, rotation: Angle = .zero, scale: CGFloat = 1)

    #if canImport(UIKit)
    /// A custom image icon.
    case LoadedImage(image: Data, rotation: Angle = .zero, scale: CGFloat = 1)
    #endif
    
    /// A text-based icon.
    case Text(text: String, rotation: Angle = .zero, scale: CGFloat = 1)
    
    /// A placeholder icon.
    case Placeholder
}

public extension IconWrapper {
    /// Create a view for this icon.
    func createView(color: Color, size: CGFloat) -> some View {
        IconWrapperView(icon: self, color: color, size: .init(width: size, height: size))
    }
    
    /// Create a view for this icon.
    func createView(color: Color, size: CGSize) -> some View {
        IconWrapperView(icon: self, color: color, size: size)
    }
}

/// View representation of an `IconWrapper`.
public struct IconWrapperView: View {
    /// The icon this view is for.
    let icon: IconWrapper
    
    /// The color of the icon.
    let color: Color
    
    /// The size of the icon.
    let size: CGSize
    
    public var body: some View {
        ZStack {
            switch icon {
            case .System(let systemName, let rotation, let scale):
                Image(systemName: systemName)
                    .font(.system(size: size.width))
                    .foregroundColor(color)
                    .rotationEffect(rotation)
                    .scaleEffect(scale)
            case .Image(let name, let rotation, let scale):
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
                    .colorMultiply(color)
                    .rotationEffect(rotation)
                    .scaleEffect(scale)
            #if canImport(UIKit)
            case .LoadedImage(let data, let rotation, let scale):
                if let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.width, height: size.height)
                        .colorMultiply(color)
                        .rotationEffect(rotation)
                        .scaleEffect(scale)
                }
                else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: size.width))
                        .foregroundColor(.red)
                        .rotationEffect(rotation)
                        .scaleEffect(scale)
                }
            #endif
            case .Text(let text, let rotation, let scale):
                Text(verbatim: text)
                    .font(.system(size: size.width))
                    .foregroundColor(color)
                    .rotationEffect(rotation)
                    .scaleEffect(scale)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            case .Placeholder:
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: size.width, height: size.height)
            }
        }
    }
}

extension IconWrapper: Equatable {
    public static func ==(lhs: IconWrapper, rhs: IconWrapper) -> Bool {
        guard lhs.codingKey == rhs.codingKey else {
            return false
        }
        
        switch lhs {
        case .System(let systemName, let rotation, let scale):
            guard case .System(let systemName_, let rotation_, let scale_) = rhs else { return false }
            guard systemName == systemName_ else { return false }
            guard rotation == rotation_ else { return false }
            guard scale == scale_ else { return false }
        case .Image(let name, let rotation, let scale):
            guard case .Image(let name_, let rotation_, let scale_) = rhs else { return false }
            guard name == name_ else { return false }
            guard rotation == rotation_ else { return false }
            guard scale == scale_ else { return false }
        #if canImport(UIKit)
        case .LoadedImage(let image, let rotation, let scale):
            guard case .LoadedImage(let image_, let rotation_, let scale_) = rhs else { return false }
            guard image == image_ else { return false }
            guard rotation == rotation_ else { return false }
            guard scale == scale_ else { return false }
        #endif
        case .Text(let text, let rotation, let scale):
            guard case .Text(let text_, let rotation_, let scale_) = rhs else { return false }
            guard text == text_ else { return false }
            guard rotation == rotation_ else { return false }
            guard scale == scale_ else { return false }
        default: break
        }
        
        return true
    }
}

extension IconWrapper: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.codingKey.rawValue)
        switch self {
        case .System(let systemName, let rotation, let scale):
            hasher.combine(systemName)
            hasher.combine(rotation)
            hasher.combine(scale)
        case .Image(let name, let rotation, let scale):
            hasher.combine(name)
            hasher.combine(rotation)
            hasher.combine(scale)
        #if canImport(UIKit)
        case .LoadedImage(let image, let rotation, let scale):
            hasher.combine(image)
            hasher.combine(rotation)
            hasher.combine(scale)
        #endif
        case .Text(let text, let rotation, let scale):
            hasher.combine(text)
            hasher.combine(rotation)
            hasher.combine(scale)
        default: break
        }
    }
}

extension IconWrapper: Codable {
    enum CodingKeys: String, CodingKey {
        case systemImage, image, text, placeholder
        
        #if canImport(UIKit)
        case loadedImage
        #endif
    }
    
    var codingKey: CodingKeys {
        switch self {
        case .System: return .systemImage
        case .Image: return .image
        #if canImport(UIKit)
        case .LoadedImage: return .loadedImage
        #endif
        case .Text: return .text
        case .Placeholder: return .placeholder
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .System(let systemName, let rotation, let scale):
            try container.encodeValues(systemName, rotation.degrees, scale, for: .systemImage)
        case .Image(let name, let rotation, let scale):
            try container.encodeValues(name, rotation.degrees, scale, for: .image)
        #if canImport(UIKit)
        case .LoadedImage(let data, let rotation, let scale):
            try container.encodeValues(data, rotation.degrees, scale, for: .loadedImage)
        #endif
        case .Text(let text, let rotation, let scale):
            try container.encodeValues(text, rotation.degrees, scale, for: .text)
        case .Placeholder:
            try container.encodeNil(forKey: .placeholder)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch container.allKeys.first {
        case .systemImage:
            let (systemName, rotationDegrees, scale): (String, Double, CGFloat) = try container.decodeValues(for: .systemImage)
            self = .System(systemName: systemName, rotation: .init(degrees: rotationDegrees), scale: scale)
        case .image:
            let (name, rotationDegrees, scale): (String, Double, CGFloat) = try container.decodeValues(for: .image)
            self = .Image(name: name, rotation: .init(degrees: rotationDegrees), scale: scale)
        #if canImport(UIKit)
        case .loadedImage:
            let (imgData, rotationDegrees, scale): (Data?, Double, CGFloat) =
            try container.decodeValues(for: .loadedImage)
            
            guard let imgData = imgData else {
                Log.reportCriticalError("IconWrapper: UIImage is missing data")
                self = .Placeholder
                
                return
            }
            
            self = .LoadedImage(image: imgData, rotation: .init(degrees: rotationDegrees), scale: scale)
        #endif
        case .text:
            let (text, rotationDegrees, scale): (String, Double, CGFloat) = try container.decodeValues(for: .text)
            self = .Text(text: text, rotation: .init(degrees: rotationDegrees), scale: scale)
        case .placeholder:
            _ = try container.decodeNil(forKey: .placeholder)
            self = .Placeholder
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum AUIcon."
                )
            )
        }
    }
}

