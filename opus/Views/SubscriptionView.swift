import SwiftUI

struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Upgrade to Premium")
                .font(.title)
            
            Text("Get access to all widget designs")
                .font(.subheadline)
            
            if viewModel.isSubscribed {
                Text("You are a premium subscriber")
                    .foregroundColor(.green)
            } else {
                Button("Subscribe - $2.99/month") {
                    viewModel.purchase()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Subscription"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

class SubscriptionViewModel: ObservableObject {
    @Published var isSubscribed = false
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private let subscriptionService = SubscriptionService()
    
    init() {
        checkSubscriptionStatus()
    }
    
    func checkSubscriptionStatus() {
        subscriptionService.checkSubscriptionStatus()
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSubscribed, on: self)
            .store(in: &cancellables)
    }
    
    func purchase() {
        isLoading = true
        Task {
            do {
                let success = try await subscriptionService.purchaseSubscription()
                await MainActor.run {
                    isLoading = false
                    isSubscribed = success
                    showAlert = true
                    alertMessage = success ? "Subscription successful!" : "Subscription failed. Please try again."
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showAlert = true
                    alertMessage = "An error occurred: \(error.localizedDescription)"
                }
            }
        }
    }
}
