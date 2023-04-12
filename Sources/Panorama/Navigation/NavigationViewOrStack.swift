
import SwiftUI

public struct NavigationViewOrStack<Data, Root, Content>: View
    where Root: View, Content: View,
          Data: MutableCollection, Data: RandomAccessCollection,
          Data: RangeReplaceableCollection,
          Data: Hashable,
          Data.Element: Hashable & Identifiable
{
    /// The navigation path data.
    @Binding var path: Data
    
    /// List of all possible values of the navigation path.
    @State var allNavigationValues: Set<Data.Element> = []
    
    /// Get the view for a navigation path value.
    let createView: (Data.Element) -> Content
    
    /// The navigation root view.
    let root: Root
    
    /// Create a navigation view.
    public init(path: Binding<Data>, createView: @escaping (Data.Element) -> Content, @ViewBuilder root: () -> Root) {
        self._path = path
        self.createView = createView
        self.root = root()
    }
    
    @available(iOS 16, *)
    var navigationStackView: some View {
        NavigationStack(path: $path) {
            root
                .navigationDestination(for: Data.Element.self) { subview in
                    self.createView(subview)
                }
        }
    }
    
    var navigationView: some View {
        NavigationView {
            ZStack {
                ForEach(allNavigationValues.map { $0 }) { value in
                    NavigationLink(isActive: .init(get: {
                        self.path.last == value
                    }, set: {
                        if $0 {
                            self.path.append(value)
                        }
                        else {
                            _ = self.path.popLast()
                        }
                    }), destination: {
                        self.createView(value)
                    }, label: {
                        EmptyView()
                    })
                }
                
                root
            }
        }
        .onChange(of: path) { path in
            self.allNavigationValues.insert(contentsOf: path)
        }
    }
    
    public var body: some View {
        if #available(iOS 16, *) {
            navigationStackView
        }
        else {
            navigationView
        }
    }
}
