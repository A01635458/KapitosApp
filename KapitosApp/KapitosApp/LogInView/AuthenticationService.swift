import Foundation
import Combine
import Supabase

@MainActor
final class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()

    private let client: SupabaseClient = SupabaseClient(
        supabaseURL: AppConfig.supabaseURL,
        supabaseKey: AppConfig.supabaseAnonKey
    )

    @Published var isLoading = false
    @Published var message: String? = nil
    @Published var currentUserId: UUID? = nil
    @Published var userRole: String? = nil

    enum AuthError: LocalizedError {
        case missingUser
        case generic(String)

        var errorDescription: String? {
            switch self {
            case .missingUser: return "No se recibió usuario de Supabase"
            case .generic(let msg): return msg
            }
        }
    }

    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        message = nil
        defer { isLoading = false }
        do {
            // Compatibilidad: usar método disponible en versión actual del SDK
            // Intentamos signIn(email:password:)
            let response = try await client.auth.signIn(email: email, password: password)
            // En versión actual user no es opcional
            let user = response.user
            currentUserId = user.id
            
            print("🔍 User logged in: \(user.id.uuidString)")
            
            // Obtener el rol del usuario desde la tabla profiles
            let profileResponse: [UserProfile] = try await client
                .from("profiles")
                .select()
                .eq("id", value: user.id.uuidString)
                .execute()
                .value
            
            print("Profiles found: \(profileResponse.count)")
            
            if let profile = profileResponse.first {
                userRole = profile.role
                print("User role: \(profile.role)")
            } else {
                print("Warning: No profile found for user")
                userRole = "user" // Default role
            }
            
            message = "Inicio de sesión exitoso"
            return true
        } catch {
            print("Error: Login error: \(error)")
            message = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
            return false
        }
    }
    
    func signOut() {
        currentUserId = nil
        userRole = nil
        message = nil
        print("User logged out")
    }
    
    /// Refresca el rol del usuario actual desde la base de datos
    func refreshUserRole() async {
        guard let userId = currentUserId else {
            print("Warning: No user ID to refresh role")
            return
        }
        
        do {
            print("Refreshing user role for: \(userId.uuidString)")
            let profileResponse: [UserProfile] = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .execute()
                .value
            
            if let profile = profileResponse.first {
                userRole = profile.role
                print("Role refreshed: \(profile.role)")
            } else {
                print("Warning: No profile found during refresh")
            }
        } catch {
            print("Error: Error refreshing role: \(error)")
        }
    }
    
    var isAuthenticated: Bool {
        currentUserId != nil
    }
}
