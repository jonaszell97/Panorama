
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct EmptyButtonStyle: ButtonStyle {
    public init() {
        
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension View {
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
    var vertical: CGFloat {
        self.top + self.bottom
    }
    
    var horizontal: CGFloat {
        self.leading + self.trailing
    }
}

public extension View {
    /// Apply a modifier to this view only if the given condition is true.
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
    
    /// Apply a modifier to this view only if the given condition is true.
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
    /// Apply a relative offset to this view.
    func relativeOffset(_ offset: CGSize) -> some View {
        RelativeOffsetView(relativeOffset: offset) {
            self
        }
    }
    
    /// Apply a relative offset to this view.
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

/// Allows using UIVisualEffect in SwiftUI.
public struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    public init(effect: UIVisualEffect? = nil) {
        self.effect = effect
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView()
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect
    }
}

public extension View {
    /// Applies a UIBlurEffect to the background of this view.
    func blurredBackground(style: UIBlurEffect.Style) -> some View {
        self.background(VisualEffectView(effect: UIBlurEffect(style: style)))
    }
}

#endif
