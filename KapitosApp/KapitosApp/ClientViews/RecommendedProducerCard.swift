//
//  RecommendedProducerCard.swift
//  KapitosApp
//

import SwiftUI

struct RecommendedProducerCard: View {
    
    let recommendation: RecommendationScore
    let onTap: () -> Void
    
    @EnvironmentObject var theme: AppThemeManager
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Producer Photo
                if let photoUrl = recommendation.producer.photo_url,
                   let url = URL(string: photoUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        producerPlaceholder
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    producerPlaceholder
                }
                
                // Producer Info
                VStack(alignment: .leading, spacing: 6) {
                    // Name
                    Text(recommendation.producer.displayName)
                        .font(.headline)
                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        .lineLimit(1)
                    
                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(recommendation.producer.locationDescription)
                            .font(.caption)
                    }
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.7) : AppColors.textLight.opacity(0.7))
                    .lineLimit(1)
                    
                    // Compatibility Score
                    HStack(spacing: 6) {
                        // Score badge
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text(recommendation.scorePercentage)
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(scoreColor(for: recommendation.score))
                        .cornerRadius(8)
                        
                        Text("compatible")
                            .font(.caption2)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.6) : AppColors.textLight.opacity(0.6))
                    }
                    
                    // Primary Reason
                    if !recommendation.reasons.isEmpty {
                        Text(recommendation.primaryReason)
                            .font(.caption2)
                            .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.5) : AppColors.textLight.opacity(0.5))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.isDarkMode ? AppColors.cardDark : Color.white)
                    .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Views
    
    private var producerPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(theme.isDarkMode ? AppColors.textDark.opacity(0.2) : AppColors.textLight.opacity(0.2))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.title)
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.5) : AppColors.textLight.opacity(0.5))
            )
    }
    
    // MARK: - Helper Functions
    
    private func scoreColor(for score: Double) -> Color {
        switch score {
        case 85...:
            return .green
        case 70..<85:
            return .orange
        default:
            return .blue
        }
    }
}

// MARK: - Expanded Recommendation Detail View

struct RecommendationDetailView: View {
    
    let recommendation: RecommendationScore
    @EnvironmentObject var theme: AppThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("¿Por qué recomendamos este productor?")
                        .font(.title2.bold())
                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.6) : AppColors.textLight.opacity(0.6))
                    }
                }
                .padding(.bottom, 10)
                
                // Overall Score
                VStack(spacing: 8) {
                    Text(recommendation.scorePercentage)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    
                    Text("Compatible contigo")
                        .font(.headline)
                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.isDarkMode ? AppColors.cardDark : Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                )
                
                // Score Breakdown
                VStack(alignment: .leading, spacing: 16) {
                    Text("Desglose de Compatibilidad")
                        .font(.headline)
                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    
                    scoreBreakdownRow(
                        title: "Preferencias de café",
                        score: recommendation.breakdown.preferenceMatch,
                        maxScore: 40,
                        icon: "heart.fill",
                        color: .pink
                    )
                    
                    scoreBreakdownRow(
                        title: "Proximidad",
                        score: recommendation.breakdown.proximityScore,
                        maxScore: 30,
                        icon: "location.fill",
                        color: .blue
                    )
                    
                    scoreBreakdownRow(
                        title: "Interacción previa",
                        score: recommendation.breakdown.engagementScore,
                        maxScore: 20,
                        icon: "message.fill",
                        color: .green
                    )
                    
                    scoreBreakdownRow(
                        title: "Tours disponibles",
                        score: recommendation.breakdown.tourAvailability,
                        maxScore: 10,
                        icon: "map.fill",
                        color: .orange
                    )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.isDarkMode ? AppColors.cardDark : Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                )
                
                // Reasons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Razones principales")
                        .font(.headline)
                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    
                    ForEach(recommendation.reasons, id: \.self) { reason in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Text(reason)
                                .font(.subheadline)
                                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.isDarkMode ? AppColors.cardDark : Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                )
            }
            .padding(20)
        }
        .background((theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight).ignoresSafeArea())
    }
    
    // MARK: - Score Breakdown Row
    
    private func scoreBreakdownRow(title: String, score: Double, maxScore: Double, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                
                Spacer()
                
                Text("\(Int(score))/\(Int(maxScore))")
                    .font(.subheadline.bold())
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.isDarkMode ? Color.white.opacity(0.1) : Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (score / maxScore), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}
