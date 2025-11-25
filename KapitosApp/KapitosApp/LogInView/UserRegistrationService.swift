import Foundation
import Combine
import Supabase

final class UserRegistrationService: ObservableObject {

    static let shared = UserRegistrationService()
    private let client: SupabaseClient = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )

    enum RegistrationError: Error, LocalizedError {
        case missingUser
        case signUpFailed(String)
        case preferencesInsertFailed(String)
        case notAuthenticated

        var errorDescription: String? {
            switch self {
            case .missingUser: return "Usuario no disponible después de signUp."
            case .signUpFailed(let msg): return "Error en registro: \(msg)"
            case .preferencesInsertFailed(let msg): return "Error guardando preferencias: \(msg)"
            case .notAuthenticated: return "Sesión no autenticada."
            }
        }
    }

    struct UserPreferencesInsertDTO: Encodable {
        let user_id: UUID
        let processes: [String]?
        let roasts: [String]?
        let drinks: [String]?
        let times: [String]?
        let acidity: [String]?
        let flavor_notes: [String]?
        let weekly_consumption: String?
    }

    @Published var isSubmitting = false
    @Published var submitMessage: String? = nil

    // Realiza signUp y retorna el UUID del usuario
    struct ProfileInsert: Encodable { let id: UUID; let full_name: String; let email: String }

    @discardableResult
    func signUpUser(name: String, email: String, password: String) async throws -> UUID {
        do {
            let response = try await client.auth.signUp(email: email, password: password)
            // user es no opcional en la versión actual del SDK
            let id = response.user.id
            // Insert perfil explícito
            let profile = ProfileInsert(id: id, full_name: name, email: email)
            try await client.from("profiles").insert(profile).execute()
            return id
        } catch {
            throw RegistrationError.signUpFailed(error.localizedDescription)
        }
    }

    // Inserta preferencias (arrays) para el usuario recién creado
    func insertPreferences(userId: UUID, preferences: RegistrationFlowModel.PreferencesData) async throws {
        let dto = UserPreferencesInsertDTO(
            user_id: userId,
            processes: emptyFiltered(preferences.processes),
            roasts: emptyFiltered(preferences.roasts),
            drinks: emptyFiltered(preferences.drinks),
            times: emptyFiltered(preferences.times),
            acidity: emptyFiltered(preferences.acidity),
            flavor_notes: emptyFiltered(preferences.notes),
            weekly_consumption: preferences.weekly.first
        )
        do {
            try await client.from("user_preferences").insert(dto).execute()
        } catch {
            throw RegistrationError.preferencesInsertFailed(error.localizedDescription)
        }
    }

    // Flujo completo: signUp + preferencias (si hay)
    func completeRegistration(flow: RegistrationFlowModel) async {
        await MainActor.run { isSubmitting = true; submitMessage = nil }
        do {
            let userId = try await signUpUser(name: flow.name, email: flow.email, password: flow.password)
            if flow.hasAnyPreferenceSelections {
                try await insertPreferences(userId: userId, preferences: flow.preferences)
            }
            await MainActor.run { submitMessage = "Registro completado ✔️" }
        } catch {
            await MainActor.run { submitMessage = error.localizedDescription }
        }
        await MainActor.run { isSubmitting = false }
    }

    private func emptyFiltered(_ set: Set<String>) -> [String]? {
        let arr = set.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        return arr.isEmpty ? nil : arr.sorted()
    }
}
