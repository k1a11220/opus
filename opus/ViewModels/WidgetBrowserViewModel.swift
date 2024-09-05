import Foundation
import Combine

class WidgetBrowserViewModel: ObservableObject {
    @Published var widgets: [WidgetModel] = []
    @Published var isSubscribed: Bool = false
    
    private let subscriptionService = SubscriptionService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadWidgets()
        checkSubscriptionStatus()
    }
    
    func loadWidgets() {
        widgets = [
            WidgetModel(id: UUID(), name: "Minimal", style: .minimal, isPremium: false, previewImage: Image("minimal_preview")),
            WidgetModel(id: UUID(), name: "Elegant", style: .elegant, isPremium: true, previewImage: Image("elegant_preview")),
            WidgetModel(id: UUID(), name: "Colorful", style: .colorful, isPremium: true, previewImage: Image("colorful_preview"))
        ]
    }
    
    func checkSubscriptionStatus() {
        subscriptionService.checkSubscriptionStatus()
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSubscribed, on: self)
            .store(in: &cancellables)
    }
}
