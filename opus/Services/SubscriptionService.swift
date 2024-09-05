import StoreKit
import Combine

class SubscriptionService {
    private let productIdentifier = "com.yourdomain.opus.subscription"
    
    func checkSubscriptionStatus() -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            Task {
                for await result in Transaction.currentEntitlements {
                    if case .verified(let transaction) = result {
                        if transaction.productID == self.productIdentifier {
                            promise(.success(true))
                            return
                        }
                    }
                }
                promise(.success(false))
            }
        }.eraseToAnyPublisher()
    }
    
    func purchaseSubscription() async throws -> Bool {
        let products = try await Product.products(for: [productIdentifier])
        guard let product = products.first else {
            throw SubscriptionError.productNotFound
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verificationResult):
            switch verificationResult {
            case .verified(let transaction):
                await transaction.finish()
                return true
            case .unverified:
                return false
            }
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }
    
    enum SubscriptionError: Error {
        case productNotFound
    }
}
