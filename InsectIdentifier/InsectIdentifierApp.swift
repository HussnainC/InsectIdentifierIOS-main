//
//  InsectIdentifierApp.swift
//  InsectIdentifier
//
//  Created by Hussnain on 11/03/2025.
//

import SwiftUI

@main
struct InsectIdentifierApp: App {
    @AppStorage(AppConstants.LANG_CODE_KEY) private var langCode: String = "en"
    @StateObject var proState = ProState()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.environment (\.locale,Locale(identifier:langCode)).environmentObject(proState)
    }
}
