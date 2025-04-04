//
//  ProState.swift
//  InsectIdentifier
//
//  Created by Hussnain on 04/04/2025.
//

import Foundation
import StoreKit

class ProState: ObservableObject {
    @Published  var  isProUser: Bool = false
    @Published var products: [Product]?
    
    init(){
        refreshState()
        Task{
             await self.fetchProducts()
        }
    }
    
    func refreshState()  {
        Task {
               await self.checkActiveSubscription()
           }
       
    }
    
    @MainActor
    private func fetchProducts() async {
            do {
                 products = try await Product.products(for: [ProductKeys.weekly,ProductKeys.monthly,ProductKeys.yearly])
            } catch {
                print("Error fetching subscription: \(error)")
            }
        }

    @MainActor
    func checkActiveSubscription() async {
           for await result in Transaction.currentEntitlements {
               guard case .verified(let transaction) = result else {
                   continue
               }

               if [ProductKeys.weekly, ProductKeys.monthly, ProductKeys.yearly].contains(transaction.productID),
                  transaction.revocationDate == nil,
                  transaction.expirationDate.map({ $0 > Date() }) != false {
                   print("Active subscription found! \(String(describing: transaction.expirationDate))")
                   self.isProUser = true
                   return
               }
           }

        self.isProUser = false
       }
}
