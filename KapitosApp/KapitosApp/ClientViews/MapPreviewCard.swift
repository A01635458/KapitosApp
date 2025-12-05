//
//  MapPreviewCard.swift
//  KapitosApp
//

import SwiftUI
import MapKit

struct MapPreviewCard: View {
    
    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var mapService = ProducerMapService()
    @Binding var currentScreen: AppScreen
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 22.7709, longitude: -102.5832), // Zacatecas center
        span: MKCoordinateSpan(latitudeDelta: 15.0, longitudeDelta: 15.0)
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
            
            // ---- MAP WITH REAL PRODUCERS ----
            Map(coordinateRegion: $region, annotationItems: mapService.producers) { producer in
                MapAnnotation(coordinate: producer.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
                    if let photoUrl = producer.photo_url, !photoUrl.isEmpty {
                        AsyncImage(url: URL(string: photoUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ZStack {
                                Circle()
                                    .fill(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                Image(systemName: "cup.and.saucer.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(
                                theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                                lineWidth: 2
                            )
                        )
                        .shadow(radius: 4)
                    } else {
                        ZStack {
                            Circle()
                                .fill(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        .overlay(
                            Circle().stroke(
                                theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight,
                                lineWidth: 2
                            )
                        )
                        .shadow(radius: 4)
                    }
                }
            }
            .preferredColorScheme(theme.isDarkMode ? .dark : .light)
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
            
            // Loading indicator
            if mapService.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                        .background(
                            (theme.isDarkMode ? Color.black : Color.white)
                                .opacity(0.7)
                        )
                        .cornerRadius(12)
                    Spacer()
                }
            }
            
            // Producer count badge
            if !mapService.producers.isEmpty {
                VStack {
                    HStack {
                        Spacer()
                        Text("\(mapService.producers.count)")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                            .cornerRadius(12)
                            .padding(12)
                    }
                    Spacer()
                }
            }
        }
        .frame(height: 240)
        .padding(.horizontal, 20)
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentScreen = .map
            }
        }
        .task {
            await mapService.fetchProducers()
            
            // Center map on producers if available
            if let firstProducer = mapService.producers.first,
               let coordinate = firstProducer.coordinate {
                region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 15.0, longitudeDelta: 15.0)
                )
            }
        }
    }
}
