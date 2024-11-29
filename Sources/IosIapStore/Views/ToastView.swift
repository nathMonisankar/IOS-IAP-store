//
//  SwiftUIView.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 29/11/24.
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding()
            .background(Color.red.opacity(0.8))
            .cornerRadius(8)
            .shadow(radius: 5)
    }
}
