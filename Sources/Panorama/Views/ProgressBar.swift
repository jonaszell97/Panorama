
import SwiftUI
import Toolbox

/// A customizable progress bar view.
///
/// The `ProgressBar` is displayed as a pill-shaped bar that fills from left to right based on the current
/// the progress percentage. Additionally, the percentage is displayed as text over the progress bar shape.
///
/// The following example shows the usage of a `ProgressBar`:
/// ```swift
/// ProgressBar(backgroundColor: .gray, foregroundColor: .cyan,
///             size: .init(width: 250, height: 30), progress: progress)
/// ```
/// ![A progress bar view.](ProgressBar)
public struct ProgressBar: View {
    struct RectangleProgressShape: Shape, Animatable {
        var animatableData: CGFloat
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move   (to: .init(x: rect.minX,                                 y: rect.minY))
            path.addLine(to: .init(x: rect.minX,                                 y: rect.maxY))
            path.addLine(to: .init(x: rect.minX + (animatableData * rect.width), y: rect.maxY))
            path.addLine(to: .init(x: rect.minX + (animatableData * rect.width), y: rect.minY))
            path.addLine(to: .init(x: rect.minX,                                 y: rect.minY))
            
            return path
        }
    }
    
    /// The color of the unfilled part of the progress bar.
    let backgroundColor: Color
    
    /// The color of the filled part of the progress bar.
    let foregroundColor: Color
    
    /// The size of the progress bar.
    let size: CGSize
    
    /// The current progress percentage in interval [0,1].
    let progress: Double
    
    /// Create a progress bar.
    ///
    /// - Parameters:
    ///   - backgroundColor: The color of the unfilled portion of the progress bar.
    ///   - foregroundColor: The color of the filled portion of the progress bar.
    ///   - size: The size of the progress bar.
    ///   - progress: The current progress percentage in [0, 1].
    public init(backgroundColor: Color, foregroundColor: Color, size: CGSize, progress: Double) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.size = size
        self.progress = progress
    }
    
    public var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)
                .cornerRadius(size.height*0.5)
            
            HStack {
                Rectangle()
                    .fill(foregroundColor)
                    .cornerRadius(size.height*0.5)
                    .clipShape(RectangleProgressShape(animatableData: CGFloat(progress)))
            }
            
            Text(verbatim: FormatToolbox.formatPercentage(progress.rounded(toDecimalPlaces: 2)))
                .foregroundColor(.white)
                .font(.system(size: size.height * 0.75).monospacedDigit())
        }
        .frame(width: size.width, height: size.height)
    }
}

@available(iOS 15, *)
struct ProgressBar_Previewsss: PreviewProvider {
    struct PreviewView: View {
        @State var progress: Double = 0
        
        func increase() {
            self.progress += 0.01
            if self.progress < 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    self.increase()
                }
            }
        }
        
        var body: some View {
            ProgressBar(backgroundColor: .gray, foregroundColor: .cyan,
                        size: .init(width: 250, height: 30), progress: progress)
                .onAppear {
                    self.increase()
                }
        }
    }
    
    static var previews: some View {
        PreviewView()
    }
}
