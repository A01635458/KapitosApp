import Foundation
import Combine
import Supabase

@MainActor
final class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()

    private let client: SupabaseClient = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )

    @Published var isLoading = false
    @Published var message: String? = nil
    @Published var currentUserId: UUID? = nil

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
            message = "Inicio de sesión exitoso ✔️"
            return true
        } catch {
            message = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
            return false
        }
    }
}
