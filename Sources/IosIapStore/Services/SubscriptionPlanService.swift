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
            return plans
        } catch {
            throw error
        }
    }
    
    func sendVerifiedCheck(transaction: TransactionDetails, apiKey: String) async throws {
        let urlString = "https://05052a84-35de-4a87-ae64-2b32a9188b68.mock.pstmn.io/transaction"
        let url = URL(string: urlString)
                
        if let url = url {
            do{
                // create request
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                let session = URLSession.shared
                // send the request

                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(apiKey, forHTTPHeaderField: "Authorization")
                // Encode the TransactionDetails into JSON
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .millisecondsSince1970 // Assuming the dates are in milliseconds
                let jsonData = try encoder.encode(transaction)

                // Set the HTTP body to the encoded JSON
                request.httpBody = jsonData
                let (data, _) = try await session.data(for: request);
                print("Post API response = \(data)")
            } catch {
                throw error
            }
        }
    }
}
