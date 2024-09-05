import StoreKit

class StoreKitManager: ObservableObject {
    @Published var isPremium = false
    
    private var products: [Product] = []
    private var purchaseListener: Task<Void, Error>?
    
    init() {
        setupPurchaseListener()
        Task {
            await requestProducts()
        }
    }
    
    deinit {
        purchaseListener?.cancel()
    }
    
    func purchasePremium() {
        Task {
            guard let product = products.first else { return }
            do {
                if try await product.purchase() != nil {
                    isPremium = true
                }
            } catch {
                print("Failed to purchase: \(error)")
            }
        }
    }
    
    private func setupPurchaseListener() {
        purchaseListener = Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                }
            }
        }
    }
    
    private func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: ["com.yourdomain.newsapp.premium"])
            DispatchQueue.main.async {
                self.products = storeProducts
            }
        } catch {
            print("Failed to request products: \(error)")
        }
    }
    
    private func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                DispatchQueue.main.async {
                    self.isPremium = true
                }
            }
        }
    }
}
