//
//  ProfileView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 18/11/25.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @EnvironmentObject var theme: AppThemeManager
    let currentUserId: UUID
    
    @State private var showNotificationPreferences = false
    @State private var userProfile: UserProfile?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )

    var body: some View {
        ZStack {
            (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                .ignoresSafeArea()

            if isLoading {
                ProgressView("Cargando perfil...")
                    .foregroundColor(.gray)
            } else if let errorMessage = errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Error al cargar perfil")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                VStack(spacing: 20) {
                    Circle()
                        .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.largeTitle)
                                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        )

                    Text(userProfile?.full_name ?? "Usuario")
                        .font(.title2)
                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    
                    Text(userProfile?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Role Badge
                    Text(userProfile?.displayRole ?? "")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    
                    // Notification Settings Button
                    Button {
                        showNotificationPreferences = true
                    } label: {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                            Text("Notificaciones Inteligentes")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.isDarkMode ? AppColors.cardDark : Color.white)
                                .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                        )
                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showNotificationPreferences) {
            NotificationPreferencesView(currentUserId: currentUserId)
                .environmentObject(theme)
        }
        .task {
            await loadUserProfile()
        }
    }
    
    // MARK: - Load User Profile
    
    private func loadUserProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let profile: UserProfile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUserId.uuidString)
                .single()
                .execute()
                .value
            
            userProfile = profile
            isLoading = false
        } catch {
            print("❌ Error loading user profile: \(error)")
            errorMessage = "No se pudo cargar el perfil"
            isLoading = false
        }
    }
}
