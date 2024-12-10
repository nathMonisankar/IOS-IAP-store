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
                if subscribed {
                    cancelButton
                }
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

extension StoreContent {
    private var cancelButton: some View {
        Button(action: {
            store.openSubscriptionSettings()
        }) {
            Text("Go To Subscriptions")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.red)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 2)
        }
    }
}

