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
            print("Error: Error fetching producers: \(error)")
        }
    }
    
    // Approve producer and create account
    func approveProducer(producerId: UUID, email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            print("Starting producer approval for ID: \(producerId.uuidString)")
            
            // 1. Create auth user account first
            print("Creating auth user with email: \(email)")
            let signUpResponse = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            let userId = signUpResponse.user.id
            print("User created with ID: \(userId.uuidString)")
            
            // 2. Get producer info
            let producerData: [Producer] = try await client
                .from("producers")
                .select()
                .eq("id", value: producerId.uuidString)
                .execute()
                .value
            
            let producerName = producerData.first?.displayName ?? "Productor"
            print("Producer name: \(producerName)")
            
            // 3. Create profile manually with producer role
            struct ProfileInsert: Encodable {
                let id: String
                let full_name: String
                let email: String
                let role: String
            }
            
            print("Creating profile with role: producer")
            try await client
                .from("profiles")
                .insert(ProfileInsert(
                    id: userId.uuidString,
                    full_name: producerName,
                    email: email,
                    role: "producer"
                ))
                .execute()
            
            print("Profile created with producer role")
            
            // 4. Update producer status to approved
            struct StatusUpdate: Encodable {
                let status: String
            }
            try await client
                .from("producers")
                .update(StatusUpdate(status: "approved"))
                .eq("id", value: producerId.uuidString)
                .execute()
            
            print("Producer status updated to approved")
            
            // 5. Link producer record to the new auth user ID
            struct IdUpdate: Encodable {
                let id: String
            }
            try await client
                .from("producers")
                .update(IdUpdate(id: userId.uuidString))
                .eq("id", value: producerId.uuidString)
                .execute()
            
            print("Producer linked to auth user")
            
            // Refresh list
            await fetchPendingProducers()
            
            print("Producer approval completed successfully!")
            return true
        } catch {
            errorMessage = ApprovalError.updateFailed(error.localizedDescription).localizedDescription
            print("Error: Error approving producer: \(error)")
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
            print("Error: Error rejecting producer: \(error)")
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
            print("Error: Error getting counts: \(error)")
            return (0, 0, 0)
        }
    }
}
