//
//  SwiftUIView.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 26/11/24.
//

import SwiftUI

public struct RootStoreView: View {
    private let apiKey: String
    @State private var showToast: Bool = false
    @StateObject private var store: RootStore
    
    public init(
        userId: String,
        apiKey: String
    ) {
        self.apiKey = apiKey
        _store = StateObject(wrappedValue: RootStore(userId: userId, apiKey: apiKey))
        
    }
    
    public var body: some View {
        ZStack {
            paymentContent
            errorToast
        }
        .onChange(of: store.errorMessage) { newValue in
            if newValue != nil {
                showToastForLimitedTime()
            }
        }
    }
}

extension RootStoreView {
    private var errorToast: some View {
        Group {
            if showToast, let message = store.errorMessage {
                VStack {
                    Spacer()
                    ToastView(message: message)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(1)
                }
            }
        }
    }
    
    private var paymentContent: some View {
        VStack {
            StoreContent()
            if store.isLoading {
                ProgressView("Loading Plans...")
            } else if store.availableProducts.count != 0 {
                ProductListView()
            } else {
                Text("No Products available at this time!")
            }
            PurchaseButtonView()
        }
        .environmentObject(store)
        .onAppear {
            Task{ @MainActor in
                await store.fetchSubscriptionPlans(apiKey: apiKey)
                await store.fetchStoreProducts()
                await store.updateCustomerProductStatus()
            }
        }
        .padding()
    }
    
    private func showToastForLimitedTime() {
        withAnimation {
            showToast = true
        }

        Task {
            try await Task.sleep(nanoseconds: 3 * 1_000_000_000) // 3 seconds
            withAnimation {
                showToast = false
            }
            store.errorMessage = nil
        }
    }
    
}


