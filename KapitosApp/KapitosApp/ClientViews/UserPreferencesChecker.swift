import Foundation
import Supabase
import Combine

final class UserPreferencesChecker: ObservableObject {
    
    @Published var hasPreferences: Bool = true
    @Published var isLoading: Bool = true
    
    private let client: SupabaseClient
    
    init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
            supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
        )
    }
    
    struct UserPreference: Decodable {
        let user_id: UUID
        let processes: [String]?
        let roasts: [String]?
        let drinks: [String]?
        let times: [String]?
        let acidity: [String]?
        let flavor_notes: [String]?
        let weekly_consumption: String?
    }
    
    @MainActor
    func checkUserPreferences(userId: UUID) async {
        isLoading = true
        
        do {
            let response: [UserPreference] = try await client
                .from("user_preferences")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            if let prefs = response.first {
                // Check if at least one preference field has data
                let hasAnyPreference = (prefs.processes?.isEmpty == false) ||
                                      (prefs.roasts?.isEmpty == false) ||
                                      (prefs.drinks?.isEmpty == false) ||
                                      (prefs.times?.isEmpty == false) ||
                                      (prefs.acidity?.isEmpty == false) ||
                                      (prefs.flavor_notes?.isEmpty == false) ||
                                      (prefs.weekly_consumption != nil)
                
                hasPreferences = hasAnyPreference
            } else {
                // No record found - user needs to complete preferences
                hasPreferences = false
            }
        } catch {
            print("Error checking preferences: \(error)")
            // Assume they have preferences on error to avoid annoying users
            hasPreferences = true
        }
        
        isLoading = false
    }
}
