//
//  SwiftUIView.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 26/11/24.
//

import SwiftUI

struct StoreContent: View {
    @AppStorage("subscribed") private var subscribed: Bool = false
    @EnvironmentObject var store: RootStore
    
    var body: some View {
        ZStack {
            VStack {
                Text(subscribed ? "Thanks for subscribing \(store.userId)!" : "Choose a plan \(store.userId)")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text(subscribed ?  "You are subscribed" : "A purchase is required to use this app")
                Image(.coin)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 100)
                    .padding()
            }
            .padding(.vertical)
        }
    }
}

