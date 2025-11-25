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
}
