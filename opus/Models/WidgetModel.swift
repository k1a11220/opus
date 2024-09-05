import SwiftUI

struct WidgetModel: Identifiable {
    let id: UUID
    let name: String
    let style: WidgetStyle
    let isPremium: Bool
    let previewImage: Image
}
