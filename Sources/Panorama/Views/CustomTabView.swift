
#if canImport(SwiftUI)

import SwiftUI

fileprivate let tabIndicatorPadding: CGFloat = 15

/// The height of the page indicator view.
fileprivate func tabIndicatorViewHeight(for style: TabIndicatorStyle) -> CGFloat {
    switch style {
    case .rectangle(_, let height, _):
        return 2*tabIndicatorPadding + height
    case .circle(let radius, _):
        return 2*tabIndicatorPadding + radius
    }
}

/// The page indicator view.
fileprivate func tabIndicatorView(_ index: Int, itemCount: Int, style: TabIndicatorStyle) -> some View {
    let spacing: CGFloat
    if case .circle = style {
        spacing = 8
    }
    else {
        spacing = 5
    }
    
    return HStack(spacing: spacing) {
        Spacer()
        
        ForEach(0..<itemCount, id: \.self) { i in
            switch style {
            case .rectangle(let width, let height, let color):
                Rectangle()
                    .fill(color)
                    .frame(width: width, height: height)
                    .opacity(i == index ? 1 : 0.30)
            case .circle(let radius, let color):
                Circle()
                    .fill(color)
                    .frame(width: radius, height: radius)
                    .opacity(i == index ? 1 : 0.30)
            }
            
        }
        
        Spacer()
    }
    .padding(.vertical, tabIndicatorPadding)
    .background(Rectangle().fill(.clear).edgesIgnoringSafeArea(.all))
}

/// The position of the tab view indicator.
public enum TabIndicatorPosition {
    case top, bottom
}

/// The style of the tab view indicator.
public enum TabIndicatorStyle {
    case rectangle(width: CGFloat = 20, height: CGFloat = 8, color: Color)
    case circle(radius: CGFloat = 8, color: Color)
}

/// Provides an alternative to SwiftUI's `TabView().tabViewStyle(.page)` with customizable animations,
/// gestures, and callbacks.
///
/// The following example shows the usage of `CustomTabView`:
/// ```swift
/// CustomTabView(itemCount: 3, index: .init(get: { index }, set: { index = $0}),
///               navigationEnabled: true,
///               tabIndicatorStyle: .circle(color: .black)) {
///     ZStack {
///         Text("Tab 1")
///     }
///     .frame(minWidth: UIScreen.main.bounds.width, maxHeight: .infinity)
///     .background(Color.red.opacity(0.1))
///     .tag(0)
///
///     ZStack {
///         Text("Tab 2")
///     }
///     .frame(minWidth: UIScreen.main.bounds.width, maxHeight: .infinity)
///     .background(Color.green.opacity(0.1))
///     .tag(1)
///
///     ZStack {
///         Text("Tab 3")
///     }
///     .frame(minWidth: UIScreen.main.bounds.width, maxHeight: .infinity)
///     .background(Color.blue.opacity(0.1))
///     .tag(2)
/// }
/// ```
/// ![A custom tab view with 3 tabs.](CustomTabView)
public struct CustomTabView<Content: View>: View {
    /// The view content.
    let content: Content
    
    /// The externally provided index of the currently selected item.
    @Binding var externalIndex: Int
    
    /// The index of the currently selected item.
    @State var index: Int
    
    /// The current view offset.
    @State var offset: CGFloat = 0
    
    /// Whether or not the tap-navigation is currently moving forward.
    @State var tapDirectionForward: Bool = true
    
    /// The width of a single item.
    @State var itemWidth: CGFloat? = nil
    
    /// The total width of all items including spacing.
    @State var contentRect: CGRect? = nil
    
    /// The offset of the first element.
    @State var initialOffset: CGFloat = 0
    
    /// The additional offset of the hstack.
    @State var bounceOffset: CGFloat = 0
    
    /// Whether to allow manual scrolling.
    let navigationEnabled: Bool
    
    /// The number of scrollable items.
    let itemCount: Int
    
    /// The duration of the transition animation.
    let animationDuration: TimeInterval
    
    /// The animation to use for the bounce.
    let bounceAnimationDuration: TimeInterval
    
    /// The style of the page indicators.
    let tabIndicatorStyle: TabIndicatorStyle
    
    /// The position of the page indicators.
    let tabIndicatorPosition: TabIndicatorPosition
    
    /// How much the user needs to scroll to move to another item.
    var scrollThreshold: CGFloat {
        guard let itemWidth else {
            return 0
        }
        
        return itemWidth / 3.0
    }
    
    /// Create a tab view.
    ///
    /// - Parameters:
    ///   - itemCount: The number of tabs.
    ///   - index: The index of the currently selected tab.
    ///   - navigationEnabled: Whether gestural navigation between pages is enabled.
    ///   - tabIndicatorStyle: The style of the tab indicator.
    ///   - tabIndicatorPosition: The position of the tab indicator.
    ///   - transitionAnimationDuration: The duration of the transition animation when switching tabs.
    ///   - content: Closure to build the tab content. This builder must generate `itemCount` views of equal width
    ///    with no spacing inbetween.
    public init (itemCount: Int,
                 index: Binding<Int>,
                 navigationEnabled: Bool = true,
                 tabIndicatorStyle: TabIndicatorStyle,
                 tabIndicatorPosition: TabIndicatorPosition = .bottom,
                 transitionAnimationDuration: TimeInterval = 0.5,
                 @ViewBuilder content: () -> Content) {
        self.content = content()
        self.itemCount = itemCount
        self.navigationEnabled = navigationEnabled
        self.animationDuration = transitionAnimationDuration
        self.bounceAnimationDuration = 0.35
        self.tabIndicatorStyle = tabIndicatorStyle
        self.tabIndicatorPosition = tabIndicatorPosition
        self._externalIndex = index
        self._index = .init(initialValue: index.wrappedValue)
    }
    
    /// Update the screen parameters based on the content width.
    func updateScreenParams(_ contentRect: CGRect) {
        let itemCount = CGFloat(self.itemCount)
        
        let contentWidth = contentRect.width
        
        let itemWidth = contentWidth / itemCount
        self.itemWidth = itemWidth
        
        // Calculate Total Content Width
        self.contentRect = contentRect
        
        // Set Initial Offset to first Item
        self.initialOffset = (contentWidth / 2.0) - (itemWidth / 2.0)
        self.offset = self.offset(for: self.index)
    }
    
    /// Calculate the offset for a particular item.
    func offset(for item: Int) -> CGFloat {
        guard let itemWidth else {
            return 0
        }
        
        return Self.offset(for: item, itemWidth: itemWidth)
    }
    
    /// Calculate the offset for a particular item.
    static func offset(for item: Int, itemWidth: CGFloat) -> CGFloat {
        -CGFloat(item) * itemWidth
    }
    
    func transition(to newIndex: Int) {
        guard newIndex >= 0 && newIndex < itemCount else {
            return
        }
        
        let newOffset = self.offset(for: newIndex)
        let currentOffset = self.offset(for: index)
        let totalDistance = newOffset - currentOffset
        let remainingTime = (1 - (bounceOffset / totalDistance)) * CGFloat(animationDuration)
        
        let animation: Animation
        if bounceOffset.isZero {
            animation = .easeInOut(duration: remainingTime)
        }
        else {
            animation = .easeOut(duration: remainingTime)
        }
        
        withAnimation(animation) {
            index = newIndex
            externalIndex = newIndex
            offset = self.offset(for: newIndex)
            bounceOffset = 0
        }
    }
    
    func onDragEnded(_ event: DragGesture.Value? = nil) {
        let bounceOffset = abs(self.bounceOffset)
        let maxBounce = max(scrollThreshold, bounceOffset)
        let bouncePercentage = min(1, Double(bounceOffset) / maxBounce)
        let bounceDuration = bouncePercentage * bounceAnimationDuration
        
        guard let event = event else {
            withAnimation(.easeIn(duration: bounceDuration)) {
                self.bounceOffset = 0
            }
            
            return
        }
        
        if index > 0 && event.translation.width > scrollThreshold {
            tapDirectionForward = false
            transition(to: index - 1)
        }
        else if index < itemCount - 1 && event.translation.width < -scrollThreshold {
            tapDirectionForward = true
            transition(to: index + 1)
        }
        else {
            withAnimation(.easeIn(duration: bounceDuration)) {
                self.bounceOffset = 0
            }
        }
    }
    
    /// A hacky drag gesture to handle cancellation caused by multiple fingers.
    /// See https://stackoverflow.com/questions/58807357/detect-draggesture-cancelation-in-swiftui
    var cancellableDragGesture: some Gesture {
        let drag = DragGesture(minimumDistance: 0)
            .onChanged({ event in
                guard let itemWidth else {
                    return
                }
                
                if index == itemCount - 1 {
                    bounceOffset = max(-itemWidth * 0.3, event.translation.width)
                }
                else if index == 0 {
                    bounceOffset = min(itemWidth * 0.3, event.translation.width)
                }
                else {
                    bounceOffset = event.translation.width
                }
            })
            .onEnded({ event in
                self.onDragEnded(event)
            })
        
        let hackyPinch = MagnificationGesture(minimumScaleDelta: 0.0)
            .onChanged({ event in
                self.onDragEnded()
            })
            .onEnded({ event in
                self.onDragEnded()
            })
        
        let hackyRotation = RotationGesture(minimumAngleDelta: Angle(degrees: 0.0))
            .onChanged({ event in
                self.onDragEnded()
            })
            .onEnded({ event in
                self.onDragEnded()
            })
        
        let hackyPress = LongPressGesture(minimumDuration: 0.0, maximumDistance: 0.0)
            .onChanged({ _ in
                self.onDragEnded()
            })
            .onEnded({ delta in
                self.onDragEnded()
            })
        
        return drag
            .simultaneously(with: hackyPinch)
            .simultaneously(with: hackyRotation)
            .exclusively(before: hackyPress)
    }
    
    /// Switch to the next tab based on the current direction.
    func switchToNextTab(moveBackwards: Bool = true) {
        guard moveBackwards else {
            self.transition(to: (index + 1) % itemCount)
            return
        }
        
        if tapDirectionForward {
            if index == itemCount - 1 {
                tapDirectionForward = false
                self.transition(to: index - 1)
            }
            else {
                self.transition(to: index + 1)
            }
        }
        else {
            if index == 0 {
                tapDirectionForward = true
                self.transition(to: index + 1)
            }
            else {
                self.transition(to: index - 1)
            }
        }
    }
    
    var bodyImpl: some View {
        ZStack {
            if let contentWidth = contentRect?.width, let itemWidth {
                // Enable tap to move on the first and last items
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .frame(width: contentWidth)
                    .offset(x: -contentWidth * 0.5)
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .frame(width: contentWidth)
                    .offset(x: CGFloat(itemCount) * itemWidth - contentWidth * 0.5)
            }
            
            HStack(spacing: 0) {
                content
            }
            .padding(tabIndicatorPosition == .bottom ? .bottom : .top, tabIndicatorViewHeight(for: tabIndicatorStyle))
        }
        .offset(x: initialOffset + self.offset + bounceOffset, y: 0)
        .frame(width: itemWidth, height: contentRect?.height)
        .clipShape(Rectangle())
        .overlay(
            ZStack {
                if let contentRect {
                    VStack {
                        if case .bottom = tabIndicatorPosition {
                            Spacer()
                        }
                        
                        tabIndicatorView(index, itemCount: itemCount, style: tabIndicatorStyle)
                            .onTapGesture {
                                guard navigationEnabled else {
                                    return
                                }
                                
                                self.switchToNextTab()
                            }
                        
                        if case .top = tabIndicatorPosition {
                            Spacer()
                        }
                    }
                    .frame(maxHeight: contentRect.height)
                }
            }
        )
        .overlay(GeometryReader { geometry in
            ZStack {}
            .onAppear {
                guard self.itemWidth == nil else {
                    return
                }
                
                let worldBounds = geometry.frame(in: .global)
                self.updateScreenParams(worldBounds)
            }
        })
        .opacity(self.itemWidth == nil ? 0 : 1)
        .onChange(of: externalIndex) { newIndex in
            self.transition(to: newIndex)
        }
    }
    
    public var body: some View {
        ZStack {
            if navigationEnabled {
                bodyImpl
                    .gesture(cancellableDragGesture)
            }
            else {
                bodyImpl
            }
        }
    }
}

#if canImport(UIKit)

struct PageViewPreviews: PreviewProvider {
    static var previews: some View {
        var index = 0
        let width = UIScreen.main.bounds.width
        return VStack {
            CustomTabView(itemCount: 3, index: .init(get: { index }, set: { index = $0}),
                          navigationEnabled: true,
                          tabIndicatorStyle: .circle(color: .black)) {
                ZStack {
                    Text("Tab 1")
                }
                .frame(minWidth: width, maxHeight: .infinity)
                .background(Color.red.opacity(0.1))
                .tag(0)
                
                ZStack {
                    Text("Tab 2")
                }
                .frame(minWidth: width, maxHeight: .infinity)
                .background(Color.green.opacity(0.1))
                .tag(1)
                
                ZStack {
                    Text("Tab 3")
                }
                .frame(minWidth: width, maxHeight: .infinity)
                .background(Color.blue.opacity(0.1))
                .tag(2)
            }
        }
    }
}

#endif
#endif
