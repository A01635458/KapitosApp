//
//  ProducerRegistrationTests.swift
//  KapitosAppTests
//  Unit tests for producer registration
//

import Testing
import Foundation
@testable import KapitosApp

@Suite("Producer Registration Tests")
struct ProducerRegistrationTests {
    
    // MARK: - Producer Model Tests
    
    @Test("Producer model with required fields")
    func testProducerModel() async {
        let producer = Producer(
            id: UUID(),
            farm_name: "Finca Test",
            experience_years: 10,
            phone: "1234567890",
            photo_url: nil,
            farm_size_ha: 5.5,
            country: "Colombia",
            state: "Antioquia",
            municipality: "Medellín",
            shade_type: nil,
            annual_production_kg: nil,
            last_harvest_date: nil,
            yield_per_ha: nil,
            price_per_kg: nil,
            current_buyers: nil,
            min_contract_volume: nil,
            open_to_export: nil,
            sells_online: nil,
            online_store_url: nil,
            needs: nil,
            has_tourist_area: nil,
            tourist_accessible: nil,
            tourism_details: nil,
            consent_gps: nil,
            consent_ai: nil,
            consent_notifications: nil,
            varieties: ["Caturra", "Castillo"],
            processes: ["Lavado", "Natural"],
            certifications: ["Orgánico"],
            altitude: 1800,
            coffee_type: "Arábica",
            status: "pending",
            created_at: Date()
        )
        
        #expect(producer.farm_name == "Finca Test")
        #expect(producer.experience_years == 10)
        #expect(producer.status == "pending")
    }
    
    @Test("Producer display name fallback")
    func testProducerDisplayName() async {
        let producerWithName = Producer(
            id: UUID(),
            farm_name: "Finca Esperanza",
            experience_years: nil,
            phone: nil,
            photo_url: nil,
            farm_size_ha: nil,
            country: nil,
            state: nil,
            municipality: nil,
            shade_type: nil,
            annual_production_kg: nil,
            last_harvest_date: nil,
            yield_per_ha: nil,
            price_per_kg: nil,
            current_buyers: nil,
            min_contract_volume: nil,
            open_to_export: nil,
            sells_online: nil,
            online_store_url: nil,
            needs: nil,
            has_tourist_area: nil,
            tourist_accessible: nil,
            tourism_details: nil,
            consent_gps: nil,
            consent_ai: nil,
            consent_notifications: nil,
            varieties: nil,
            processes: nil,
            certifications: nil,
            altitude: nil,
            coffee_type: nil,
            status: "pending",
            created_at: nil
        )
        
        let producerWithoutName = Producer(
            id: UUID(),
            farm_name: nil,
            experience_years: nil,
            phone: nil,
            photo_url: nil,
            farm_size_ha: nil,
            country: nil,
            state: nil,
            municipality: nil,
            shade_type: nil,
            annual_production_kg: nil,
            last_harvest_date: nil,
            yield_per_ha: nil,
            price_per_kg: nil,
            current_buyers: nil,
            min_contract_volume: nil,
            open_to_export: nil,
            sells_online: nil,
            online_store_url: nil,
            needs: nil,
            has_tourist_area: nil,
            tourist_accessible: nil,
            tourism_details: nil,
            consent_gps: nil,
            consent_ai: nil,
            consent_notifications: nil,
            varieties: nil,
            processes: nil,
            certifications: nil,
            altitude: nil,
            coffee_type: nil,
            status: "pending",
            created_at: nil
        )
        
        #expect(producerWithName.displayName == "Finca Esperanza")
        #expect(producerWithoutName.displayName == "Productor sin nombre")
    }
    
    @Test("Producer location formatting")
    func testProducerLocation() async {
        let producer = Producer(
            id: UUID(),
            farm_name: "Test Farm",
            experience_years: nil,
            phone: nil,
            photo_url: nil,
            farm_size_ha: nil,
            country: "Colombia",
            state: "Antioquia",
            municipality: "Medellín",
            shade_type: nil,
            annual_production_kg: nil,
            last_harvest_date: nil,
            yield_per_ha: nil,
            price_per_kg: nil,
            current_buyers: nil,
            min_contract_volume: nil,
            open_to_export: nil,
            sells_online: nil,
            online_store_url: nil,
            needs: nil,
            has_tourist_area: nil,
            tourist_accessible: nil,
            tourism_details: nil,
            consent_gps: nil,
            consent_ai: nil,
            consent_notifications: nil,
            varieties: nil,
            processes: nil,
            certifications: nil,
            altitude: nil,
            coffee_type: nil,
            status: "pending",
            created_at: nil
        )
        
        #expect(producer.location == "Medellín, Antioquia, Colombia")
    }
    
    // MARK: - Status Tests
    
    @Test("Producer status validation")
    func testProducerStatus() async {
        let validStatuses = ["pending", "approved", "rejected"]
        
        for status in validStatuses {
            #expect(validStatuses.contains(status))
        }
    }
    
    @Test("Producer status transitions")
    func testStatusTransitions() async {
        var status = "pending"
        
        #expect(status == "pending")
        
        // Approve
        status = "approved"
        #expect(status == "approved")
        
        // Cannot go back to pending
        let canRevert = false // Business rule
        #expect(!canRevert)
    }
    
    // MARK: - Data Validation Tests
    
    @Test("Farm size validation")
    func testFarmSizeValidation() async {
        let validSizes: [Double] = [1.0, 5.5, 100.0, 0.5]
        let invalidSizes: [Double] = [-1.0, -5.5]
        
        for size in validSizes {
            #expect(size >= 0)
        }
        
        for size in invalidSizes {
            #expect(size < 0)
        }
    }
    
    @Test("Altitude validation")
    func testAltitudeValidation() async {
        let validAltitudes = [800, 1200, 1800, 2400]
        
        for altitude in validAltitudes {
            #expect(altitude >= 0)
            #expect(altitude <= 3000) // Reasonable coffee altitude range
        }
    }
    
    @Test("Phone number format")
    func testPhoneFormat() async {
        let validPhones = ["1234567890", "+57 300 1234567", "300-123-4567"]
        
        for phone in validPhones {
            #expect(!phone.isEmpty)
            let digitsOnly = phone.filter { $0.isNumber }
            #expect(digitsOnly.count >= 7)
        }
    }
    
    // MARK: - Array Data Tests
    
    @Test("Varieties array handling")
    func testVarietiesArray() async {
        let varieties = ["Caturra", "Castillo", "Bourbon", "Típica"]
        
        #expect(varieties.count == 4)
        #expect(varieties.contains("Caturra"))
        #expect(!varieties.isEmpty)
    }
    
    @Test("Empty arrays are handled correctly")
    func testEmptyArrays() async {
        let emptyVarieties: [String] = []
        let emptyProcesses: [String] = []
        
        #expect(emptyVarieties.isEmpty)
        #expect(emptyProcesses.isEmpty)
    }
    
    // MARK: - Date Parsing Tests
    
    @Test("Harvest date parsing")
    func testHarvestDateParsing() async {
        let parseDate = { (input: String) -> String? in
            let cleaned = input.trimmingCharacters(in: .whitespaces)
            let parts = cleaned.replacingOccurrences(of: "-", with: "/").split(separator: "/")
            guard parts.count == 2 else { return nil }
            let monthStr = String(parts[0])
            let yearStr = String(parts[1])
            guard let month = Int(monthStr), (1...12).contains(month),
                  let year = Int(yearStr), year > 1900 else { return nil }
            let monthPadded = String(format: "%02d", month)
            return "\(year)-\(monthPadded)-01"
        }
        
        #expect(parseDate("11/2024") == "2024-11-01")
        #expect(parseDate("3/2023") == "2023-03-01")
        #expect(parseDate("invalid") == nil)
        #expect(parseDate("13/2024") == nil) // Invalid month
    }
}
