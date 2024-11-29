//
//  SwiftUIView.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 27/11/24.
//

import SwiftUI

struct ProductListItemView: View {
    @EnvironmentObject var store: RootStore
    
    var product: SubscriptionPlan
    var isSelected: Bool {
        if store.selectedProduct != nil && store.selectedProduct?.productId == product.productId {
            return true
        }
        return false
    }
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 10) {
                Text(product.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(product.description)
                    .font(.body)
                    .foregroundColor(.primary)

                Text(product.priceFormatted)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                        
                if let discount = product.discounts.first(where: { $0.modeType == .freeTrial }) {
                    Text("Intro Offer: \(discount.priceFormatted) for \(discount.recurringSubscriptionPeriod.displayText)")
                        .font(.callout)
                        .foregroundColor(.accentColor)
                }
                        
                if store.isProductPurchased(with: product.productId) {
                    Text("⭐️ Your current plan")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            radioButton
        }
        .padding()
        .background(
            isSelected
            ? LinearGradient(gradient: Gradient(colors: [.mint, .cyan]), startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}

extension ProductListItemView {
    private var radioButton: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                .background(Circle().fill(isSelected ? Color.blue : Color.clear))
                .frame(width: 24, height: 24)
                
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
            }
        }
    }
}
