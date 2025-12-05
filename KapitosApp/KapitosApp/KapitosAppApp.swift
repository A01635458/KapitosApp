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
    @StateObject private var auth = AuthenticationService.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if auth.isAuthenticated {
                // Usuario autenticado - mostrar la vista correspondiente según su rol
                if auth.userRole == "admin" {
                    KapeContentView()
                        .environmentObject(theme)
                } else if auth.userRole == "productor" {
                    if let userId = auth.currentUserId {
                        ProducerContentView(currentUserId: userId)
                            .environmentObject(theme)
                    }
                } else {
                    // Cliente o rol por defecto
                    if let userId = auth.currentUserId {
                        ContentView(currentUserId: userId)
                            .environmentObject(theme)
                    }
                }
            } else {
                // No autenticado - mostrar LoginView
                LoginView()
                    .environmentObject(theme)
            }
        }
    }
}
