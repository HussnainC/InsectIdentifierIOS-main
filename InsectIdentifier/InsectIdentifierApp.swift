//
//  InsectIdentifierApp.swift
//  InsectIdentifier
//
//  Created by Hussnain on 11/03/2025.
//

import SwiftUI
import StoreKit
import GoogleMobileAds


class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    MobileAds.shared.start(completionHandler: nil)

    return true
  }
}

@main
struct InsectIdentifierApp: App {
    @AppStorage(AppConstants.LANG_CODE_KEY) private var langCode: String = "en"
    @StateObject var proState = ProState()
    @StateObject private var adVM = InterstitialViewModel()
    init(){
        startTransactionListener(proState: proState)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
    
          
        }.environment (\.locale,Locale(identifier:langCode))
            .environmentObject(proState)
            .environmentObject(adVM)
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
