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
                // Esperar a que el rol esté cargado antes de mostrar la vista
                if let role = auth.userRole {
                    // Usuario autenticado con rol conocido
                    if role == "admin" {
                        KapeContentView()
                            .environmentObject(theme)
                    } else if role == "producer" {
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
                    // Autenticado pero rol aún no cargado - mostrar loading
                    ZStack {
                        Color(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight))
                                .scaleEffect(1.5)
                            
                            Text("Cargando...")
                                .font(.headline)
                                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                        }
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
