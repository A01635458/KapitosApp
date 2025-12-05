//
//  KapitosAppApp.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 15/11/25.
//


import SwiftUI

@main
struct KapitosAppApp: App {
    @StateObject private var theme = AppThemeManager()
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(theme)
                .navigationBarBackButtonHidden(true)
        }
    }
}
