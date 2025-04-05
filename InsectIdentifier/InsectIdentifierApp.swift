//
//  InsectIdentifierApp.swift
//  InsectIdentifier
//
//  Created by Hussnain on 11/03/2025.
//

import SwiftUI
import StoreKit

@main
struct InsectIdentifierApp: App {
    @AppStorage(AppConstants.LANG_CODE_KEY) private var langCode: String = "en"
    @StateObject var proState = ProState()
    init(){
        startTransactionListener(proState: proState)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.environment (\.locale,Locale(identifier:langCode)).environmentObject(proState)
    }
    func startTransactionListener(proState: ProState) {
        Task.detached(priority: .background) {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else {
                    continue
                }
                print("Transaction update: \(transaction.productID)")

                // Finish the transaction to prevent it from being re-processed
                await transaction.finish()
                
                // Update app state
                await MainActor.run {
                    proState.refreshState()
                }
            }
        }
    }
    
}
