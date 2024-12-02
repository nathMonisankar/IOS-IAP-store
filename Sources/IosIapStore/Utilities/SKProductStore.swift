//
//  File.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 28/11/24.
//

import StoreKit
import Foundation

struct SKProductStore {
    let subscriptionPlanService = SubscriptionPlanService();

    func fetchProductsFromAppStore(for productIds: [String]) async throws -> [Product] {
        print("fetchProductsFromAppStore = \(productIds)")
        if(productIds.isEmpty) {
            throw StoreError.noProducts
        }
        do {
            print("fetchProductsFromAppStore = start")
            let allStoreProducts = try await Product.products(for: productIds)
            print("fetchProductsFromAppStore = end")
            return sortByPrice(allStoreProducts)
        } catch {
            print("fetchProductsFromAppStore error = \(error)")
            throw error;
        }
    }

    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: {return $0.price < $1.price})
    }

    func sendTransactionDetails(for transaction: Transaction, with userId: String, using apiKey: String) async throws {
        
        let mappedTransaction = mapTransactionToDetails(for: transaction, with: userId);
        do{
            try await subscriptionPlanService.sendVerifiedCheck(transaction: mappedTransaction, apiKey: apiKey)
        } catch {
            throw error
        }
    }

    func mapTransactionToDetails(for transaction: Transaction, with userId: String) -> TransactionDetails {

        return TransactionDetails(
                userId: userId,
                bundleId: transaction.appBundleID,
//                currency: transaction.currency?.identifier ?? "",
                deviceVerification: transaction.deviceVerification.base64EncodedString(),
                deviceVerificationNonce: transaction.deviceVerificationNonce.uuidString,
//                environment: transaction.environment.rawValue,
                expiresDate: transaction.expirationDate?.timeIntervalSince1970 ?? 0,
                inAppOwnershipType: transaction.ownershipType.rawValue,
                isUpgraded: transaction.isUpgraded, // Boolean value
                originalPurchaseDate: transaction.originalPurchaseDate.timeIntervalSince1970,
                originalTransactionId: transaction.originalID,
                price: transaction.price ?? Decimal(0),
                productId: transaction.productID,
                purchaseDate: transaction.purchaseDate.timeIntervalSince1970,
                quantity: transaction.purchasedQuantity,
                signedDate: transaction.signedDate.timeIntervalSince1970,
//                storefront: transaction.storefront.countryCode,
//                storefrontId: transaction.storefront.id,
//                subscriptionGroupIdentifier: transaction.subscriptionGroupIdentifier ?? "",
                transactionId: String(transaction.id),
//                transactionReason: transaction.reason.rawValue,
                type: transaction.productType.rawValue,
                webOrderLineItemId: transaction.webOrderLineItemID ?? ""
            )
    }
    
    func getSubscriptionGroupIdentifier(for transaction: Transaction, from storeProducts: [Product]) -> String? {
        if let product = storeProducts.first(where: { $0.id == transaction.productID }) {
            return product.subscription?.subscriptionGroupID
        }
        return nil
    }
    
    func checkVerified<T> (_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func getStoreProduct(with productId: String, from storeProducts: [Product]) -> Product? {
        return storeProducts.first(where: { $0.id == productId })
    }

}
