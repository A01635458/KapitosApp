//
//  ProducerStore.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//
import SwiftUI
import Combine
import Supabase

@MainActor
class ProducerStore: ObservableObject {
    
    private let client: SupabaseClient = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )
    
    let currentUserId: UUID

    // --- BUSINESS INFO ---
    @Published var businessName: String = "Cargando..."
    @Published var phone: String = ""
    @Published var address: String = ""
    @Published var schedule: String = "Lun - Vie · 8am - 6pm"
    @Published var description: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var bannerImage: UIImage? = UIImage(named: "banner_mock")
    @Published var profileImage: UIImage? = UIImage(systemName: "leaf.fill")

    // --- PRODUCTS ---
    @Published var products: [ProducerProduct] = []

    // --- CUSTOMER VIEW PREVIEW ---
    var displayName: String { businessName }
    var displayAddress: String { address }
    
    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
        Task {
            await loadProducerData()
            await loadProducts()
        }
    }
    
    func loadProducerData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 Loading producer data for user: \(currentUserId.uuidString)")
            
            // Load producer info from database
            let response: [Producer] = try await client
                .from("producers")
                .select()
                .eq("id", value: currentUserId.uuidString)
                .execute()
                .value
            
            if let producer = response.first {
                print("✅ Producer found: \(producer.displayName)")
                
                // Update business info with real fields from database
                businessName = producer.farm_name ?? "Productor"
                phone = producer.phone ?? ""
                
                // Build address from location fields
                var locationParts: [String] = []
                if let municipality = producer.municipality {
                    locationParts.append(municipality)
                }
                if let state = producer.state {
                    locationParts.append(state)
                }
                address = locationParts.joined(separator: ", ")
                
                // Build description from available data
                var descParts: [String] = []
                if let varieties = producer.varieties, !varieties.isEmpty {
                    descParts.append("Variedades: \(varieties.joined(separator: ", "))")
                }
                if let altitude = producer.altitude {
                    descParts.append("cultivado a \(altitude)m de altura")
                }
                if let municipality = producer.municipality {
                    descParts.append("en \(municipality)")
                }
                description = descParts.isEmpty ? "Productor de café" : descParts.joined(separator: " ")
                
                print("📋 Producer data loaded successfully")
            } else {
                print("⚠️ No producer found for this user")
                errorMessage = "No se encontró información del productor"
                businessName = "Productor"
            }
            
            isLoading = false
        } catch {
            print("❌ Error loading producer data: \(error)")
            errorMessage = "Error al cargar datos: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Products Management
    
    /// Carga todos los productos del productor desde Supabase
    func loadProducts() async {
        do {
            print("🔍 Loading products for producer: \(currentUserId.uuidString)")
            
            struct ProductDTO: Codable {
                let id: UUID
                let producer_id: UUID
                let name: String
                let price: Double
                let weight: String
                let image_url: String?
                let description: String?
                let tasting_notes: [String]?
                let brewing_methods: [String]?
                let category: String?
                let roast_level: String?
                let packaging_type: String?
                let category_fields: [String: String]?
                let is_active: Bool
                let created_at: String?
            }
            
            let response: [ProductDTO] = try await client
                .from("producer_products")
                .select()
                .eq("producer_id", value: currentUserId.uuidString)
                .eq("is_active", value: true)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            print("✅ Loaded \(response.count) products from database")
            
            // Convertir DTOs a ProducerProduct con imageUrl de Supabase
            self.products = response.map { dto in
                ProducerProduct(
                    id: dto.id,
                    name: dto.name,
                    price: dto.price,
                    weight: dto.weight,
                    image: nil,
                    imageUrl: dto.image_url,
                    description: dto.description,
                    tastingNotes: dto.tasting_notes,
                    brewingMethods: dto.brewing_methods,
                    category: dto.category,
                    roastLevel: dto.roast_level,
                    packagingType: dto.packaging_type,
                    categoryFields: dto.category_fields
                )
            }
            
        } catch {
            print("❌ Error loading products: \(error)")
            errorMessage = "Error al cargar productos: \(error.localizedDescription)"
        }
    }
    
    /// Guarda un nuevo producto en Supabase
    func saveProduct(_ product: ProducerProduct) async -> Bool {
        do {
            print("💾 Saving product: \(product.name)")
            
            struct ProductInsertDTO: Codable {
                let id: UUID
                let producer_id: UUID
                let name: String
                let price: Double
                let weight: String
                let image_url: String?
                let description: String?
                let tasting_notes: [String]?
                let brewing_methods: [String]?
                let category: String?
                let roast_level: String?
                let packaging_type: String?
                let category_fields: [String: String]?
            }
            
            // TODO: Subir imagen a Supabase Storage si existe
            var imageUrl: String? = nil
            if let imageData = product.image {
                imageUrl = try await uploadProductImage(imageData, productId: product.id)
            }
            
            let dto = ProductInsertDTO(
                id: product.id,
                producer_id: currentUserId,
                name: product.name,
                price: product.price,
                weight: product.weight,
                image_url: imageUrl,
                description: product.description,
                tasting_notes: product.tastingNotes,
                brewing_methods: product.brewingMethods,
                category: product.category,
                roast_level: product.roastLevel,
                packaging_type: product.packagingType,
                category_fields: product.categoryFields
            )
            
            try await client
                .from("producer_products")
                .insert(dto)
                .execute()
            
            print("✅ Product saved successfully")
            
            // Recargar productos
            await loadProducts()
            
            return true
        } catch {
            print("❌ Error saving product: \(error)")
            errorMessage = "Error al guardar producto: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Actualiza un producto existente
    func updateProduct(_ product: ProducerProduct) async -> Bool {
        do {
            print("🔄 Updating product: \(product.name)")
            
            // Si hay una nueva imagen, subirla
            var imageUrl: String? = product.imageUrl
            if let imageData = product.image {
                imageUrl = try await uploadProductImage(imageData, productId: product.id)
            }
            
            struct ProductUpdateDTO: Codable {
                let name: String
                let price: Double
                let weight: String
                let image_url: String?
                let description: String?
                let tasting_notes: [String]?
                let brewing_methods: [String]?
                let category: String?
                let roast_level: String?
                let packaging_type: String?
                let category_fields: [String: String]?
            }
            
            let dto = ProductUpdateDTO(
                name: product.name,
                price: product.price,
                weight: product.weight,
                image_url: imageUrl,
                description: product.description,
                tasting_notes: product.tastingNotes,
                brewing_methods: product.brewingMethods,
                category: product.category,
                roast_level: product.roastLevel,
                packaging_type: product.packagingType,
                category_fields: product.categoryFields
            )
            
            try await client
                .from("producer_products")
                .update(dto)
                .eq("id", value: product.id.uuidString)
                .execute()
            
            print("✅ Product updated successfully")
            await loadProducts()
            
            return true
        } catch {
            print("❌ Error updating product: \(error)")
            errorMessage = "Error al actualizar producto: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Elimina un producto (soft delete)
    func deleteProduct(_ product: ProducerProduct) async -> Bool {
        do {
            print("🗑️ Deleting product: \(product.name)")
            
            try await client
                .from("producer_products")
                .update(["is_active": false])
                .eq("id", value: product.id.uuidString)
                .execute()
            
            print("✅ Product deleted successfully")
            await loadProducts()
            
            return true
        } catch {
            print("❌ Error deleting product: \(error)")
            errorMessage = "Error al eliminar producto: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Sube una imagen de producto a Supabase Storage
    private func uploadProductImage(_ imageData: Data, productId: UUID) async throws -> String {
        let fileName = "\(currentUserId.uuidString)/\(productId.uuidString).jpg"
        let bucket = "product-images"
        
        try await client.storage
            .from(bucket)
            .upload(
                path: fileName,
                file: imageData,
                options: .init(contentType: "image/jpeg")
            )
        
        let publicURL = try client.storage
            .from(bucket)
            .getPublicURL(path: fileName)
        
        return publicURL.absoluteString
    }
}
