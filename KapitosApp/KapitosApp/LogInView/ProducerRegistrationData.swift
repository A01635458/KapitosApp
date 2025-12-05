import Foundation
import Supabase
import Combine
import UIKit

class ProducerRegistrationData: ObservableObject {

    @Published var isLoading = false
    @Published var submitMessage: String? = nil

    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )

    func submitProducer(form: ProducerFormModel) async {

        do {
            isLoading = true
            submitMessage = nil
            
            // 1. Upload image if present
            var photoUrl: String? = nil
            if let image = form.profileImage {
                photoUrl = await uploadProducerImage(image: image, producerName: form.brand)
            }
            
            let dto = ProducerInsertDTO(
                id: nil, // dejar que Postgres genere uuid
                farm_name: form.brand.trimmingCharacters(in: .whitespacesAndNewlines),
                experience_years: Int(form.experienceYears),
                phone: form.phone.trimmingCharacters(in: .whitespacesAndNewlines),
                photo_url: photoUrl,
                farm_size_ha: Double(form.farmSize),
                country: "México",
                state: form.state,
                municipality: form.municipality ?? emptyToNil(form.locationAddress ?? form.location),
                latitude: form.latitude,
                longitude: form.longitude,
                shade_coverage_percent: Int(form.shadeCoverage),
                annual_production_kg: Int(form.production),
                last_harvest_date: formatHarvestDate(month: form.harvestMonth, year: form.harvestYear),
                yield_per_ha: Double(form.yield),
                price_per_kg: Double(form.price),
                sales_types: splitList(form.salesTypes),
                min_contract_volume: Int(form.minVolume),
                open_to_export: normalizedYes(form.exportReady),
                sells_online: normalizedYes(form.onlineSales),
                online_store_url: nil,
                has_tourist_area: normalizedYes(form.hasTastingArea),
                tourist_accessible: normalizedYes(form.touristAccess),
                tourism_details: nil,
                varieties: splitList(form.varieties),
                processes: splitList(form.processes),
                certifications: splitList(form.certifications),
                altitude: Int(form.altitude),
                consent_gps: form.consentGPS,
                consent_ai: form.consentAI,
                consent_notifications: form.consentNotifications,
                status: "pending" // Mark as pending for admin approval
            )

            // --- INSERT ---
            do {
                try await supabase
                    .from("producers")
                    .insert(dto)
                    .execute()
            } catch {
                // Log detallado para diagnosticar errores (por ejemplo RLS, formato de fecha, tipos)
                print("[Supabase Insert Error]", error)
                throw error
            }

            submitMessage = "Registro enviado correctamente ✔️"

        } catch {
            submitMessage = "Error al enviar: \(error.localizedDescription)"
        }

        isLoading = false
    }
    
    // MARK: - Image Upload
    
    private func uploadProducerImage(image: UIImage, producerName: String) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("❌ Failed to convert image to JPEG")
            return nil
        }
        
        do {
            let fileName = "\(UUID().uuidString)_\(producerName.replacingOccurrences(of: " ", with: "_")).jpg"
            let filePath = "producer_photos/\(fileName)"
            
            // Upload to Supabase Storage
            let uploadedFile = try await supabase.storage
                .from("producer-profiles")
                .upload(path: filePath, file: imageData, options: .init(contentType: "image/jpeg"))
            
            // Get public URL
            let publicURL = try supabase.storage
                .from("producer-profiles")
                .getPublicURL(path: filePath)
            
            print("✅ Image uploaded successfully: \(publicURL)")
            return publicURL.absoluteString
            
        } catch {
            print("❌ Error uploading image: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Helpers Parse / Normalization

private func normalizedYes(_ value: String) -> Bool {
    let lower = value.folding(options: .diacriticInsensitive, locale: .current).lowercased()
    return ["si", "sí", "yes", "true", "1"].contains(lower)
}

private func splitList(_ raw: String) -> [String] {
    raw
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}

private func emptyToNil(_ text: String) -> String? {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
}

private func formatHarvestDate(month: Int, year: Int) -> String {
    let monthPadded = String(format: "%02d", month)
    return "\(year)-\(monthPadded)-01" // formato YYYY-MM-DD para columna date
}

