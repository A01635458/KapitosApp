//
//  MockProducer.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import CoreLocation
import Combine 

struct MockProducer: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let profileImage: String
    let bio: String
    let schedule: String
}

let mockCafe = MockProducer(
    name: "Café de Córdoba",
    coordinate: CLLocationCoordinate2D(latitude: 18.8841, longitude: -96.9310),
    profileImage: "cafe_cordoba",   // asegúrate de agregar esta imagen en Assets
    bio: "Café veracruzano de altura con tradición desde 1800. Procesos lavados y naturales.",
    schedule: "Lun–Dom: 7:00–20:00"
)
