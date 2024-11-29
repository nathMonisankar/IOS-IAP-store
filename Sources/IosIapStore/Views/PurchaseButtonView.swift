//
//  SwiftUIView.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 29/11/24.
//

import SwiftUI

struct PurchaseButtonView: View {
    @EnvironmentObject var store: RootStore
    
    func getRecurringDescriptionText() -> String {
        if let product = store.selectedProduct {
            return "Plan auto-renews for \(product.priceFormatted)\(product.recurringSubscriptionPeriod.recurringText) until canceled."
        }
        return ""
    }
    var body: some View {
        VStack(spacing: 8) {
            recurringText
            purchaseButton
        }
    }
}

extension PurchaseButtonView {
    private var purchaseButton: some View {
        Button(action: {
            if let selectedPlan = store.selectedProduct {
                Task {
                    await store.purchaseProduct(with: selectedPlan.productId)
                }
            }
        }) {
            Text(store.subscribeButtonTitle())
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(store.isSubscribeButtonDisabled() ? .gray : .blue)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .disabled(store.isSubscribeButtonDisabled())
    }
    
    private var recurringText: some View {
        Text(getRecurringDescriptionText())
            .font(.footnote)
            .foregroundColor(.primary)
    }
}
