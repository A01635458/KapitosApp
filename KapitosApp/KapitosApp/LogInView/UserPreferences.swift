//
//  UserPreferences.swift
//  KapitosApp
//
//  Created by GitHub Copilot on 05/12/25.
//

import Foundation

/// Model for user coffee preferences from database
struct UserPreferences: Codable, Identifiable {
    let userId: UUID
    let processes: [String]?
    let roasts: [String]?
    let drinks: [String]?
    let times: [String]?
    let acidity: [String]?
    let flavorNotes: [String]?
    let weeklyConsumption: String?
    let createdAt: Date?
    
    var id: UUID { userId }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case processes
        case roasts
        case drinks
        case times
        case acidity
        case flavorNotes = "flavor_notes"
        case weeklyConsumption = "weekly_consumption"
        case createdAt = "created_at"
    }
    
    // Computed property to get all preference tags as a single array
    var allPreferenceTags: [String] {
        var tags: [String] = []
        if let processes = processes { tags.append(contentsOf: processes) }
        if let roasts = roasts { tags.append(contentsOf: roasts) }
        if let drinks = drinks { tags.append(contentsOf: drinks) }
        if let acidity = acidity { tags.append(contentsOf: acidity) }
        if let flavorNotes = flavorNotes { tags.append(contentsOf: flavorNotes) }
        return tags
    }
    
    // Check if user has any preferences set
    var hasPreferences: Bool {
        let hasArrays = !(processes?.isEmpty ?? true) ||
                       !(roasts?.isEmpty ?? true) ||
                       !(drinks?.isEmpty ?? true) ||
                       !(acidity?.isEmpty ?? true) ||
                       !(flavorNotes?.isEmpty ?? true)
        return hasArrays || weeklyConsumption != nil
    }
}
