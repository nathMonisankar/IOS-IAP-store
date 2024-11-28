//
//  File.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 28/11/24.
//

import StoreKit
import Foundation

struct SKTwoProductStore {
    
    @MainActor @available(iOS 15.0, *)
    func fetchProductsFromAppStore(for productIds: [String]) async throws -> [Product] {
        if(productIds.isEmpty) {
            throw StoreError.noProducts
        }
        do {
            let allStoreProducts = try await Product.products(for: productIds)
            
            return sortByPrice(allStoreProducts)
        } catch {
            throw error;
        }
    }
    
    @available(iOS 15.0, *)
    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: {return $0.price < $1.price})
    }
}
