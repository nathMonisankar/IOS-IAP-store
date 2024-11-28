//
//  SwiftUIView.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 27/11/24.
//

import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var store: MyStore
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing: 20) {
                ForEach(store.availableProducts) { product in
                    ProductListItemView(product: product)
                        .onTapGesture {
                            store.selectedProduct = product
                        }
                }
            }
        }
    }
}

