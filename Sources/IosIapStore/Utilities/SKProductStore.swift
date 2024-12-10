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
        if(productIds.isEmpty) {
            throw StoreError.noProducts
        }
        do {
            let allStoreProducts = try await Product.products(for: productIds)
            if allStoreProducts.count == 0 {
                throw StoreError.noProductsInStore
            }
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
/*
 "userId" : [USER_LOGIN_ID],
 "appAccountToken" : "3e2d5d0d-ab6c-1e13-307a-3802d7cdfc6a",
 "bundleId" : "com.iap.sdk",
 "currency" : "USD",
 "deviceVerification" : "aCz1Ywhi6U2KeoT8nSOciDRX2htFQ9kBysBscye45XLu0HQYxTwZ0khsN54AamLd",
 "deviceVerificationNonce" : "72a9600e-c3c5-4232-bc60-577f8bdf73ab",
 "environment" : "Xcode",
 "expiresDate" : 1765361352619,
 "inAppOwnershipType" : "PURCHASED",
 "isUpgraded" : false,
 "originalPurchaseDate" : 1733727163880,
 "originalTransactionId" : "1",
 "price" : 990,
 "productId" : "yearly_subscription",
 "purchaseDate" : 1733825352619,
 "quantity" : 1,
 "signedDate" : 1733825352628,
 "storefront" : "USA",
 "storefrontId" : "143441",
 "subscriptionGroupIdentifier" : "21585786",
 "transactionId" : "2",
 "transactionReason" : "PURCHASE",
 "type" : "Auto-Renewable Subscription",
 "webOrderLineItemId" : "2"
 
 */
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
                webOrderLineItemId: transaction.webOrderLineItemID ?? "",
                appAccountToken: transaction.appAccountToken ?? UUID()
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
