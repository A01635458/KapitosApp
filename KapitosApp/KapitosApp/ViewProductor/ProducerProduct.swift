//
//  ProducerProduct.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import Foundation

struct ProducerProduct: Identifiable, Codable {
    var id = UUID()
    var name: String
    var price: Double
    var weight: String
    var image: Data?
    var imageUrl: String? // URL de Supabase Storage
    
    // Nuevos campos generados por AI
    var description: String?
    var tastingNotes: [String]?
    var brewingMethods: [String]?
    var category: String?
    var roastLevel: String?
    var packagingType: String?
    var categoryFields: [String: String]?
}
