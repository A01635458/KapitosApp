//
//  AdminDataService.swift
//  KapitosApp
//  Service for admin to fetch producers, clients, and stats
//

import Foundation
import Supabase
import Combine

@MainActor
final class AdminDataService: ObservableObject {
    static let shared = AdminDataService()
    
    private let client: SupabaseClient = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )
    
    @Published var approvedProducers: [Producer] = []
    @Published var allUsers: [UserProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Fetch approved producers
    func fetchApprovedProducers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response: [Producer] = try await client
                .from("producers")
                .select()
                .eq("status", value: "approved")
                .order("created_at", ascending: false)
                .execute()
                .value
            
            approvedProducers = response
        } catch {
            errorMessage = "Error al obtener productores: \(error.localizedDescription)"
            print("❌ Error fetching approved producers: \(error)")
        }
    }
    
    // Fetch all users (clients)
    func fetchAllUsers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response: [UserProfile] = try await client
                .from("profiles")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
            
            allUsers = response
        } catch {
            errorMessage = "Error al obtener usuarios: \(error.localizedDescription)"
            print("❌ Error fetching users: \(error)")
        }
    }
    
    // Create manual account (admin or client)
    func createAccount(email: String, password: String, fullName: String, role: String = "user") async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // 1. Create auth user
            let signUpResponse = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            let userId = signUpResponse.user.id
            
            // 2. Update profile with name and role
            struct ProfileUpdate: Encodable {
                let full_name: String
                let role: String
            }
            
            try await client
                .from("profiles")
                .update(ProfileUpdate(full_name: fullName, role: role))
                .eq("id", value: userId.uuidString)
                .execute()
            
            return true
        } catch {
            errorMessage = "Error al crear cuenta: \(error.localizedDescription)"
            print("❌ Error creating account: \(error)")
            return false
        }
    }
    
    // Get user count by role
    func getUserCountsByRole() async -> (users: Int, producers: Int, admins: Int) {
        do {
            let allProfiles: [UserProfile] = try await client
                .from("profiles")
                .select()
                .execute()
                .value
            
            let users = allProfiles.filter { $0.role == "user" }.count
            let producers = allProfiles.filter { $0.role == "producer" }.count
            let admins = allProfiles.filter { $0.role == "admin" }.count
            
            return (users, producers, admins)
        } catch {
            print("❌ Error getting user counts: \(error)")
            return (0, 0, 0)
        }
    }
}
