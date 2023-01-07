
import SwiftUI
import Toolbox

public struct CounterView: View {
    /// The starting value of the counter.
    let startValue: Int
    
    /// The ending value of the counter.
    let endValue: Int
    
    /// The font size to use.
    let fontSize: CGFloat
    
    /// The font color to use.
    let fontColor: Color
    
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
    
    /// Default initializer.
    public init(startValue: Int, endValue: Int,
                fontSize: CGFloat, fontColor: Color,
                animationDuration: Double? = nil,
                animationDelay: Double = 0,
                onAnimationComplete: Optional<() -> Void> = nil) {
        self.startValue = startValue
        self.endValue = endValue
        self.fontSize = fontSize
        self.fontColor = fontColor
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
    
    func staticDigitView(digit: Int?) -> some View {
        Text(verbatim: FormatToolbox.format(digit ?? 0))
            .font(.system(size: fontSize).monospacedDigit())
            .foregroundColor(fontColor)
            .opacity(digit == nil ? 0 : 1)
    }
    
    func animatedDigitView(digit: Int?, offset: Double, nextDigit: Int?) -> some View {
        let startDigit = digit
        let endDigit = nextDigit
        
        return ZStack {
            if startDigit == nil {
                Text(verbatim: FormatToolbox.format(startDigit ?? 0))
                    .font(.system(size: fontSize).monospacedDigit())
                    .foregroundColor(fontColor)
                    .opacity(0)
                    .offset(x: 0, y: offset)
            }
            else {
                Text(verbatim: FormatToolbox.format(startDigit ?? 0))
                    .font(.system(size: fontSize).monospacedDigit())
                    .foregroundColor(fontColor)
                    .opacity(1 - abs(offset / fontSize))
                    .offset(x: 0, y: offset)
            }
            
            if endDigit == nil {
                Text(verbatim: FormatToolbox.format(endDigit ?? 0))
                    .font(.system(size: fontSize).monospacedDigit())
                    .foregroundColor(fontColor)
                    .opacity(0)
                    .offset(x: 0, y: -fontSize + offset)
            }
            else {
                Text(verbatim: FormatToolbox.format(endDigit ?? 0))
                    .font(.system(size: fontSize).monospacedDigit())
                    .foregroundColor(fontColor)
                    .opacity(abs(offset / fontSize))
                    .offset(x: 0, y: -fontSize + offset)
            }
        }
        .transition(.identity)
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
                        self.digitAnimations[digitPosition] = (Double(fontSize), nextDigit)
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
                    animatedDigitView(digit: displayDigits[i], offset: rotationAngle, nextDigit: nextDigit)
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
        CounterView(startValue: 1050, endValue: 950, fontSize: 50, fontColor: .black)
    }
}
