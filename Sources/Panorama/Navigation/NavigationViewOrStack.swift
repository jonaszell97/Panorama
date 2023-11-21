
import SwiftUI

fileprivate struct NavigationStackPushValueEnvironmentKey: EnvironmentKey {
    static let defaultValue: Optional<(Any) -> Void> = nil
}

fileprivate extension EnvironmentValues {
    var navigationStackPushValue: Optional<(Any) -> Void> {
        get {
            return self[NavigationStackPushValueEnvironmentKey.self]
        }
        set {
            self[NavigationStackPushValueEnvironmentKey.self] = newValue
        }
    }
}

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
    
    @available(iOS 16, macOS 13, *)
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
        if #available(iOS 16, macOS 13, *) {
            navigationStackView
        }
        else {
            navigationView
                .environment(\.navigationStackPushValue) { value in
                    guard let value = value as? Data.Element else {
                        return
                    }
                    
                    self.path.append(value)
                }
        }
    }
}

public struct NavigationStackLink<Data, Label>: View
    where Label: View, Data: Hashable & Identifiable
{
    /// The link value.
    let value: Data
    
    /// Get the view for a navigation path value.
    let label: Label
    
    /// Push a new value.
    @Environment(\.navigationStackPushValue) var pushValue
    
    /// Create a navigation view.
    public init(value: Data, @ViewBuilder label: () -> Label) {
        self.value = value
        self.label = label()
    }
    
    public var body: some View {
        if #available(iOS 16, macOS 13, *) {
            NavigationLink(value: self.value) {
                label
            }
        }
        else {
            Button(action: {
                pushValue?(self.value)
            }, label: {
                label
            })
        }
    }
}
