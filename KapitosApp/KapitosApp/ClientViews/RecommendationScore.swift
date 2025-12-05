//
//  RecommendationScore.swift
//  KapitosApp
//
//  Created by GitHub Copilot on 05/12/25.
//

import Foundation

/// Represents a scored recommendation for a producer
struct RecommendationScore: Identifiable {
    let id = UUID()
    let producer: ProducerMapData
    let score: Double // 0-100
    let reasons: [String]
    let breakdown: ScoreBreakdown
    
    struct ScoreBreakdown {
        let preferenceMatch: Double // 0-40
        let proximityScore: Double  // 0-30
        let engagementScore: Double // 0-20
        let tourAvailability: Double // 0-10
    }
    
    /// Formatted score as percentage
    var scorePercentage: String {
        String(format: "%.0f%%", score)
    }
    
    /// Primary reason for recommendation
    var primaryReason: String {
        reasons.first ?? "Productor recomendado"
    }
    
    /// Check if this is a high-quality match
    var isHighMatch: Bool {
        score >= 85
    }
    
    /// Check if this is a good match
    var isGoodMatch: Bool {
        score >= 70
    }
}
