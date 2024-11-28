//
//  File.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 28/11/24.
//

import Foundation
import StoreKit
import SwiftUI

class SKProductStore: NSObject, SKProductsRequestDelegate {
    
    @MainActor
    func fetchProductsFromAppStore(for productIds: [String]) async throws -> [SKProduct] {
        if productIds.isEmpty {
            throw StoreError.noProducts
        }
        
        // Create a promise to handle the products fetched asynchronously
        return try await withCheckedThrowingContinuation { continuation in
            let productRequest = SKProductsRequest(productIdentifiers: Set(productIds))
            productRequest.delegate = self
            productRequest.start()

            // Store the continuation to resume later when products are fetched
            self.continuation = continuation
        }
    }
    
    // Continuation to resume fetching products later
    private var continuation: CheckedContinuation<[SKProduct], Error>?
    
    // Delegate method for SKProductsRequest to handle the response
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Return the products received from App Store
        continuation?.resume(returning: sortByPrice(response.products))
        continuation = nil
    }
    
    // Handle any errors from SKProductsRequest
    func productRequest(_ request: SKProductsRequest, didFailWithError error: Error) {
        // Resume with an error if the request fails
        continuation?.resume(throwing: StoreError.productRequestFailed)
        continuation = nil
    }
    
    func sortByPrice(_ products: [SKProduct]) -> [SKProduct] {
        products.sorted {
            let price1 = $0.price as Decimal
            let price2 = $1.price as Decimal
            return price1 < price2
        }
    }
}
