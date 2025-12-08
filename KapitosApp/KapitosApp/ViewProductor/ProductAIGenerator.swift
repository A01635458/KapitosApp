//
//  ProductAIGenerator.swift
//  KapitosApp
//
//  Sistema de Auto-Generación de Productos con Apple Intelligence
//  Usa Vision Framework + NaturalLanguage para generar info completa del producto
//

import UIKit
import Vision
import NaturalLanguage
import Combine
import SwiftUI

@MainActor
class ProductAIGenerator: ObservableObject {
    
    @Published var isProcessing = false
    @Published var progress: String = ""
    
    // MARK: - Resultado del análisis completo
    
    struct ProductAnalysis {
        let category: String
        let confidence: Float
        
        // Análisis visual
        let detectedText: [String]
        let dominantColors: [UIColor]
        let roastLevel: RoastLevel
        let packagingType: PackagingType
        
        // Contenido generado
        let title: String
        let description: String
        let suggestedPrice: Double
        let tastingNotes: [String]
        let brewingMethods: [String]
        let categorySpecificFields: [String: String]
    }
    
    enum RoastLevel: String {
        case light = "Tueste Claro"
        case medium = "Tueste Medio"
        case dark = "Tueste Oscuro"
        case unroasted = "Verde (Sin Tostar)"
    }
    
    enum PackagingType: String {
        case bag = "Bolsa"
        case can = "Lata"
        case jar = "Frasco"
        case bulk = "A Granel"
    }
    
    // MARK: - Análisis completo de imagen
    
    func analyzeProduct(image: UIImage) async -> ProductAnalysis? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        isProcessing = true
        progress = "Analizando imagen..."
        
        // 1️⃣ Clasificar categoría
        guard let (category, confidence) = await classifyCategory(ciImage: ciImage) else {
            isProcessing = false
            return nil
        }
        
        progress = "Detectado: \(category) (\(Int(confidence * 100))%)"
        
        // 2️⃣ Extraer texto con OCR
        progress = "Extrayendo texto..."
        let detectedText = await extractText(from: ciImage)
        
        // 3️⃣ Analizar características visuales
        progress = "Analizando características..."
        let colors = await analyzeDominantColors(image: image)
        let roastLevel = determineRoastLevel(colors: colors, category: category)
        let packaging = determinePackaging(from: detectedText, colors: colors)
        
        // 4️⃣ GENERAR TODO EL CONTENIDO
        progress = "Generando información del producto..."
        
        let title = generateTitle(category: category, text: detectedText, roast: roastLevel)
        let description = generateDescription(category: category, roast: roastLevel, text: detectedText)
        let price = suggestPrice(category: category, packaging: packaging)
        let tastingNotes = generateTastingNotes(category: category, roast: roastLevel)
        let methods = generateBrewingMethods(category: category)
        let specificFields = generateCategoryFields(category: category, roast: roastLevel, packaging: packaging)
        
        isProcessing = false
        progress = "¡Listo!"
        
        return ProductAnalysis(
            category: category,
            confidence: confidence,
            detectedText: detectedText,
            dominantColors: colors,
            roastLevel: roastLevel,
            packagingType: packaging,
            title: title,
            description: description,
            suggestedPrice: price,
            tastingNotes: tastingNotes,
            brewingMethods: methods,
            categorySpecificFields: specificFields
        )
    }
    
    // MARK: - 1️⃣ Clasificación con Core ML
    
    private func classifyCategory(ciImage: CIImage) async -> (String, Float)? {
        return await withCheckedContinuation { continuation in
            do {
                let model = try VNCoreMLModel(for: CoffeeType().model)
                
                let request = VNCoreMLRequest(model: model) { request, error in
                    if let results = request.results as? [VNClassificationObservation],
                       let top = results.first {
                        continuation.resume(returning: (top.identifier, top.confidence))
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
                
                let handler = VNImageRequestHandler(ciImage: ciImage)
                try handler.perform([request])
                
            } catch {
                print("Error: Error clasificando: \(error)")
                continuation.resume(returning: nil)
            }
        }
    }
    
    // MARK: - 2️⃣ OCR con Vision Framework
    
    private func extractText(from ciImage: CIImage) async -> [String] {
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let detectedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                continuation.resume(returning: detectedText)
            }
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["es-MX", "en-US"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([request])
            } catch {
                print("Error: Error en OCR: \(error)")
                continuation.resume(returning: [])
            }
        }
    }
    
    // MARK: - 3️⃣ Análisis de colores dominantes
    
    private func analyzeDominantColors(image: UIImage) async -> [UIColor] {
        guard let inputImage = CIImage(image: image) else { return [] }
        
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                     y: inputImage.extent.origin.y,
                                     z: inputImage.extent.size.width,
                                     w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                     parameters: [kCIInputImageKey: inputImage,
                                                  kCIInputExtentKey: extentVector]) else {
            return []
        }
        
        guard let outputImage = filter.outputImage else { return [] }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        let avgColor = UIColor(red: CGFloat(bitmap[0]) / 255,
                               green: CGFloat(bitmap[1]) / 255,
                               blue: CGFloat(bitmap[2]) / 255,
                               alpha: 1)
        
        return [avgColor]
    }
    
    // MARK: - 4️⃣ Determinar nivel de tueste
    
    private func determineRoastLevel(colors: [UIColor], category: String) -> RoastLevel {
        guard let color = colors.first else { return .medium }
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let brightness = (red + green + blue) / 3
        
        if category.lowercased().contains("verde") || category.lowercased().contains("green") {
            return .unroasted
        }
        
        if brightness > 0.6 {
            return .light
        } else if brightness > 0.35 {
            return .medium
        } else {
            return .dark
        }
    }
    
    // MARK: - 5️⃣ Determinar tipo de empaque
    
    private func determinePackaging(from text: [String], colors: [UIColor]) -> PackagingType {
        let combinedText = text.joined(separator: " ").lowercased()
        
        if combinedText.contains("kg") || combinedText.contains("granel") {
            return .bulk
        } else if combinedText.contains("lata") || combinedText.contains("can") {
            return .can
        } else if combinedText.contains("frasco") || combinedText.contains("jar") {
            return .jar
        } else {
            return .bag
        }
    }
    
    // MARK: - Generación de Contenido
    
    private func generateTitle(category: String, text: [String], roast: RoastLevel) -> String {
        // Intentar extraer marca del texto OCR
        let brandName = text.first { $0.count > 3 && $0.count < 20 } ?? "Café"
        
        let categoryName = category.capitalized
        
        // Si el texto ya tiene un buen nombre, usarlo
        if !text.isEmpty, let firstText = text.first, firstText.count > 5 {
            return firstText
        }
        
        return "\(brandName) \(categoryName) - \(roast.rawValue)"
    }
    
    private func generateDescription(category: String, roast: RoastLevel, text: [String]) -> String {
        let descriptions: [String: [String]] = [
            "Grano": [
                "Café en grano de alta calidad, perfecto para moler en casa y disfrutar de su frescura máxima.",
                "Granos cuidadosamente seleccionados que conservan todos sus aceites naturales y aromas.",
                "Ideal para los amantes del café que buscan controlar el molido según su método de preparación."
            ],
            "Molido": [
                "Café molido listo para preparar, con el punto perfecto de molienda para resultados consistentes.",
                "Molido artesanal que preserva el aroma y sabor característico de nuestro café.",
                "Practicidad sin sacrificar calidad, perfecto para tu rutina diaria."
            ],
            "Tostado": [
                "Café recién tostado siguiendo técnicas tradicionales que realzan sus mejores características.",
                "Tostado en lotes pequeños para garantizar frescura y control de calidad.",
                "El tueste perfecto que equilibra acidez, cuerpo y dulzura natural."
            ],
            "Verde": [
                "Café verde sin tostar, ideal para tostadores caseros o profesionales.",
                "Granos verdes de alta calidad que esperan tu toque personal de tostado.",
                "Materia prima premium para crear tu perfil de tueste personalizado."
            ]
        ]
        
        let baseDescriptions = descriptions[category] ?? descriptions["Grano"]!
        var finalDescription = baseDescriptions.randomElement()!
        
        // Agregar información del tueste
        switch roast {
        case .light:
            finalDescription += " Con tueste claro que preserva notas florales y frutales brillantes."
        case .medium:
            finalDescription += " Tueste medio que ofrece un balance perfecto entre acidez y cuerpo."
        case .dark:
            finalDescription += " Tueste oscuro con notas intensas de chocolate y caramelo."
        case .unroasted:
            finalDescription += " Grano verde listo para tostar según tu preferencia."
        }
        
        return finalDescription
    }
    
    private func suggestPrice(category: String, packaging: PackagingType) -> Double {
        var basePrice: Double
        
        switch category.lowercased() {
        case let c where c.contains("grano"):
            basePrice = 180.0
        case let c where c.contains("molido"):
            basePrice = 150.0
        case let c where c.contains("tostado"):
            basePrice = 200.0
        case let c where c.contains("verde"):
            basePrice = 120.0
        default:
            basePrice = 150.0
        }
        
        // Ajustar por tipo de empaque
        switch packaging {
        case .bulk:
            basePrice *= 0.8 // 20% descuento en granel
        case .can:
            basePrice *= 1.3 // 30% más caro en lata
        case .jar:
            basePrice *= 1.2
        case .bag:
            break
        }
        
        return basePrice
    }
    
    private func generateTastingNotes(category: String, roast: RoastLevel) -> [String] {
        let lightNotes = ["Floral", "Cítrico", "Frutas rojas", "Té negro", "Miel"]
        let mediumNotes = ["Chocolate con leche", "Caramelo", "Nueces", "Frutas dulces", "Vainilla"]
        let darkNotes = ["Chocolate oscuro", "Especias", "Ahumado", "Frutos secos", "Melaza"]
        let greenNotes = ["Herbáceo", "Fresco", "Vegetal"]
        
        var notes: [String]
        
        switch roast {
        case .light:
            notes = lightNotes.shuffled().prefix(3).map { $0 }
        case .medium:
            notes = mediumNotes.shuffled().prefix(3).map { $0 }
        case .dark:
            notes = darkNotes.shuffled().prefix(3).map { $0 }
        case .unroasted:
            notes = greenNotes
        }
        
        return notes
    }
    
    private func generateBrewingMethods(category: String) -> [String] {
        if category.lowercased().contains("molido") {
            return ["Cafetera de filtro", "Prensa francesa", "Chemex", "V60"]
        } else if category.lowercased().contains("grano") {
            return ["Espresso", "Cafetera de filtro", "Prensa francesa", "Cold brew", "Aeropress"]
        } else {
            return ["Espresso", "Cafetera de filtro", "Prensa francesa"]
        }
    }
    
    private func generateCategoryFields(category: String, roast: RoastLevel, packaging: PackagingType) -> [String: String] {
        var fields: [String: String] = [:]
        
        fields["Categoría"] = category
        fields["Nivel de tueste"] = roast.rawValue
        fields["Tipo de empaque"] = packaging.rawValue
        fields["Peso sugerido"] = packaging == .bulk ? "1kg" : "250g"
        fields["Origen"] = "México"
        fields["Proceso"] = ["Lavado", "Natural", "Honey"].randomElement()!
        
        if category.lowercased().contains("grano") {
            fields["Molido recomendado"] = ["Fino", "Medio", "Grueso"].randomElement()!
        }
        
        if roast != .unroasted {
            fields["Fecha de tueste"] = "Reciente"
            fields["Perfil de taza"] = ["Balanceado", "Complejo", "Dulce"].randomElement()!
        }
        
        return fields
    }
}
