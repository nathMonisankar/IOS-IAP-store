//
//  Transaction.swift
//  sdk
//
//  Created by Monisankar Nath on 25/11/24.
//

import Foundation

struct TransactionDetails: Codable {
    let userId: String
    let bundleId: String
//    let currency: String
    let deviceVerification: String
    let deviceVerificationNonce: String
//    let environment: String
    let expiresDate: TimeInterval
    let inAppOwnershipType: String
    let isUpgraded: Bool
    let originalPurchaseDate: TimeInterval
    let originalTransactionId: UInt64
    let price: Decimal
    let productId: String
    let purchaseDate: TimeInterval
    let quantity: Int
    let signedDate: TimeInterval
//    let storefront: String
//    let storefrontId: String
//    let subscriptionGroupIdentifier: String
    let transactionId: String
//    let transactionReason: String
    let type: String
    let webOrderLineItemId: String
    let receipt: String
}
