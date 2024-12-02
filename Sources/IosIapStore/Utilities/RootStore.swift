//  Created by Monisankar Nath on 26/11/24.

import Foundation
import StoreKit
import SwiftUI

public enum StoreError: Error {
    case failedVerification
    case noProducts
    case productRequestFailed
    case purchaseProductFailed
}

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

class RootStore: ObservableObject {
    @AppStorage("subscribed") private var isSubscribed: Bool = false
    @Published var apiSubscriptionPlans: [SubscriptionPlan] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published private(set) var storeProducts: [Product] = []
    @Published var selectedProduct: SubscriptionPlan?
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var availableProducts: [SubscriptionPlan] = []
    @Published private(set) var productIds: [String] = []
    @Published private(set) var subscriptionGroupStatus: RenewalState?
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    let sk2Store = SKProductStore()
    
    let subscriptionPlanService = SubscriptionPlanService();
    let userId: String
    let apiKey: String
    
    init(userId: String, apiKey: String) {
        self.userId = userId
        self.apiKey = apiKey
        updateListenerTask = listenForTransactions()
    }
    deinit {
        updateListenerTask?.cancel()
    }
    
    @MainActor
    private func updateAvaiableProducts() {
        availableProducts = apiSubscriptionPlans.filter { plan in
            storeProducts.contains { $0.id == plan.productId }
        }
    }
    @MainActor
    private func updateProductIds() {
        productIds = apiSubscriptionPlans.map { $0.productId };
    }
    
    
    @MainActor
    func fetchSubscriptionPlans(apiKey: String) async {
        do {
            self.apiSubscriptionPlans = try await subscriptionPlanService.loadSubscriptionPlans(apiKey: apiKey)
            print("fetchSubscriptionPlans = \(apiSubscriptionPlans.count)")
            self.updateProductIds();
        } catch {
            self.errorMessage = "Failed to load subscription plans: \(error.localizedDescription)"
            self.isLoading = false
            print("fetchSubscriptionPlans - \(error)")
        }
    }
    
    @MainActor
    func fetchStoreProducts() async {
        if(productIds.isEmpty) {
            errorMessage = "No Products available."
            self.isLoading = false
            return
        }
        
        do {
            let sk2Products = try await sk2Store.fetchProductsFromAppStore(for: productIds)
            storeProducts = sk2Products
            print("fetchStoreProducts = \(sk2Products.count)")
            self.updateAvaiableProducts();
            self.isLoading = false
        } catch {
            let errMsg = "Failed to fetch App Store products: \(error.localizedDescription)"
            errorMessage = errMsg
            print("fetchStoreProducts - \(error)")
            self.isLoading = false
        }
    }
    
    @MainActor
    func purchaseProduct(with productId: String) async {
        guard let product = storeProducts.first(where: { $0.id == productId }) else {
            errorMessage = "Product not found in App Store"
            return
        }
        do {
            let result = try await product.purchase()
//            print("purchaseProduct result - \(result)")
            switch result {
            case .success(let verification):
                let transaction = try sk2Store.checkVerified(verification)
//                print("purchase done - \(transaction)")
                try await sk2Store.sendTransactionDetails(for: transaction, with: userId, using: apiKey)
            
                await updateCustomerProductStatus()
                
                await transaction.finish()
                errorMessage = nil
            case .userCancelled:
                errorMessage = "User cancelled the purchase"
    
            case .pending:
                errorMessage = "Purchase is pending"
               
            default:
                errorMessage = "Unknown purchase result"
               
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
        
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSubs: [Product] = []

        var latestTransactions: [String: Transaction] = [:]

        for await result in Transaction.currentEntitlements {
            do{
                let transaction = try sk2Store.checkVerified(result)
                print("transaction currentEntitlements = \(transaction)")
                guard let groupID = sk2Store.getSubscriptionGroupIdentifier(for: transaction, from: storeProducts) else {
                    continue // Skip transactions without a group ID
                }

                // Compare with existing transaction for the group and keep the latest one
                if let existingTransaction = latestTransactions[groupID] {
                    if transaction.purchaseDate > existingTransaction.purchaseDate {
                        latestTransactions[groupID] = transaction
                    }
                } else {
                    // First transaction for this group
                    latestTransactions[groupID] = transaction
                }
            } catch {
                errorMessage = "Could not find products. \(error.localizedDescription)"
            }
            
        }

        let latestTransactionProductIDs = Set(Array(latestTransactions.values).map { $0.productID })
        purchasedSubs = storeProducts.filter { product in
            latestTransactionProductIDs.contains(product.id)
        }
        
        self.purchasedSubscriptions = purchasedSubs
        
        subscriptionGroupStatus = try? await storeProducts.first?.subscription?.status.first?.state
        await updateSubscriptionStatus()
        
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        if subscriptionGroupStatus == .subscribed || subscriptionGroupStatus == .inGracePeriod {
            isSubscribed = true
        } else {
            isSubscribed = false
        }
    }
    
    func isProductPurchased(with productId: String) -> Bool {
        if let product = storeProducts.first(where: {$0.id == productId}) {
            return purchasedSubscriptions.contains(product)
        }
        return false
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        print("listenForTransactions")
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try result.payloadValue
                    print("transaction details - \(transaction)")
//                    await self.updateCustomerProductStatus()
                    
                    await transaction.finish()
                } catch {
//                    self.errorMessage = "Transaction failed verification"
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    func subscribeButtonTitle() -> String {
        guard let selectedPlan = selectedProduct else { return "Select a Plan" }
        if isProductPurchased(with: selectedPlan.productId) {
            return "Subscribed"
        } else {
            return "Change Plan"
        }
    }
        
    func isSubscribeButtonDisabled() -> Bool {
        guard let selectedPlan = selectedProduct else { return true }
        return isProductPurchased(with: selectedPlan.productId)
    }
    
}
