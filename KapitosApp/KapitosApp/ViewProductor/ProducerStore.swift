//
//  ProducerStore.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//
import SwiftUI
import Combine

class ProducerStore: ObservableObject {

    // --- BUSINESS INFO ---
    @Published var businessName: String = "Café El Bosque"
    @Published var phone: String = "5551234567"
    @Published var address: String = "San Cristóbal, Chiapas"
    @Published var schedule: String = "Lun - Vie · 8am - 6pm"
    @Published var description: String = "Café de especialidad producido en altura."

    @Published var bannerImage: UIImage? = UIImage(named: "banner_mock")
    @Published var profileImage: UIImage? = UIImage(systemName: "leaf.fill")

    // --- PRODUCTS ---
    @Published var products: [ProducerProduct] = [
        ProducerProduct(
            name: "Café Honey",
            price: 280,
            weight: "1 kg",
            image: nil
        )
    ]

    // --- CUSTOMER VIEW PREVIEW ---
    var displayName: String { businessName }
    var displayAddress: String { address }
}
