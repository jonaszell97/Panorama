
#if canImport(UIKit)
#if canImport(SwiftUI)

import SwiftUI

// The types of touches users want to be notified about
public struct TouchType: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let started = TouchType(rawValue: 1 << 0)
    public static let moved = TouchType(rawValue: 1 << 1)
    public static let ended = TouchType(rawValue: 1 << 2)
    public static let all: TouchType = [.started, .moved, .ended]
}

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-the-location-of-a-tap-inside-a-view
fileprivate struct TouchLocatingView: UIViewRepresentable {
    // A closure to call when touch data has arrived
    var onUpdate: (CGPoint) -> Void
    
    // The list of touch types to be notified of
    var types = TouchType.all
    
    // Whether touch information should continue after the user's finger has left the view
    var limitToBounds = true
    
    func makeUIView(context: Context) -> TouchLocatingUIView {
        // Create the underlying UIView, passing in our configuration
        let view = TouchLocatingUIView()
        view.onUpdate = onUpdate
        view.touchTypes = types
        view.limitToBounds = limitToBounds
        return view
    }
    
    func updateUIView(_ uiView: TouchLocatingUIView, context: Context) {
    }
    
    // The internal UIView responsible for catching taps
    class TouchLocatingUIView: UIView {
        // Internal copies of our settings
        var onUpdate: ((CGPoint) -> Void)?
        var touchTypes: TouchType = .all
        var limitToBounds = true
        
        // Our main initializer, making sure interaction is enabled.
        override init(frame: CGRect) {
            super.init(frame: frame)
            isUserInteractionEnabled = true
        }
        
        // Just in case you're using storyboards!
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            isUserInteractionEnabled = true
        }
        
        // Triggered when a touch starts.
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .started)
        }
        
        // Triggered when an existing touch moves.
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .moved)
        }
        
        // Triggered when the user lifts a finger.
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .ended)
        }
        
        // Triggered when the user's touch is interrupted, e.g. by a low battery alert.
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            send(location, forEvent: .ended)
        }
        
        // Send a touch location only if the user asked for it
        func send(_ location: CGPoint, forEvent event: TouchType) {
            guard touchTypes.contains(event) else {
                return
            }
            
            if limitToBounds == false || bounds.contains(location) {
                onUpdate?(CGPoint(x: round(location.x), y: round(location.y)))
            }
        }
    }
}

// A custom SwiftUI view modifier that overlays a view with our UIView subclass.
fileprivate struct TouchLocater: ViewModifier {
    var type: TouchType = .all
    var limitToBounds = true
    let perform: (CGPoint) -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(
                TouchLocatingView(onUpdate: perform, types: type, limitToBounds: limitToBounds)
            )
    }
}

// A new method on View that makes it easier to apply our touch locater view.
public extension View {
    func onTouch(type: TouchType = .ended, limitToBounds: Bool = true,
                 perform: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(TouchLocater(type: type, limitToBounds: limitToBounds, perform: perform))
    }
}

#endif
#endif
