//
//  ContentView.swift
//  InsectIdentifier
//
//  Created by Hussnain on 12/03/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var adVm: InterstitialViewModel
    var body: some View {
        ZStack{
            NavigationStack {
                ZStack{
                    SplashView()
                }
               
            }
            if adVm.isLoadingAd {
                Color.white.ignoresSafeArea()
                              ProgressView("Loading Ad...")
                                  .padding()
                                  .background(Color.white)
                                  .cornerRadius(10)
            }
        }
        
    }

}

#Preview {
    ContentView().environmentObject(InterstitialViewModel())
}
