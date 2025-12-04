//
//  MapView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 15/11/25.
//

import SwiftUI
import MapKit

struct MapView: View {

    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var mapService = ProducerMapService()
    @State private var selectedProducer: ProducerMapData?
    @State private var showStore = false

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), // Mexico City default
            span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
        )
    )

    var body: some View {

        ZStack {
            Map(
                position: $position,
                interactionModes: .all
            ) {
                // Dynamic producer annotations from database
                ForEach(mapService.producers) { producer in
                    if let coordinate = producer.coordinate {
                        Annotation(producer.displayName, coordinate: coordinate) {
                            Button {
                                selectedProducer = producer
                                showStore = true
                            } label: {
                                VStack(spacing: 4) {
                                    // Profile image or placeholder
                                    if let photoUrl = producer.photo_url, !photoUrl.isEmpty {
                                        AsyncImage(url: URL(string: photoUrl)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Image(systemName: "cup.and.saucer.fill")
                                                .resizable()
                                                .padding(12)
                                                .foregroundColor(.white)
                                                .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                        }
                                        .frame(width: 65, height: 65)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight, lineWidth: 3)
                                        )
                                        .shadow(radius: 6)
                                    } else {
                                        // Placeholder icon
                                        ZStack {
                                            Circle()
                                                .fill(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                                .frame(width: 65, height: 65)
                                            
                                            Image(systemName: "cup.and.saucer.fill")
                                                .font(.system(size: 28))
                                                .foregroundColor(.white)
                                        }
                                        .overlay(
                                            Circle()
                                                .stroke(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight, lineWidth: 3)
                                        )
                                        .shadow(radius: 6)
                                    }

                                    Image(systemName: "triangle.fill")
                                        .font(.system(size: 12))
                                        .rotationEffect(.degrees(180))
                                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                }
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .preferredColorScheme(theme.isDarkMode ? .dark : .light)
            .ignoresSafeArea()

            // Header with title and loading indicator
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Productores de Café")
                            .font(.title3.bold())
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        
                        Text("\(mapService.producers.count) fincas")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if mapService.isLoading {
                        ProgressView()
                            .scaleEffect(0.9)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    (theme.isDarkMode ? AppColors.cardDark : .white)
                        .opacity(0.95)
                )
                .cornerRadius(16)
                .shadow(radius: 4)
                .padding(.top, 50)
                .padding(.horizontal, 16)
                
                Spacer()
            }
            
            // Error message
            if let error = mapService.errorMessage {
                VStack {
                    Spacer()
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .cornerRadius(12)
                        .padding()
                }
            }
        }
        .sheet(isPresented: $showStore) {
            if let producer = selectedProducer {
                ProducerDetailSheetView(producer: producer)
                    .environmentObject(theme)
            }
        }
        .task {
            await mapService.fetchProducers()
        }
    }
}
