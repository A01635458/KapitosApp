import Foundation
import Supabase
import Combine

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
            let dto = ProducerInsertDTO(
                id: nil, // dejar que Postgres genere uuid
                farm_name: form.brand.trimmingCharacters(in: .whitespacesAndNewlines),
                experience_years: 0,
                phone: form.phone.trimmingCharacters(in: .whitespacesAndNewlines),
                photo_url: nil,
                farm_size_ha: Double(form.farmSize),
                country: nil,
                state: nil,
                municipality: emptyToNil(form.location),
                shade_type: emptyToNil(form.shadeType),
                annual_production_kg: Int(form.production),
                last_harvest_date: parseHarvestDate(form.harvestDate),
                yield_per_ha: Double(form.yield),
                price_per_kg: Double(form.price),
                current_buyers: emptyToNil(form.sellingTo),
                min_contract_volume: Int(form.minVolume),
                open_to_export: normalizedYes(form.exportReady),
                sells_online: normalizedYes(form.onlineSales),
                online_store_url: nil,
                needs: emptyToNil(form.needs),
                has_tourist_area: normalizedYes(form.hasTastingArea),
                tourist_accessible: normalizedYes(form.touristAccess),
                tourism_details: nil,
                varieties: splitList(form.varieties),
                processes: splitList(form.processes),
                certifications: splitList(form.certifications)
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

private func parseHarvestDate(_ input: String) -> String? {
    let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
    if cleaned.isEmpty { return nil }
    // Esperado: mm/aaaa o mm/yyyy -> devolver yyyy-mm-01
    let parts = cleaned.replacingOccurrences(of: "-", with: "/").split(separator: "/")
    guard parts.count == 2 else { return nil }
    let monthStr = String(parts[0])
    let yearStr = String(parts[1])
    guard let month = Int(monthStr), (1...12).contains(month), let year = Int(yearStr), year > 1900 else { return nil }
    let monthPadded = String(format: "%02d", month)
    return "\(year)-\(monthPadded)-01" // formato YYYY-MM-DD para columna date
}

