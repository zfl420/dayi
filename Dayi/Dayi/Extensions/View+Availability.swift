import SwiftUI

extension View {
    @ViewBuilder
    func iOS16SheetPresentation() -> some View {
        if #available(iOS 16.0, *) {
            self
                .presentationDetents([.fraction(0.99)])
                .presentationDragIndicator(.visible)
        } else {
            self
        }
    }

    @ViewBuilder
    func iOS16NavigationBarHidden() -> some View {
        if #available(iOS 16.0, *) {
            self.toolbar(.hidden, for: .navigationBar)
        } else {
            self.navigationBarHidden(true)
        }
    }

    @ViewBuilder
    func iOS16ToolbarBackgroundHidden() -> some View {
        if #available(iOS 16.0, *) {
            self.toolbarBackground(.hidden, for: .navigationBar)
        } else {
            self
        }
    }
}
