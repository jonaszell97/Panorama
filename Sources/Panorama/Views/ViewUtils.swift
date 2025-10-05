
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// A button style that does not change the apperance of the button.
public struct EmptyButtonStyle: ButtonStyle {
    /// Create an empty button style.
    public init() {
        
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension View {
    /// Hide a list background only if the required method is available.
    func hideListBackgroundIfAvailable() -> some View {
        ZStack {
            if #available(iOS 16, macOS 13, *) {
                self.scrollContentBackground(.hidden)
            }
            else {
                self
            }
        }
    }
}

public extension EdgeInsets {
    /// The combined top and bottom insets.
    var vertical: CGFloat {
        self.top + self.bottom
    }
    
    /// The combined leading and trailing insets.
    var horizontal: CGFloat {
        self.leading + self.trailing
    }
}

public extension View {
    /// Apply a modifier to this view.
    ///
    /// - Parameters:
    ///   - modifier: The modifier to apply.
    /// - Returns: The `self` view, with `modifier` applied to it.
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
    
    /// Apply a modifier to this view only if the given condition is true.
    ///
    /// - Parameters:
    ///   - condition: The condition that controls the modifier.
    ///   - modifier: The modifier to apply conditionally.
    /// - Returns: The `self` view, optionally with `modifier` applied to it if `condition` is true.
    func applyIf<M: ViewModifier>(_ condition: Bool, _ modifier: M) -> some View {
        ZStack {
            if condition {
                self.modifier(modifier)
            }
            else {
                self
            }
        }
    }
    
    /// Apply a modifier function to this view only if the given condition is true.
    ///
    /// - Parameters:
    ///   - condition: The condition that controls the modifier.
    ///   - modifierFunction: The modifier function to apply conditionally.
    /// - Returns: The `self` view, optionally with `modifier` applied to it if `condition` is true.
    func applyIf<T: View>(_ condition: Bool, modifierFunction: (Self) -> T) -> some View {
        ZStack {
            if condition {
                modifierFunction(self)
            }
            else {
                self
            }
        }
    }
    
    /// A combination of the `onAppear` and `onChange` modifiers.
    ///
    /// - Parameters:
    ///   - value: The value to check against when determining whether to run the closure.
    ///   - action: A closure to run when the value changes or the view appears.
    ///
    /// - Returns: A view that fires an action when the specified value changes or when it appears.
    func onAppearOrChange<T>(of value: T, perform action: @escaping (T) -> Void)
        -> some View where T: Equatable
    {
        self.onAppear { action(value) }
            .onChange(of: value) { action($0) }
    }
}

fileprivate struct RelativeOffsetView<Content: View>: View {
    /// The content view.
    let content: Content
    
    /// The relative offset.
    let relativeOffset: CGSize
    
    /// The computed view size.
    @State var size: CGSize? = nil
    
    init (relativeOffset: CGSize, @ViewBuilder content: () -> Content) {
        self.relativeOffset = relativeOffset
        self.content = content()
    }
    
    var body: some View {
        content
            .opacity(self.size == nil ? 0 : 1)
            .offset(x: (self.size?.width ?? 0) * relativeOffset.width, y: (self.size?.height ?? 0) * relativeOffset.height)
            .overlay(GeometryReader { geometry in
                ZStack {
                }
                .onAppear {
                    self.size = geometry.size
                }
            })
    }
}

public extension View {
    /// Apply an offset that is relative to the view's size.
    ///
    /// - Parameter offset: The offset to apply. The width and height of the offset are
    /// multiplied by the view's widtth and height, respectively.
    /// - Returns: The `self` view offset by the given amount.
    func relativeOffset(_ offset: CGSize) -> some View {
        RelativeOffsetView(relativeOffset: offset) {
            self
        }
    }
    
    /// Apply an offset that is relative to the view's size.
    ///
    /// - Parameters:
    ///   - x: The horizontal offset. This value is multiplied by the view's size.
    ///   - y: The vertical offset. This value is multiplied by the view's size.
    /// - Returns: The `self` view offset by the given amount.
    func relativeOffset(x: CGFloat? = nil, y: CGFloat? = nil) -> some View {
        RelativeOffsetView(relativeOffset: .init(width: x ?? 0, height: y ?? 0)) {
            self
        }
    }
}

public extension View {
    /// Read the size of this view.
    func readSize(into size: Binding<CGSize?>) -> some View {
        self.overlay(GeometryReader { geometry in
            ZStack {}
                .onAppear {
                    size.wrappedValue = geometry.size
                }
        })
    }
    
    /// Read the size and safe area insets of this view.
    func readSizeAndSafeAreaInsets(size: Binding<CGSize?>, safeAreaInsets: Binding<EdgeInsets?>) -> some View {
        self.overlay(GeometryReader { geometry in
            ZStack {}
                .onAppear {
                    size.wrappedValue = geometry.size
                    safeAreaInsets.wrappedValue = geometry.safeAreaInsets
                }
        })
    }
}

// MARK: VisualEffectView

#if canImport(UIKit)

/// Apply a `UIVisualEffect` to a SwiftUI `View`.
public struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    /// Create a visual effect view with a given effect.
    ///
    /// - Parameter effect: The effect to apply.
    public init(effect: UIVisualEffect? = nil) {
        self.effect = effect
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView()
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect
    }
}

public extension View {
    /// Applies a `UIBlurEffect` to the background of this view.
    ///
    /// - Parameter style: The blur style to apply.
    /// - Returns: The `self`view with a background with the specified blur.
    func blurredBackground(style: UIBlurEffect.Style) -> some View {
        self.background(VisualEffectView(effect: UIBlurEffect(style: style)))
    }
}

#endif
