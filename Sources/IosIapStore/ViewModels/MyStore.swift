//  Created by Monisankar Nath on 26/11/24.

import Foundation
import StoreKit
import SwiftUI

public enum StoreError: Error {
    case failedVerification
    case noProducts
    case productRequestFailed
}

class MyStore: ObservableObject {
    @AppStorage("subscribed") private var isSubscribed: Bool = false
    @Published var apiSubscriptionPlans: [SubscriptionPlan] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published private(set) var storeProducts: [Any]
    @Published var selectedProduct: SubscriptionPlan?
    
    let sk2Store = SKTwoProductStore()
    let sk1Store = SKProductStore()
    
    let subscriptionPlanService = SubscriptionPlanService();
    let userId: String
    
    var productIds: [String] {
        return apiSubscriptionPlans.map { $0.productId }
    }
    
    var availableProducts: [SubscriptionPlan] {
        if #available(iOS 15.0, *), let products = storeProducts as? [Product] {
            return apiSubscriptionPlans.filter { plan in
                products.contains { $0.id == plan.productId }
            }
        } else if let products = storeProducts as? [SKProduct] {
            return apiSubscriptionPlans.filter { plan in
                products.contains { $0.productIdentifier == plan.productId }
            }
        } else {
            return []
        }
        
    }
    
    init(userId: String) {
        self.userId = userId
        if #available(iOS 15.0, *) {
            storeProducts = [] as [Product]
        } else {
            storeProducts = [] as [SKProduct]
        }
    }
    
    @MainActor
    func fetchSubscriptionPlans(apiKey: String) async {
        do {
            self.apiSubscriptionPlans = try await subscriptionPlanService.loadSubscriptionPlans(apiKey: apiKey)
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to load subscription plans: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    @MainActor
    func fetchStoreProducts() async {
        if(productIds.isEmpty) {
            return
        }
        
        do {
            // Use StoreKit 2 to fetch products (async/await approach)
            if #available(iOS 15.0, *) {
                let sk2Products = try await sk2Store.fetchProductsFromAppStore(for: productIds)
                storeProducts = sk2Products
            } else {
                // Use StoreKit 1 to fetch products
                let sk1Products = try await sk1Store.fetchProductsFromAppStore(for: productIds)
                storeProducts = sk1Products
            }
            print("StoreProducts fetched = \(storeProducts)")
        } catch {
            let errMsg = "Failed to fetch App Store products: \(error.localizedDescription)"
            errorMessage = errMsg
            print(errMsg)
        }
    }
    
    
    
}
