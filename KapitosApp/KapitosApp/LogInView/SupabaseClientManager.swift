//
//  SupabaseClientManager.swift
//  KapitosApp
//

import Foundation
import Supabase

final class SupabaseClientManager {

    static let shared = SupabaseClientManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey
        )
    }
    
    /// Obtiene el ID del usuario autenticado actualmente
    /// - Returns: UUID del usuario o nil si no hay sesión activa
    func getCurrentUserId() async -> UUID? {
        do {
            let session = try await client.auth.session
            return session.user.id
        } catch {
            print("Error obteniendo usuario actual: \(error)")
            return nil
        }
    }
}

