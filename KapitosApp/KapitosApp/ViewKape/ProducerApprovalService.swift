//
//  ProducerApprovalService.swift
//  KapitosApp
//  Service to fetch and approve producer applications
//

import Foundation
import Supabase
import Combine

@MainActor
final class ProducerApprovalService: ObservableObject {
    static let shared = ProducerApprovalService()
    
    private let client: SupabaseClient = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )
    
    @Published var pendingProducers: [Producer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    enum ApprovalError: LocalizedError {
        case fetchFailed(String)
        case updateFailed(String)
        case createAccountFailed(String)
        
        var errorDescription: String? {
            switch self {
            case .fetchFailed(let msg): return "Error al obtener solicitudes: \(msg)"
            case .updateFailed(let msg): return "Error al actualizar estado: \(msg)"
            case .createAccountFailed(let msg): return "Error al crear cuenta: \(msg)"
            }
        }
    }
    
    // Fetch pending producers
    func fetchPendingProducers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response: [Producer] = try await client
                .from("producers")
                .select()
                .eq("status", value: "pending")
                .order("created_at", ascending: false)
                .execute()
                .value
            
            pendingProducers = response
        } catch {
            errorMessage = ApprovalError.fetchFailed(error.localizedDescription).localizedDescription
            print("❌ Error fetching producers: \(error)")
        }
    }
    
    // Approve producer and create account
    func approveProducer(producerId: UUID, email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // 1. Update producer status
            struct StatusUpdate: Encodable {
                let status: String
            }
            try await client
                .from("producers")
                .update(StatusUpdate(status: "approved"))
                .eq("id", value: producerId.uuidString)
                .execute()
            
            // 2. Create auth user account
            let signUpResponse = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            let userId = signUpResponse.user.id
            
            // 3. Update profile to producer role
            struct ProfileUpdate: Encodable {
                let role: String
            }
            try await client
                .from("profiles")
                .update(ProfileUpdate(role: "producer"))
                .eq("id", value: userId.uuidString)
                .execute()
            
            // 4. Link producer to auth user
            struct IdUpdate: Encodable {
                let id: String
            }
            try await client
                .from("producers")
                .update(IdUpdate(id: userId.uuidString))
                .eq("id", value: producerId.uuidString)
                .execute()
            
            // Refresh list
            await fetchPendingProducers()
            
            return true
        } catch {
            errorMessage = ApprovalError.updateFailed(error.localizedDescription).localizedDescription
            print("❌ Error approving producer: \(error)")
            return false
        }
    }
    
    // Reject producer
    func rejectProducer(producerId: UUID) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            struct StatusUpdate: Encodable {
                let status: String
            }
            try await client
                .from("producers")
                .update(StatusUpdate(status: "rejected"))
                .eq("id", value: producerId.uuidString)
                .execute()
            
            // Refresh list
            await fetchPendingProducers()
            
            return true
        } catch {
            errorMessage = ApprovalError.updateFailed(error.localizedDescription).localizedDescription
            print("❌ Error rejecting producer: \(error)")
            return false
        }
    }
    
    // Get counts for dashboard
    func getProducerCounts() async -> (pending: Int, approved: Int, rejected: Int) {
        do {
            let allProducers: [Producer] = try await client
                .from("producers")
                .select()
                .execute()
                .value
            
            let pending = allProducers.filter { $0.status == "pending" }.count
            let approved = allProducers.filter { $0.status == "approved" }.count
            let rejected = allProducers.filter { $0.status == "rejected" }.count
            
            return (pending, approved, rejected)
        } catch {
            print("❌ Error getting counts: \(error)")
            return (0, 0, 0)
        }
    }
}
