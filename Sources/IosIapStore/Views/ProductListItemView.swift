//
//  SwiftUIView.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 27/11/24.
//

import SwiftUI

struct ProductListItemView: View {
    @EnvironmentObject var store: MyStore
    
    var product: SubscriptionPlan
    var isSelected: Bool {
        if store.selectedProduct != nil && store.selectedProduct?.productId == product.productId {
            return true
        }
        return false
    }
    
    var body: some View {
        HStack{
            VStack(spacing: 10) {
                Text(product.name)
                Text(product.description)
            }
            
            Spacer()
            radioButton
        }
        .padding()
        .background(Color.gray.opacity(0.4))
        .cornerRadius(10)
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
