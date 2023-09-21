
import SwiftUI
import Toolbox

fileprivate func staticDigitView(digit: Int?) -> some View {
    Text(verbatim: FormatToolbox.format(digit ?? 0))
        .opacity(digit == nil ? 0 : 1)
}

fileprivate func animatedDigitView(digit: Int?, offset: Double, nextDigit: Int?,
                                   height: CGFloat, direction: AnimatedDigitView.Direction = .decreasing) -> some View {
    let startDigit = digit
    let endDigit = nextDigit
    let multiplier: CGFloat = direction == .increasing ? -1 : 1
    
    return ZStack {
        if startDigit == nil {
            Text(verbatim: FormatToolbox.format(startDigit ?? 0))
                .opacity(0)
                .offset(x: 0, y: offset * multiplier)
        }
        else {
            Text(verbatim: FormatToolbox.format(startDigit ?? 0))
                .opacity(1 - abs(offset / height))
                .offset(x: 0, y: offset * multiplier)
        }
        
        if endDigit == nil {
            Text(verbatim: FormatToolbox.format(endDigit ?? 0))
                .opacity(0)
                .offset(x: 0, y: (-height + offset) * multiplier)
        }
        else {
            Text(verbatim: FormatToolbox.format(endDigit ?? 0))
                .opacity(abs(offset / height))
                .offset(x: 0, y: (-height + offset) * multiplier)
        }
    }
    .transition(.identity)
}

/// A view that counts up or down from one digit to another with a slot-machine style animation.
public struct AnimatedDigitView: View {
    /// The moving direction.
    public enum Direction: String {
        case decreasing
        case increasing
        case closest
    }
    
    /// The starting value of the counter.
    let startDigit: Int
    
    /// The ending value of the counter.
    let endDigit: Int
    
    /// The direction of the move.
    let direction: Direction
    
    /// The font size to use.
    let height: CGFloat
    
    /// The animation duration.
    let animationDuration: Double
    
    /// The animation delay.
    let animationDelay: Double
    
    /// Animation completion callback.
    let onAnimationComplete: Optional<() -> Void>
    
    /// The active digit animations.
    @State var displayDigit: Int?
    
    /// The active digit animations.
    @State var digitAnimation: (Double, Int?)?
    
    /// The actual direction.
    @State var finalDirection: Direction = .increasing
    
    /// Memberwise initializer
    public init(startDigit: Int, endDigit: Int, direction: Direction,
                height: CGFloat, animationDuration: Double,
                animationDelay: Double,
                onAnimationComplete: Optional<() -> Void> = nil) {
        self.startDigit = startDigit
        self.endDigit = endDigit
        self.direction = direction
        self.height = height
        self.animationDuration = animationDuration
        self.animationDelay = animationDelay
        self.onAnimationComplete = onAnimationComplete
        self._displayDigit = .init(initialValue: nil)
        self._digitAnimation = .init(initialValue: nil)
    }
    
    func startAnimation() {
        let numberOfSteps: Int
        let direction: Direction
        
        switch self.direction {
        case .decreasing:
            if endDigit <= startDigit {
                numberOfSteps = startDigit - endDigit
            }
            else {
                numberOfSteps = 10 - (endDigit - startDigit)
            }
            direction = .decreasing
        case .increasing:
            if endDigit >= startDigit {
                numberOfSteps = endDigit - startDigit
            }
            else {
                numberOfSteps = 10 - (startDigit - endDigit)
            }
            direction = .increasing
        case .closest:
            let stepsIncreasing, stepsDecreasing: Int
            if endDigit <= startDigit {
                stepsDecreasing = startDigit - endDigit
                stepsIncreasing = 10 - (startDigit - endDigit)
            }
            else {
                stepsDecreasing = 10 - (endDigit - startDigit)
                stepsIncreasing = endDigit - startDigit
            }
            
            if stepsIncreasing > stepsDecreasing {
                direction = .decreasing
                numberOfSteps = stepsDecreasing
            }
            else {
                direction = .increasing
                numberOfSteps = stepsIncreasing
            }
        }
        
        let singleStepDuration = animationDuration / Double(numberOfSteps)
        var delay = animationDelay
        
        let sequence = AnimationSequence()
        var currentDigit = startDigit
        
        while currentDigit != endDigit {
            let nextDigit: Int
            switch direction {
            case .decreasing:
                if currentDigit == 0 {
                    nextDigit = 9
                }
                else {
                    nextDigit = currentDigit - 1
                }
            case .increasing:
                nextDigit = (currentDigit + 1) % 10
            case .closest:
                fatalError("direction should have been set")
            }
            
            sequence.append(delay: delay) {
                self.digitAnimation = (0, nextDigit)
            }
            
            sequence.append(animation: .linear(duration: singleStepDuration),
                            duration: singleStepDuration) {
                self.digitAnimation = (Double(height), nextDigit)
            }
            
            sequence.append {
                self.displayDigit = nextDigit
                self.digitAnimation = nil
            }
            
            delay = 0
            currentDigit = nextDigit
        }
        
        self.displayDigit = startDigit
        self.finalDirection = direction
        
        sequence.append {
            self.onAnimationComplete?()
        }
        
        sequence.execute()
    }
    
    public var body: some View {
        ZStack {
            if let (rotationAngle, nextDigit) = digitAnimation {
                animatedDigitView(digit: displayDigit, offset: rotationAngle, nextDigit: nextDigit,
                                  height: height, direction: finalDirection)
            }
            else {
                staticDigitView(digit: displayDigit)
            }
        }
        .clipShape(Rectangle())
        .onAppear {
            self.startAnimation()
        }
    }
}

/// A view that counts up or down from one number to another with a slot-machine style animation
///
/// `CounterView` displays the current count as a horizontal stack of digits. Digit changes are animated
/// by sliding in a new digit from above while sliding down the current digit. The step size of the animation is
/// ajdusted based on the distance between the start and end values.
///
/// This example creates a `CounterView` that animates in steps of 1:
/// ```swift
/// CounterView(startValue: 25, endValue: 15, fontSize: 50, fontColor: .black, animationDuration: 1)
/// ```
/// ![A CounterView counting down from 25 to 15](CounterView_Step1)
/// 
/// This example creates a `CounterView` that animates in steps of 10:
/// ```swift
/// CounterView(startValue: 1050, endValue: 950, fontSize: 50, fontColor: .black)
/// ```
/// ![A CounterView counting down from 1,050 to 950](CounterView_Step10)
public struct CounterView: View {
    /// The starting value of the counter.
    let startValue: Int
    
    /// The ending value of the counter.
    let endValue: Int
    
    /// The font size to use.
    let height: CGFloat
    
    /// The animation duration.
    let animationDuration: Double
    
    /// The animation delay.
    let animationDelay: Double
    
    /// Animation completion callback.
    var onAnimationComplete: Optional<() -> Void>
    
    /// The digits of the start value.
    private let startValueDigits: [Int?]
    
    /// The digits of the end value.
    private let endValueDigits: [Int?]
    
    /// The active digit animations.
    @State var displayDigits: [Int?]
    
    /// The active digit animations.
    @State var digitAnimations: [(Double, Int?)?]
    
    
    /// Create a counter view.
    ///
    /// - Parameters:
    ///   - startValue: The value the counter starts from.
    ///   - endValue: The value the counter ends at.
    ///   - fontSize: The font size of the counter.
    ///   - fontColor: The color of the counter.
    ///   - animationDuration: The duration of the counting animation.
    ///   - animationDelay: The delay of the counting animation.
    ///   - onAnimationComplete: Callback to invoke once the animation completes.
    public init(startValue: Int, endValue: Int,
                height: CGFloat,
                animationDuration: Double? = nil,
                animationDelay: Double = 0,
                onAnimationComplete: Optional<() -> Void> = nil) {
        self.startValue = startValue
        self.endValue = endValue
        self.height = height
        self.onAnimationComplete = onAnimationComplete
        self.animationDuration = animationDuration ?? Self.defaultAnimationDuration(startValue: startValue, endValue: endValue)
        self.animationDelay = animationDelay
        
        var startValueDigits = startValue.digits.map { $0 as Int? }
        var endValueDigits = endValue.digits.map { $0 as Int? }
        
        if startValueDigits.count > endValueDigits.count {
            while startValueDigits.count > endValueDigits.count {
                endValueDigits.insert(nil, at: 0)
            }
        }
        else {
            while startValueDigits.count < endValueDigits.count {
                startValueDigits.insert(nil, at: 0)
            }
        }
        
        self.startValueDigits = startValueDigits
        self.endValueDigits = endValueDigits
        self._digitAnimations = .init(initialValue: .init(repeating: nil, count: self.startValueDigits.count))
        self._displayDigits = .init(initialValue: self.startValueDigits)
    }
    
    /// - Returns: The default animation duration counting from `startValue` to `endValue`.
    public static func defaultAnimationDuration(startValue: Int, endValue: Int) -> TimeInterval {
        let difference = abs(startValue - endValue)
        switch difference {
        case 1:
            return 0.35
        case 2...4:
            return 0.5
        case 5...50:
            return TimeInterval(difference) * 0.05
        default:
            return 2
        }
    }
    
    func startAnimation() {
        var sequences = [AnimationSequence]()
        for _ in 0..<displayDigits.count {
            sequences.append(AnimationSequence())
        }
        
        let difference = abs(endValue - startValue)
        
        let numberOfSteps: Int
        var stepSize: Int
        var firstStepSize: Int?
        
        if difference < 20 {
            numberOfSteps = difference
            stepSize = 1
            firstStepSize = nil
        }
        else {
            let step: Int
            if difference < 50 {
                step = 2
            }
            else if difference < 100 {
                step = 5
            }
            else if difference < 250 {
                step = 10
            }
            else if difference < 500 {
                step = 25
            }
            else if difference < 1000 {
                step = 50
            }
            else {
                step = 10 ** (Int(log10(Double(difference))) - 1)
            }
            
            numberOfSteps = (difference / step) + 1
            stepSize = step
            firstStepSize = step - (startValue % step)
        }
        
        let singleStepDuration = animationDuration / Double(numberOfSteps)
        var currentValue = startValue
        var delay = animationDelay
        
        while currentValue != endValue {
            var step: Int
            if let firstStep = firstStepSize {
                step = firstStep
                firstStepSize = nil
            }
            else {
                step = stepSize
            }
            
            let nextValue: Int
            if endValue > startValue {
                if currentValue + step > endValue {
                    step = endValue - currentValue
                }
                
                nextValue = currentValue + step
            }
            else {
                if currentValue - step < endValue {
                    step = endValue - currentValue
                }
                
                nextValue = currentValue - step
            }
            
            let visibleDigits = MathsToolbox.requiredDigits(nextValue, base: 10)
            for i in 0..<displayDigits.count {
                let digitPosition = displayDigits.count - 1 - i
                let power = 10 ** i
                
                // Check if there is a change in this digit
                let previous = currentValue / power
                let next = nextValue / power
                
                let sequence = sequences[i]
                if previous != next {
                    let nextDigit: Int? = (i >= visibleDigits && next == 0) ? nil : next % 10
                    sequence.append(delay: delay) {
                        self.digitAnimations[digitPosition] = (0, nextDigit)
                    }
                    
                    sequence.append(animation: .linear(duration: singleStepDuration),
                                    duration: singleStepDuration) {
                        self.digitAnimations[digitPosition] = (Double(height), nextDigit)
                    }
                    
                    sequence.append {
                        self.displayDigits[digitPosition] = nextDigit
                        self.digitAnimations[digitPosition] = nil
                    }
                }
                else {
                    sequence.append(delay: delay) {}
                    sequence.append(delay: singleStepDuration) {}
                    sequence.append {}
                }
            }
            
            delay = 0
            currentValue = nextValue
        }
        
        sequences.first?.append {
            self.onAnimationComplete?()
        }
        
        for sequence in sequences {
            sequence.execute()
        }
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<displayDigits.count, id: \.self) { i in
                if let (rotationAngle, nextDigit) = digitAnimations[i] {
                    animatedDigitView(digit: displayDigits[i], offset: rotationAngle, nextDigit: nextDigit,
                                      height: height)
                }
                else {
                    staticDigitView(digit: displayDigits[i])
                }
            }
            .clipShape(Rectangle())
        }
        .onAppear {
            self.startAnimation()
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CounterView(startValue: 1050, endValue: 950, height: 50)
            
            AnimatedDigitView(startDigit: 9, endDigit: 5, direction: .decreasing,
                              height: 50, animationDuration: 2,
                              animationDelay: 0)
            
            AnimatedDigitView(startDigit: 9, endDigit: 5, direction: .increasing,
                              height: 50, animationDuration: 2,
                              animationDelay: 0)
            
            AnimatedDigitView(startDigit: 5, endDigit: 7, direction: .decreasing,
                              height: 50, animationDuration: 2,
                              animationDelay: 0)
        }
        .font(.system(size: 50))
        .foregroundColor(.black)
    }
}
