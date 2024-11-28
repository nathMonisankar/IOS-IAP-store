//
//  SwiftUIView.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 26/11/24.
//

import SwiftUI

public struct RootStoreView: View {
    private let apiKey: String
    @StateObject private var store: MyStore
    public init(
        userId: String,
        apiKey: String
    ) {
        self.apiKey = apiKey
        _store = StateObject(wrappedValue: MyStore(userId: userId))
    }
    public var body: some View {
        VStack {
            StoreContent()
            if store.isLoading {
                ProgressView("Loading Plans...")
            } else if store.availableProducts.count != 0 {
                ProductListView()
            } else {
                Text("No Products available at this time!")
            }
        }
        .environmentObject(store)
        .onAppear {
            Task{ @MainActor in
                await store.fetchSubscriptionPlans(apiKey: apiKey)
                await store.fetchStoreProducts()
            }
        }
        .padding()
    }
}

