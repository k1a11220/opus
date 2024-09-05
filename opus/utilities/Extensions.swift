import SwiftUI

extension View {
    func cardify() -> some View {
        self
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}
