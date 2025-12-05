//
//  RecommendationEngine.swift
//  KapitosApp
//
//  Created by GitHub Copilot on 05/12/25.
//

import Foundation
import NaturalLanguage
import CoreLocation
import Supabase
import Combine

@MainActor
class RecommendationEngine: ObservableObject {
    
    @Published var recommendations: [RecommendationScore] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )
    
    private let preferencesService = UserPreferencesService()
    private let producerService = ProducerMapService()
    
    // MARK: - Main Recommendation Generation
    
    /// Generate personalized recommendations for a user
    func generateRecommendations(for userId: UUID, userLocation: CLLocation? = nil, limit: Int = 10) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Load user preferences
            await preferencesService.fetchUserPreferences(userId: userId)
            guard let preferences = preferencesService.preferences else {
                print("⚠️ No preferences found - showing generic recommendations")
                await loadGenericRecommendations(limit: limit)
                return
            }
            
            // 2. Load all approved producers
            await producerService.fetchProducers()
            let producers = producerService.producers
            
            guard !producers.isEmpty else {
                errorMessage = "No hay productores disponibles"
                isLoading = false
                return
            }
            
            // 3. Load conversation history for engagement scoring
            let conversationCounts = await loadConversationCounts(userId: userId)
            
            // 4. Score each producer
            var scoredProducers: [RecommendationScore] = []
            
            for producer in producers {
                let score = calculateScore(
                    producer: producer,
                    preferences: preferences,
                    userLocation: userLocation,
                    conversationCount: conversationCounts[producer.id] ?? 0
                )
                scoredProducers.append(score)
            }
            
            // 5. Sort by score and take top N
            recommendations = scoredProducers
                .sorted { $0.score > $1.score }
                .prefix(limit)
                .map { $0 }
            
            print("✅ Generated \(recommendations.count) recommendations (top score: \(recommendations.first?.score ?? 0))")
            
        } catch {
            errorMessage = "Error generando recomendaciones: \(error.localizedDescription)"
            print("❌ Error in generateRecommendations: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Scoring Algorithm
    
    private func calculateScore(
        producer: ProducerMapData,
        preferences: UserPreferences,
        userLocation: CLLocation?,
        conversationCount: Int
    ) -> RecommendationScore {
        
        // 1. Preference Match Score (40 points max)
        let preferenceScore = calculatePreferenceMatch(producer: producer, preferences: preferences)
        
        // 2. Proximity Score (30 points max)
        let proximityScore = calculateProximityScore(producer: producer, userLocation: userLocation)
        
        // 3. Engagement Score (20 points max)
        let engagementScore = calculateEngagementScore(conversationCount: conversationCount)
        
        // 4. Tour Availability (10 points max)
        let tourScore = calculateTourScore(producer: producer)
        
        // Total score
        let totalScore = preferenceScore + proximityScore + engagementScore + tourScore
        
        // Generate reasons
        let reasons = generateReasons(
            producer: producer,
            preferences: preferences,
            preferenceScore: preferenceScore,
            proximityScore: proximityScore,
            tourScore: tourScore
        )
        
        let breakdown = RecommendationScore.ScoreBreakdown(
            preferenceMatch: preferenceScore,
            proximityScore: proximityScore,
            engagementScore: engagementScore,
            tourAvailability: tourScore
        )
        
        return RecommendationScore(
            producer: producer,
            score: totalScore,
            reasons: reasons,
            breakdown: breakdown
        )
    }
    
    // MARK: - Individual Scoring Components
    
    /// Calculate how well producer matches user preferences (0-40 points)
    private func calculatePreferenceMatch(producer: ProducerMapData, preferences: UserPreferences) -> Double {
        var score: Double = 0
        var maxPossible: Double = 0
        
        // Process matching (15 points)
        if let userProcesses = preferences.processes, !userProcesses.isEmpty,
           let producerProcesses = producer.processes, !producerProcesses.isEmpty {
            let matches = Set(userProcesses).intersection(Set(producerProcesses)).count
            score += Double(matches) / Double(userProcesses.count) * 15
            maxPossible += 15
        }
        
        // Variety matching with flavor notes (15 points)
        if let flavorNotes = preferences.flavorNotes, !flavorNotes.isEmpty,
           let varieties = producer.varieties, !varieties.isEmpty {
            // Use semantic similarity for flavor notes
            let similarityScore = calculateSemanticSimilarity(
                userTerms: flavorNotes,
                producerTerms: varieties
            )
            score += similarityScore * 15
            maxPossible += 15
        }
        
        // Certification bonus (10 points)
        if let certifications = producer.certifications, !certifications.isEmpty {
            score += Double(certifications.count) * 2 // 2 points per certification, max 10
            score = min(score, maxPossible + 10)
            maxPossible += 10
        }
        
        // Scale to 40 points
        return maxPossible > 0 ? (score / maxPossible) * 40 : 0
    }
    
    /// Calculate proximity score based on distance (0-30 points)
    private func calculateProximityScore(producer: ProducerMapData, userLocation: CLLocation?) -> Double {
        guard let userLocation = userLocation,
              let producerCoordinate = producer.coordinate else {
            return 15 // Default mid-range score if no location data
        }
        
        let producerLocation = CLLocation(
            latitude: producerCoordinate.latitude,
            longitude: producerCoordinate.longitude
        )
        
        let distanceKm = userLocation.distance(from: producerLocation) / 1000
        
        // Scoring: closer = better
        // < 50km = 30 points
        // 50-100km = 25 points
        // 100-200km = 20 points
        // 200-500km = 15 points
        // > 500km = 10 points
        
        switch distanceKm {
        case 0..<50:
            return 30
        case 50..<100:
            return 25
        case 100..<200:
            return 20
        case 200..<500:
            return 15
        default:
            return 10
        }
    }
    
    /// Calculate engagement score based on conversation history (0-20 points)
    private func calculateEngagementScore(conversationCount: Int) -> Double {
        // More conversations = higher engagement
        switch conversationCount {
        case 5...:
            return 20
        case 3..<5:
            return 15
        case 1..<3:
            return 10
        default:
            return 0
        }
    }
    
    /// Calculate tour availability bonus (0-10 points)
    private func calculateTourScore(producer: ProducerMapData) -> Double {
        if producer.has_tourist_area == true && producer.tourist_accessible == true {
            return 10
        } else if producer.has_tourist_area == true {
            return 5
        }
        return 0
    }
    
    // MARK: - Semantic Similarity
    
    /// Calculate semantic similarity between user terms and producer terms
    private func calculateSemanticSimilarity(userTerms: [String], producerTerms: [String]) -> Double {
        guard let embedding = NLEmbedding.wordEmbedding(for: .spanish) else {
            // Fallback to simple string matching
            let userSet = Set(userTerms.map { $0.lowercased() })
            let producerSet = Set(producerTerms.map { $0.lowercased() })
            let intersection = userSet.intersection(producerSet)
            return Double(intersection.count) / Double(userTerms.count)
        }
        
        var totalSimilarity: Double = 0
        var comparisons = 0
        
        for userTerm in userTerms {
            for producerTerm in producerTerms {
                let distance = embedding.distance(between: userTerm.lowercased(), and: producerTerm.lowercased(), distanceType: .cosine)
                // Convert distance to similarity (closer = higher score)
                let similarityScore = max(0, 1 - distance)
                totalSimilarity += similarityScore
                comparisons += 1
            }
        }
        
        return comparisons > 0 ? totalSimilarity / Double(comparisons) : 0
    }
    
    // MARK: - Reason Generation
    
    /// Generate human-readable reasons for recommendation
    private func generateReasons(
        producer: ProducerMapData,
        preferences: UserPreferences,
        preferenceScore: Double,
        proximityScore: Double,
        tourScore: Double
    ) -> [String] {
        var reasons: [String] = []
        
        // Process matches
        if let userProcesses = preferences.processes,
           let producerProcesses = producer.processes {
            let matches = Set(userProcesses).intersection(Set(producerProcesses))
            if !matches.isEmpty {
                let processStr = matches.joined(separator: ", ")
                reasons.append("Usa procesos que prefieres: \(processStr)")
            }
        }
        
        // Flavor notes
        if let flavorNotes = preferences.flavorNotes, !flavorNotes.isEmpty {
            reasons.append("Compatible con tus notas favoritas: \(flavorNotes.joined(separator: ", "))")
        }
        
        // Location
        if proximityScore >= 25 {
            if let state = producer.state {
                reasons.append("Ubicado en \(state)")
            }
        }
        
        // Tour availability
        if tourScore > 0 {
            reasons.append("Ofrece tours y área de cata")
        }
        
        // Certifications
        if let certs = producer.certifications, !certs.isEmpty {
            reasons.append("Certificaciones: \(certs.joined(separator: ", "))")
        }
        
        return reasons.isEmpty ? ["Productor verificado"] : reasons
    }
    
    // MARK: - Helper Methods
    
    /// Load conversation counts for engagement scoring
    private func loadConversationCounts(userId: UUID) async -> [UUID: Int] {
        do {
            // Query to count messages per conversation for this user
            struct ConversationData: Codable {
                let producer_id: UUID
            }
            
            let conversations: [ConversationData] = try await supabase
                .from("conversations")
                .select("producer_id")
                .eq("client_id", value: userId.uuidString)
                .execute()
                .value
            
            // Count occurrences
            var counts: [UUID: Int] = [:]
            for conv in conversations {
                counts[conv.producer_id, default: 0] += 1
            }
            
            return counts
            
        } catch {
            print("⚠️ Error loading conversation counts: \(error)")
            return [:]
        }
    }
    
    /// Load generic recommendations when user has no preferences
    private func loadGenericRecommendations(limit: Int) async {
        await producerService.fetchProducers()
        let producers = producerService.producers.prefix(limit)
        
        recommendations = producers.map { producer in
            RecommendationScore(
                producer: producer,
                score: 50, // Neutral score
                reasons: ["Productor verificado"],
                breakdown: RecommendationScore.ScoreBreakdown(
                    preferenceMatch: 0,
                    proximityScore: 0,
                    engagementScore: 0,
                    tourAvailability: 0
                )
            )
        }
    }
    
    // MARK: - Public Helpers
    
    /// Get top match for a user
    func getTopMatch(for userId: UUID, userLocation: CLLocation? = nil) async -> RecommendationScore? {
        await generateRecommendations(for: userId, userLocation: userLocation, limit: 1)
        return recommendations.first
    }
    
    /// Get high-quality matches (score >= 85)
    var highMatches: [RecommendationScore] {
        recommendations.filter { $0.isHighMatch }
    }
}
