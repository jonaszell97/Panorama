
import SwiftUI
import Toolbox

#if DEBUG

fileprivate extension Log {
    static var animationSequence = Toolbox.Logger(subsystem: "com.jonaszell.AppUtilities", category: "AnimationSequence")
}

#endif

/// An animation sequence allows the execution of several animation steps (and other functions) one after the other with
/// customizable timing.
public class AnimationSequence {
    public enum AnimationSequenceAction {
        /// An animation.
        case animation(function: () -> Void, animation: Animation?, duration: Double, delay: Double)
        
        /// A plain function.
        case function(function: () -> Void, delay: Double)
        
        /// A delay.
        case delay(delay: Double)
        
        /// A suspension point.
        case suspension
        
        /// The delay of this action.
        var delay: TimeInterval {
            switch self {
            case .animation(_, _, _, let delay):
                return delay
            case .function(_, let delay):
                return delay
            case .delay(let delay):
                return delay
            case .suspension:
                return 0
            }
        }
        
        /// The duration of this action.
        var duration: TimeInterval {
            switch self {
            case .animation(_, _, let duration, _):
                return duration
            default:
                return 0
            }
        }
        
        /// The function related to this action.
        var function: Optional<() -> Void> {
            switch self {
            case .animation(let function, _, _, _):
                return function
            case .function(let function, _):
                return function
            default:
                return nil
            }
        }
    }
    
    /// The animations to execute.
    public var actions: [AnimationSequenceAction]
    
    /// The total animation duration.
    public var totalDuration: Double
    
    /// The current execution index.
    public var currentIndex: Int = 0
    
    /// Whether or not the execution of this sequence has been stopped.
    public var stopped: Bool = false
    
    /// Whether this sequence was ever started.
    private var didStartExecution: Bool = false

    /// Runs a step after a delay. Steps are scheduled on the main queue unless
    /// the caller supplies its own scheduler, e.g. to drive a sequence from a
    /// test clock.
    private let schedule: (TimeInterval, @escaping () -> Void) -> Void

    /// The default scheduler: the main queue, without a deadline for zero delays.
    public static let mainQueue: (TimeInterval, @escaping () -> Void) -> Void = { delay, work in
        if delay.isZero {
            DispatchQueue.main.async(execute: work)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        }
    }

    /// Create an animation sequence. Actions can be specified here or added later.
    ///
    /// - Parameters:
    ///   - actions: The actions in the sequence.
    ///   - schedule: Runs a step after the given delay. Defaults to the main queue.
    public init(actions: [AnimationSequence.AnimationSequenceAction] = [],
                schedule: @escaping (TimeInterval, @escaping () -> Void) -> Void = AnimationSequence.mainQueue) {
        self.actions = actions
        self.totalDuration = 0
        self.schedule = schedule
    }
    
    deinit {
        guard !didStartExecution else {
            return
        }
        
        #if DEBUG
        Log.animationSequence.warning("AnimationSequence \(ObjectIdentifier(self).debugDescription) went out of scope without being executed")
        #endif
    }
    
    /// Append an animated action to this sequence.
    ///
    /// - Parameters:
    ///   - animation: The animation to use.
    ///   - duration: The duration of the animation.
    ///   - delay: The delay of the animation.
    ///   - function: The action that is invoked with the given animation.
    /// - Returns: Returns `self` for method chaining.
    @discardableResult public func append(animation: Animation?,
                                          duration: Double = 0.35,
                                          delay: Double = 0,
                                          function: @escaping () -> Void) -> AnimationSequence {
        actions.append(.animation(function: function, animation: animation, duration: duration, delay: delay))
        
        totalDuration += duration
        totalDuration += delay
        
        return self
    }
    
    /// Append an action to this sequence.
    ///
    /// - Parameters:
    ///   - delay: The delay of the action.
    ///   - function: The action callback
    /// - Returns: Returns `self` for method chaining.
    @discardableResult public func append(delay: Double = 0,
                                          function: @escaping () -> Void) -> AnimationSequence {
        actions.append(.function(function: function, delay: delay))
        totalDuration += delay
        
        return self
    }
    
    /// Append a pre-created sequence element to thsi sequence.
    ///
    /// - Parameter action: The action to append.
    /// - Returns: Returns `self` for method chaining.
    @discardableResult public func append(_ action: AnimationSequenceAction) -> AnimationSequence {
        actions.append(action)
        totalDuration += action.duration
        totalDuration += action.delay
        
        return self
    }
    
    /// Execute the animation sequence.
    ///
    /// - Returns: The estimated duration of the sequence execution in seconds.
    @discardableResult public func execute() -> Double {
        self.didStartExecution = true
        
        guard actions.count > 0 else {
            return 0
        }
        
        schedule(actions[0].delay) {
            self.execute(at: 0)
        }

        return totalDuration
    }
    
    /// Execute this animation sequence without any animations.
    public func executeWithoutAnimations() {
        self.didStartExecution = true
        
        for action in actions {
            action.function?()
        }
    }
    
    /// Continue a suspended sequence. This will report a critical error if the sequence has not previously been suspended.
    public func resume() {
        guard case .suspension = self.actions[self.currentIndex] else {
            Log.reportCriticalError("resuming a non-suspended sequence")
            return
        }
        
        self.currentIndex += 1
        self.execute(at: self.currentIndex)
    }
    
    /// Stop this sequence.
    public func stop() {
        self.stopped = true
    }
    
    /// Skip to the given point in the sequence.
    /// 
    /// - Parameter index: The index that should be moved to.
    public func skip(to index: Int) {
        guard self.actions.count > index else {
            Log.reportCriticalError("trying to skip to index \(index) in AnimationSequence with \(self.actions.count) actions")
            return
        }
        
        self.stopped = true

        schedule(0) {
            self.execute(at: index, force: true)
        }
    }
    
    /// Execute the specified animation and schedule the next one.
    private func execute(at index: Int, force: Bool = false) {
        guard force || !stopped else {
            return
        }
        
        let action = actions[index]
        self.currentIndex = index
        
        switch action {
        case .animation(let function, let animation, _, _):
            withAnimation(animation) {
                function()
            }
        case .function(let function, _):
            function()
        case .delay:
            break
        case .suspension:
            return
        }
        
        if index + 1 >= actions.count {
            return
        }
        
        schedule(action.duration + actions[index + 1].delay) {
            self.execute(at: index + 1, force: force)
        }
    }
}

