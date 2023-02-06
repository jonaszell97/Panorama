
import SwiftUI

public struct _DynamicGridLayoutCache {
    struct Row {
        /// The indices of the subviews in this row.
        let subviewIndices: [(Int, CGFloat)]
        
        /// The size of this row's content.
        let size: CGSize
    }
    
    /// List of rows in this layout.
    var rows: [Row] = []
    
    /// The total height of the layout.
    var totalHeight: CGFloat = 0
}

/// A row-first grid layout that supports subviews with varying heights and widths.
///
/// `DynamicGrid` organizes its subviews in rows. Each row has a maximum width provided by the parent container
/// When there is not enough horizontal space remaining to place the next item in a row, the item is placed in the next row.
/// The height of any given row is defined by its tallest subview.
///
/// The alignment of subviews within a row can be specified using the `alignment` parameter. Additionally, the
/// horizontal spacing between elements within a row can be defined with the `horizontalSpacing` parameter, and the
/// vertical spacing between rows with the `verticalSpacing` parameter.
///
/// The following example shows the layout created by a `DynamicGrid` with a center `alignment`:
/// ```swift
///     DynamicGrid(alignment: .center) {
///         // ...
///     }
///     .frame(maxWidth: 150)
/// ```
/// ![DynamicGrid with center alignment](DynamicGrid_CenterAlignment)
///
/// The same grid would look like the following with leading `alignment`:
/// ```swift
///     DynamicGrid(alignment: .leading) {
///         // ...
///     }
///     .frame(maxWidth: 150)
/// ```
/// ![DynamicGrid with leading alignment](DynamicGrid_LeadingAlignment)
@available(iOS 16, macOS 13, *)
public struct DynamicGrid: Layout {
    /// The alignment of subviews within a single row of the grid.
    let alignment: HorizontalAlignment
    
    /// The horizontal spacing between elements within  a row.
    let horizontalSpacing: CGFloat
    
    /// The vertical spacing between rows.
    let verticalSpacing: CGFloat
    
    /// Create a `DynamicGrid` with specified alignment and spacing.
    ///
    /// - Parameters:
    ///   - alignment: The horizontal alignment of elements within a single row.
    ///   - horizontalSpacing: The horizontal spacing between row elements.
    ///   - verticalSpacing: The vertical spacing between rows.
    public init(alignment: HorizontalAlignment = .center, horizontalSpacing: CGFloat = 10, verticalSpacing: CGFloat = 10) {
        self.alignment = alignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .vertical
        return properties
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout _DynamicGridLayoutCache) -> CGSize {
        // Pass the size proposal on to the subviews
        let subviewSizes = subviews.map { $0.sizeThatFits(proposal) }
        
        // If the width is unbounded, return a single row containing all subviews
        guard let proposalWidth = proposal.width, proposalWidth.isFinite else {
            let maxHeight = subviewSizes.max { $0.height < $1.height }?.height ?? 0
            let totalWidth = subviewSizes.reduce(0) { $0 + $1.width }
            
            return .init(width: totalWidth, height: maxHeight)
        }
        
        cache = .init()
        
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        var currentRow = [(Int, CGFloat)]()
        
        for (i, subviewSize) in subviewSizes.enumerated() {
            let subviewWidth = subviewSize.width
            let subviewWidthWithSpacing: CGFloat
            
            // Add spacing for every view but the first
            if currentRowWidth > 0 {
                subviewWidthWithSpacing = subviewWidth + self.horizontalSpacing
            }
            else {
                subviewWidthWithSpacing = subviewWidth
            }
            
            let subviewHeight = subviewSize.height
            
            // View can fit on this row
            if currentRowWidth + subviewWidthWithSpacing <= proposalWidth {
                currentRow.append((i, subviewWidth + self.horizontalSpacing))
                currentRowWidth += subviewWidthWithSpacing
                currentRowHeight = max(currentRowHeight, subviewHeight)
            }
            // Start new row
            else {
                cache.rows.append(.init(subviewIndices: currentRow, size: .init(width: currentRowWidth, height: currentRowHeight)))
                cache.totalHeight += currentRowHeight
                
                currentRow = [(i, subviewWidth + self.horizontalSpacing)]
                currentRowWidth = subviewWidth
                currentRowHeight = subviewHeight
            }
        }
        
        if !currentRow.isEmpty {
            cache.rows.append(.init(subviewIndices: currentRow, size: .init(width: currentRowWidth, height: currentRowHeight)))
            cache.totalHeight += currentRowHeight
        }
        
        // Add vertical spacing
        if !cache.rows.isEmpty {
            cache.totalHeight += CGFloat(cache.rows.count - 1) * self.verticalSpacing
        }
        
        return .init(width: proposalWidth, height: cache.totalHeight)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout _DynamicGridLayoutCache) {
        var currentVerticalOffset: CGFloat = bounds.origin.y
        for row in cache.rows {
            var currentHorizontalOffset: CGFloat = bounds.minX
            switch self.alignment {
            case .leading:
                currentHorizontalOffset += 0
            case .trailing:
                currentHorizontalOffset += bounds.width - row.size.width
            case .center:
                fallthrough
            default:
                currentHorizontalOffset += (bounds.width - row.size.width) * 0.5
            }
            
            for (subviewIndex, subviewWidth) in row.subviewIndices {
                subviews[subviewIndex].place(at: .init(x: currentHorizontalOffset, y: currentVerticalOffset),
                                             proposal: proposal)
                
                currentHorizontalOffset += subviewWidth
            }
            
            currentVerticalOffset += row.size.height
            currentVerticalOffset += self.verticalSpacing
        }
    }
    
    public func makeCache(subviews: Subviews) -> _DynamicGridLayoutCache {
        .init()
    }
    
    public func updateCache(_ cache: inout _DynamicGridLayoutCache, subviews: Subviews) {
        cache = .init()
    }
}

@available(iOS 16, macOS 13, *)
struct DynamicGridPreviews: PreviewProvider {
    struct TagView: View {
        let text: String
        var body: some View {
            Text(verbatim: text)
                .foregroundColor(.white)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 5)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: (UIFont.preferredFont(forTextStyle: .body).pointSize + 10) * 0.5)
                        .fill(Color.cyan)
                )
        }
    }
    
    struct PreviewView: View {
        var body: some View {
            VStack {
                Spacer()
                DynamicGrid(alignment: .center) {
                    TagView(text: "A")
                    TagView(text: "B")
                    TagView(text: "C")
                    TagView(text: "DDDDDD")
                    TagView(text: "EEEEEEEEEEEEEEEEEEEE")
                    TagView(text: "FF")
                    TagView(text: "GGGGGGGGGGGGGGGGGGGGGGG")
                    TagView(text: "HHHH")
                    TagView(text: "III")
                    TagView(text: "J")
                }
                .frame(maxWidth: 150)
                
                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    static var previews: some View {
        PreviewView()
    }
}
