//
//  MapPreviewCard.swift
//  KapitosApp
//

import SwiftUI
import MapKit

struct MapPreviewCard: View {
    
    @EnvironmentObject var theme: AppThemeManager
    @Binding var currentScreen: AppScreen
    
    @State private var region = MKCoordinateRegion(
        center: mockCafe.coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
    )
    
    var body: some View {
        ZStack {
            // ---- BACKGROUND CARD (MATCH HOME STYLE) ----
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    theme.isDarkMode
                        ? AppColors.cardDark.opacity(0.55)
                        : AppColors.cardLight.opacity(0.95)
                )
                .shadow(
                    color: theme.isDarkMode
                        ? Color.black.opacity(0.35)
                        : Color.black.opacity(0.12),
                    radius: 6, x: 0, y: 4
                )
            
            // ---- MAP ITSELF ----
            Map(coordinateRegion: $region)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            theme.isDarkMode
                                ? AppColors.cardDark.opacity(0.5)
                                : AppColors.cardLight.opacity(0.7),
                            lineWidth: 1
                        )
                )
                .allowsHitTesting(false)
            
            // ---- PIN DEL PRODUCTOR ----
            VStack {
                Spacer()
                
                Image(mockCafe.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 78, height: 78)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(
                            theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                            lineWidth: 4
                        )
                    )
                    .shadow(
                        color: theme.isDarkMode
                            ? AppColors.accentDark.opacity(0.4)
                            : AppColors.accentLight.opacity(0.4),
                        radius: 8
                    )
                
                Spacer().frame(height: 14)
            }
        }
        .frame(height: 240)
        .padding(.horizontal, 20)
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentScreen = .map
            }
        }
    }
}
