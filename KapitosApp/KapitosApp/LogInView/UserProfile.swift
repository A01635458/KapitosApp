//
//  UserProfile.swift
//  KapitosApp
//  Shared model for user profiles
//

import Foundation

struct UserProfile: Identifiable, Codable {
    let id: UUID
    let full_name: String
    let email: String
    let role: String // 'user', 'producer', 'admin'
    let created_at: String?
    let photo_url: String?
    
    var displayRole: String {
        switch role {
        case "user": return "Cliente"
        case "producer": return "Productor"
        case "admin": return "Admin"
        default: return role
        }
    }
}
