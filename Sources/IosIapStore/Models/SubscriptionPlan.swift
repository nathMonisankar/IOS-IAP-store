//
//  File.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 26/11/24.
//

import Foundation

struct SubscriptionPlan: Codable, Identifiable {
    var id: String {
        return productId
    }
    let productId, name, description, price, priceFormatted: String
    let kind: SubscriptionKind
    let subscriptionFamilyName: String
    let recurringSubscriptionPeriod: RecurringSubscriptionPeriod
    let isFamilyShareable: Bool
    let discounts: [Discount]
}

struct Discount: Codable {
    let modeType: ModeType
    let price, priceFormatted: String
    let recurringSubscriptionPeriod: RecurringSubscriptionPeriod
    let type: DiscountType
    let numOfPeriods: Int

}

enum SubscriptionKind: String, Codable {
    case autoRenewable = "Auto-Renewable Subscription"
    case nonRenewable = "Non-Renewable Subscription"
}

enum RecurringSubscriptionPeriod: String, Codable {
    case threeDays = "3D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case oneYear = "1Y"
    
    var displayText: String {
        switch self {
        case .threeDays:
            return "3 Days"
        case .oneYear:
            return "1 Year"
        case .oneMonth:
            return "1 Month"
        case .oneWeek:
            return "1 Week"
        }
    }
}

enum ModeType: String, Codable {
    case freeTrial = "FreeTrial"
}

enum DiscountType: String, Codable {
    case introOffer = "IntroOffer"
    case seasonalDiscount = "SeasonalDiscount"
}

