//
//  LocationPickerPreview.swift
//  KapitosApp
//
//  Preview y ejemplos de uso del selector de ubicación
//

import SwiftUI
import MapKit

// MARK: - Ejemplo de Uso Básico

struct LocationPickerExample: View {
    @State private var showPicker = false
    @State private var selectedLocation: LocationData?
    @EnvironmentObject var theme: AppThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            if let location = selectedLocation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ubicación Seleccionada:")
                        .font(.headline)
                    
                    Text(location.address)
                        .font(.body)
                    
                    Text("Lat: \(location.coordinate.latitude, specifier: "%.6f")")
                        .font(.caption)
                    
                    Text("Lon: \(location.coordinate.longitude, specifier: "%.6f")")
                        .font(.caption)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            }
            
            Button("Seleccionar Ubicación") {
                showPicker = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $showPicker) {
            MapLocationPickerView { location in
                selectedLocation = location
            }
            .environmentObject(theme)
        }
    }
}

// MARK: - Ejemplo con Formulario

struct FormWithLocationExample: View {
    @State private var farmName = ""
    @State private var showLocationPicker = false
    @State private var location = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    
    @EnvironmentObject var theme: AppThemeManager
    
    var body: some View {
        Form {
            Section("Datos de la Finca") {
                TextField("Nombre de la finca", text: $farmName)
                
                Button(action: { showLocationPicker = true }) {
                    HStack {
                        Image(systemName: "map.fill")
                        if location.isEmpty {
                            Text("Seleccionar ubicación")
                                .foregroundColor(.gray)
                        } else {
                            VStack(alignment: .leading) {
                                Text(location)
                                if let lat = latitude, let lon = longitude {
                                    Text("Lat: \(lat, specifier: "%.6f"), Lon: \(lon, specifier: "%.6f")")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section {
                Button("Guardar") {
                    // Guardar datos
                }
                .disabled(farmName.isEmpty || latitude == nil)
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            MapLocationPickerView { locationData in
                latitude = locationData.coordinate.latitude
                longitude = locationData.coordinate.longitude
                location = locationData.address
            }
            .environmentObject(theme)
        }
    }
}

// MARK: - Preview

#Preview("Location Picker") {
    MapLocationPickerView { location in
        print("Selected: \(location.address)")
    }
    .environmentObject(AppThemeManager())
}

#Preview("Simple Example") {
    LocationPickerExample()
        .environmentObject(AppThemeManager())
}

#Preview("Form Example") {
    FormWithLocationExample()
        .environmentObject(AppThemeManager())
}

// MARK: - Casos de Prueba

extension LocationPickerViewModel {
    /// Casos de prueba para diferentes ubicaciones cafetaleras en México
    static let testLocations = [
        // Chiapas - Principal productor
        CLLocationCoordinate2D(latitude: 16.7569, longitude: -93.1292),
        
        // Veracruz - Coatepec (famoso por café)
        CLLocationCoordinate2D(latitude: 19.4518, longitude: -96.9570),
        
        // Oaxaca - Pluma Hidalgo
        CLLocationCoordinate2D(latitude: 15.9254, longitude: -96.4169),
        
        // Puebla - Sierra Norte
        CLLocationCoordinate2D(latitude: 20.0911, longitude: -97.9653),
        
        // Guerrero
        CLLocationCoordinate2D(latitude: 17.5516, longitude: -99.5024),
    ]
}

// MARK: - Utilidades de Testing

struct LocationPickerTestView: View {
    @StateObject private var viewModel = LocationPickerViewModel()
    
    var body: some View {
        VStack {
            Text("Test Locations")
                .font(.headline)
            
            ForEach(Array(LocationPickerViewModel.testLocations.enumerated()), id: \.offset) { index, coordinate in
                Button("Test Location \(index + 1)") {
                    viewModel.centerCoordinate = coordinate
                    viewModel.updateCenterAddress(coordinate: coordinate)
                    viewModel.mapCameraPosition = .region(
                        MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                }
            }
            
            if !viewModel.centerAddress.isEmpty {
                Text(viewModel.centerAddress)
                    .font(.caption)
                    .padding()
            }
        }
    }
}

#Preview("Test Locations") {
    LocationPickerTestView()
}
