//
//  UserPreferencesService.swift
//  KapitosApp
//
//  Created by GitHub Copilot on 05/12/25.
//

import Foundation
import Supabase
import Combine

@MainActor
class UserPreferencesService: ObservableObject {
    
    @Published var preferences: UserPreferences?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )
    
    /// Fetch user preferences from database
    func fetchUserPreferences(userId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [UserPreferences] = try await supabase
                .from("user_preferences")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            if let prefs = response.first {
                preferences = prefs
                print("✅ Loaded preferences for user \(userId)")
            } else {
                print("⚠️ No preferences found for user \(userId)")
                preferences = nil
            }
            
        } catch {
            errorMessage = "Error al cargar preferencias: \(error.localizedDescription)"
            print("❌ Error fetching preferences: \(error)")
        }
        
        isLoading = false
    }
    
    /// Check if user has preferences configured
    func hasPreferences(userId: UUID) async -> Bool {
        await fetchUserPreferences(userId: userId)
        return preferences?.hasPreferences ?? false
    }
}
