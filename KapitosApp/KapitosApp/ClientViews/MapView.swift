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
    let currentUserId: UUID
    @StateObject private var mapService = ProducerMapService()
    @State private var selectedProducer: ProducerMapData?
    @State private var showStore = false
    @State private var searchText = ""
    @State private var filteredProducers: [ProducerMapData] = []
    @State private var showSuggestions = false

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 22.7709, longitude: -102.5832), // Zacatecas center
            span: MKCoordinateSpan(latitudeDelta: 15.0, longitudeDelta: 15.0)
        )
    )
    
    var displayedProducers: [ProducerMapData] {
        if searchText.isEmpty {
            return mapService.producers
        } else {
            return filteredProducers
        }
    }

    var body: some View {

        ZStack {
            Map(
                position: $position,
                interactionModes: .all
            ) {
                // Dynamic producer annotations from database
                ForEach(displayedProducers) { producer in
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
            
            // Search bar overlay at toolbar height
            VStack(spacing: 0) {
                searchBarSection
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
                ProducerDetailSheetView(producer: producer, currentUserId: currentUserId)
                    .environmentObject(theme)
            }
        }
        .task {
            await mapService.fetchProducers()
        }
    }
    
    // MARK: - Search Bar Section
    
    private var searchBarSection: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                    
                    TextField("Buscar por nombre o ubicación...", text: $searchText)
                        .textFieldStyle(.plain)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                        .onChange(of: searchText) { oldValue, newValue in
                            filterProducers()
                            showSuggestions = !newValue.isEmpty && !filteredProducers.isEmpty
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            filteredProducers = []
                            showSuggestions = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(theme.isDarkMode ? AppColors.backgroundDark.opacity(0.95) : AppColors.cardLight.opacity(0.95))
                .cornerRadius(10)
                .shadow(radius: 2)
                
                if mapService.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 60)
            .padding(.top, 60) // Align with toolbar/sidebar button
            
            // Autocomplete suggestions
            if showSuggestions && !searchText.isEmpty {
                VStack(spacing: 0) {
                    ForEach(filteredProducers.prefix(5)) { producer in
                        Button(action: {
                            selectProducer(producer)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                    .font(.system(size: 20))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(producer.farm_name)
                                        .font(.body)
                                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                        .lineLimit(1)
                                    
                                    Text(producer.locationDescription)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.left")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(theme.isDarkMode ? AppColors.cardDark : .white)
                        }
                        
                        if producer.id != filteredProducers.prefix(5).last?.id {
                            Divider()
                                .padding(.leading, 48)
                        }
                    }
                }
                .background(theme.isDarkMode ? AppColors.cardDark : .white)
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.horizontal, 60)
                .padding(.top, 4)
            }
            
            // Info card
            if !showSuggestions {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Productores de Café")
                            .font(.headline)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        
                        Text("\(displayedProducers.count) fincas\(searchText.isEmpty ? "" : " encontradas")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    (theme.isDarkMode ? AppColors.cardDark : .white)
                        .opacity(0.95)
                )
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding(.horizontal, 60)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Filter Function
    
    private func filterProducers() {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        
        if query.isEmpty {
            filteredProducers = []
            return
        }
        
        // Filter and sort by relevance
        let matches = mapService.producers.filter { producer in
            let farmName = producer.farm_name.lowercased()
            let municipality = producer.municipality?.lowercased() ?? ""
            let state = producer.state?.lowercased() ?? ""
            
            // Check if query matches at the start of any word
            let farmWords = farmName.components(separatedBy: " ")
            let municipalityWords = municipality.components(separatedBy: " ")
            let stateWords = state.components(separatedBy: " ")
            
            let startsWithMatch = farmWords.contains(where: { $0.hasPrefix(query) }) ||
                                 municipalityWords.contains(where: { $0.hasPrefix(query) }) ||
                                 stateWords.contains(where: { $0.hasPrefix(query) })
            
            // Also check varieties
            let varietyMatch = producer.varieties?.contains(where: { 
                $0.lowercased().hasPrefix(query) 
            }) == true
            
            return startsWithMatch || varietyMatch
        }
        
        // Sort by relevance: exact farm name match first, then others
        filteredProducers = matches.sorted { first, second in
            let firstName = first.farm_name.lowercased()
            let secondName = second.farm_name.lowercased()
            
            let firstStarts = firstName.hasPrefix(query)
            let secondStarts = secondName.hasPrefix(query)
            
            if firstStarts && !secondStarts {
                return true
            } else if !firstStarts && secondStarts {
                return false
            }
            
            // If both start with query or neither does, sort alphabetically
            return firstName < secondName
        }
    }
    
    // MARK: - Select Producer
    
    private func selectProducer(_ producer: ProducerMapData) {
        searchText = producer.farm_name
        showSuggestions = false
        
        // Center map on selected producer
        if let coordinate = producer.coordinate {
            withAnimation {
                position = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )
                )
            }
            
            // Optionally show details after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                selectedProducer = producer
                showStore = true
            }
        }
    }
}


