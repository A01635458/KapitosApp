//
//  LocationPickerViewModel.swift
//  KapitosApp
//
//  Created by GitHub Copilot on 04/12/25.
//

import Foundation
import MapKit
import SwiftUI
import Combine

/// Represents a location with coordinates and address
struct LocationData: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let address: String
    let name: String?
    
    static func == (lhs: LocationData, rhs: LocationData) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.address == rhs.address
    }
}

@MainActor
class LocationPickerViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var searchResults: [MKMapItem] = []
    @Published var isSearching: Bool = false
    @Published var selectedLocation: LocationData?
    @Published var mapCameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), // Mexico City default
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @Published var centerCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)
    @Published var centerAddress: String = ""
    
    private var searchTask: Task<Void, Never>?
    private let geocoder = CLGeocoder()
    
    /// Search for locations in Mexico based on search text
    func searchLocations() {
        searchTask?.cancel()
        
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        searchTask = Task {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = searchText
                request.resultTypes = [.address, .pointOfInterest]
                
                // Limit search to Mexico
                let mexicoRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 23.6345, longitude: -102.5528),
                    span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30)
                )
                request.region = mexicoRegion
                
                let search = MKLocalSearch(request: request)
                let response = try await search.start()
                
                if !Task.isCancelled {
                    searchResults = response.mapItems
                    isSearching = false
                }
            } catch {
                if !Task.isCancelled {
                    print("Search error: \(error.localizedDescription)")
                    searchResults = []
                    isSearching = false
                }
            }
        }
    }
    
    /// Select a location from search results
    func selectSearchResult(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        let address = formatAddress(from: item.placemark)
        
        selectedLocation = LocationData(
            coordinate: coordinate,
            address: address,
            name: item.name
        )
        
        // Update map position
        mapCameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
        
        centerCoordinate = coordinate
        centerAddress = address
        
        // Clear search
        searchResults = []
        searchText = ""
    }
    
    /// Update the center address when map is moved
    func updateCenterAddress(coordinate: CLLocationCoordinate2D) {
        centerCoordinate = coordinate
        
        Task {
            do {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                
                if let placemark = placemarks.first {
                    let address = formatAddress(from: placemark)
                    await MainActor.run {
                        centerAddress = address
                    }
                }
            } catch {
                print("Geocoding error: \(error.localizedDescription)")
                await MainActor.run {
                    centerAddress = "Ubicación seleccionada"
                }
            }
        }
    }
    
    /// Confirm the current center location
    func confirmLocation() -> LocationData {
        return LocationData(
            coordinate: centerCoordinate,
            address: centerAddress.isEmpty ? "Ubicación seleccionada" : centerAddress,
            name: nil
        )
    }
    
    /// Format address from placemark
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []
        
        if let name = placemark.name {
            components.append(name)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        
        return components.isEmpty ? "Ubicación en México" : components.joined(separator: ", ")
    }
    
    /// Format address from MKPlacemark
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var components: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            components.append(thoroughfare)
        }
        if let subThoroughfare = placemark.subThoroughfare {
            components.append(subThoroughfare)
        }
        if let locality = placemark.locality {
            components.append(locality)
        }
        if let state = placemark.administrativeArea {
            components.append(state)
        }
        
        return components.isEmpty ? "Ubicación en México" : components.joined(separator: ", ")
    }
}
