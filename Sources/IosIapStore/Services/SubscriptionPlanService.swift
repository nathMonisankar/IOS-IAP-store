//
//  File.swift
//  IosIapStore
//
//  Created by Monisankar Nath on 27/11/24.
//

import Foundation

struct SubscriptionPlanService {
    func loadSubscriptionPlans(apiKey: String) async throws -> [SubscriptionPlan] {
        do {
            let url = URL(string: "https://05052a84-35de-4a87-ae64-2b32a9188b68.mock.pstmn.io/productDetails")!
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: request)
            let plans = try JSONDecoder().decode([SubscriptionPlan].self, from: data)
//            print(plans)
            return plans
        } catch {
            throw error
        }
    }
}
