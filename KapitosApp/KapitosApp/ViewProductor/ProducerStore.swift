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
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var logoImage: UIImage? = nil

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
                
                // Load logo image from URL if available
                if let photoUrl = producer.photo_url, !photoUrl.isEmpty {
                    Task {
                        await loadLogoImageFromURL(photoUrl)
                    }
                }
                
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
    
    /// Carga el logo desde una URL
    private func loadLogoImageFromURL(_ urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.logoImage = image
                }
            }
        } catch {
            print("❌ Error loading logo image from URL: \(error)")
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
    
    /// Sube el logo del productor a Supabase Storage y actualiza la base de datos
    func uploadLogo(_ image: UIImage) async -> Bool {
        do {
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                print("❌ Could not convert image to JPEG")
                return false
            }
            
            print("📤 Uploading logo for producer: \(currentUserId.uuidString)")
            
            let fileName = "\(currentUserId.uuidString)/logo.jpg"
            let bucket = "producer-profiles"
            
            // Upload to storage
            try await client.storage
                .from(bucket)
                .upload(
                    path: fileName,
                    file: imageData,
                    options: .init(contentType: "image/jpeg", upsert: true)
                )
            
            // Get public URL
            let publicURL = try client.storage
                .from(bucket)
                .getPublicURL(path: fileName)
            
            let urlString = publicURL.absoluteString
            print("✅ Logo uploaded to: \(urlString)")
            
            // Update producer record with new photo_url
            try await client
                .from("producers")
                .update(["photo_url": urlString])
                .eq("id", value: currentUserId.uuidString)
                .execute()
            
            print("✅ Producer photo_url updated in database")
            
            // Update local state
            await MainActor.run {
                self.logoImage = image
            }
            
            return true
        } catch {
            print("❌ Error uploading logo: \(error)")
            errorMessage = "Error al subir logo: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Guarda los cambios de información del negocio en la base de datos
    func saveBusinessInfo() async {
        do {
            print("💾 Saving business info for producer: \(currentUserId.uuidString)")
            
            try await client
                .from("producers")
                .update([
                    "farm_name": businessName,
                    "phone": phone
                ])
                .eq("id", value: currentUserId.uuidString)
                .execute()
            
            print("✅ Business info saved successfully")
        } catch {
            print("❌ Error saving business info: \(error)")
            errorMessage = "Error al guardar: \(error.localizedDescription)"
        }
    }
}
