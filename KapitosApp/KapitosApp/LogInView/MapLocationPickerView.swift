//
//  MapLocationPickerView.swift
//  KapitosApp
//
//  Created by GitHub Copilot on 04/12/25.
//

import SwiftUI
import MapKit

struct MapLocationPickerView: View {
    
    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var viewModel = LocationPickerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var onLocationConfirmed: (LocationData) -> Void
    
    var body: some View {
        ZStack {
            // Background
            (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Search Bar
                searchBarView
                
                // Search Results List
                if !viewModel.searchResults.isEmpty {
                    searchResultsList
                }
                
                // Map with center pin
                mapView
                
                // Selected location info
                locationInfoView
                
                // Confirm button
                confirmButton
            }
        }
        .onAppear {
            // Set initial center address
            viewModel.updateCenterAddress(coordinate: viewModel.centerCoordinate)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : .gray)
            }
            
            Spacer()
            
            Text("Seleccionar Ubicación")
                .font(.headline)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            
            Spacer()
            
            // Placeholder for symmetry
            Color.clear
                .frame(width: 30, height: 30)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(theme.isDarkMode ? AppColors.cardDark : .white)
    }
    
    // MARK: - Search Bar
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Buscar tu finca cafetalera...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                .onChange(of: viewModel.searchText) { oldValue, newValue in
                    viewModel.searchLocations()
                }
            
            if viewModel.isSearching {
                ProgressView()
                    .scaleEffect(0.8)
            }
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                    viewModel.searchResults = []
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.cardLight)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Search Results
    
    private var searchResultsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.searchResults, id: \.self) { item in
                    Button(action: {
                        viewModel.selectSearchResult(item)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if let name = item.name {
                                    Text(name)
                                        .font(.body)
                                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                        .lineLimit(1)
                                }
                                
                                if let address = formatItemAddress(item) {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(theme.isDarkMode ? AppColors.cardDark : .white)
                    }
                    
                    Divider()
                        .padding(.leading, 52)
                }
            }
        }
        .frame(maxHeight: 200)
        .background(theme.isDarkMode ? AppColors.cardDark : .white)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .shadow(radius: 4)
    }
    
    // MARK: - Map
    
    private var mapView: some View {
        ZStack {
            Map(position: $viewModel.mapCameraPosition, interactionModes: .all)
                .mapStyle(.standard(elevation: .realistic))
                .mapControlVisibility(.hidden)
                .preferredColorScheme(theme.isDarkMode ? .dark : .light)
                .onMapCameraChange { context in
                    // Update center coordinate as map moves
                    viewModel.updateCenterAddress(coordinate: context.region.center)
                }
            
            // Fixed center pin
            VStack {
                Spacer()
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    .shadow(radius: 4)
                Spacer()
            }
            
            // Instruction text at top
            VStack {
                Text("Mueve el mapa para ajustar la posición exacta")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding(.top, 12)
                
                Spacer()
            }
        }
        .frame(maxHeight: .infinity)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Location Info
    
    private var locationInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                
                Text("Ubicación seleccionada:")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(viewModel.centerAddress.isEmpty ? "Cargando dirección..." : viewModel.centerAddress)
                .font(.body)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                .lineLimit(2)
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Text("Lat:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.6f", viewModel.centerCoordinate.latitude))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                }
                
                HStack(spacing: 4) {
                    Text("Lon:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.6f", viewModel.centerCoordinate.longitude))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(theme.isDarkMode ? AppColors.cardDark : .white)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Confirm Button
    
    private var confirmButton: some View {
        Button(action: {
            let location = viewModel.confirmLocation()
            onLocationConfirmed(location)
            dismiss()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Confirmar Ubicación")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .disabled(viewModel.centerAddress.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func formatItemAddress(_ item: MKMapItem) -> String? {
        let placemark = item.placemark
        var components: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}

// MARK: - Preview

#Preview {
    MapLocationPickerView { location in
        print("Location confirmed: \(location.address)")
    }
    .environmentObject(AppThemeManager())
}
