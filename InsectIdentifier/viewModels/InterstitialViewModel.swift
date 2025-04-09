//
//  InterstitialViewModel.swift
//  InsectIdentifier
//
//  Created by Hussnain on 09/04/2025.
//

import GoogleMobileAds
import SwiftUI


class InterstitialViewModel: NSObject, ObservableObject, FullScreenContentDelegate {
    private var interstitialAd: InterstitialAd?
    @Published var isLoadingAd = false
    
    @MainActor
    func loadAndShowAd() {
        isLoadingAd = true

        Task {
            do {
                let ad = try await InterstitialAd.load(
                    with: "ca-app-pub-3940256099942544/4411468910",
                    request: Request()
                )
                ad.fullScreenContentDelegate = self
                self.interstitialAd = ad

                isLoadingAd = false

                guard let ad = self.interstitialAd else {
                    return print("Ad wasn't ready.")
                }

                 ad.present(from: nil)

            } catch {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                isLoadingAd = false
            }
        }
    }


    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad dismissed.")
        interstitialAd = nil
        self.isLoadingAd = false
    }
    
    func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("Ad failed to present.")
        interstitialAd = nil
    }
}
