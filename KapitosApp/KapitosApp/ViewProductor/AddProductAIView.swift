//
//  AddProductAIView.swift
//  KapitosApp
//
//  Sistema de Auto-Generación de Productos con Apple Intelligence
//  Foto → Producto listo en 3 segundos
//

import SwiftUI
import PhotosUI

struct AddProductAIView: View {

    @EnvironmentObject var store: ProducerStore
    @EnvironmentObject var theme: AppThemeManager
    @Environment(\.dismiss) var dismiss

    // AI Generator
    @StateObject private var aiGenerator = ProductAIGenerator()
    
    // Imagen
    @State private var selectedImage: UIImage?
    @State private var analysisResult: ProductAIGenerator.ProductAnalysis?

    // Contenido generado (editable)
    @State private var generatedTitle = ""
    @State private var generatedDescription = ""
    @State private var generatedPrice = ""
    @State private var generatedTastingNotes = ""
    @State private var generatedMethods = ""
    @State private var generatedWeight = "250g"
    @State private var categoryFieldsText = ""

    // Estados UI
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showAnalysisDetails = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var showImageSourceDialog = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 26) {

                    Text("Agregar Producto con AI")
                        .font(.largeTitle.bold())
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                        .padding(.top, 6)

                    // ---------------------------
                    // IMAGEN + ANÁLISIS
                    // ---------------------------

                    VStack(spacing: 12) {
                        Button { showImageSourceDialog = true } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                    .frame(height: 220)

                                if let img = selectedImage {
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 220)
                                        .clipped()
                                        .cornerRadius(16)
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                        Text("Tomar foto o elegir imagen")
                                            .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                        
                        // Estado de procesamiento
                        if aiGenerator.isProcessing {
                            VStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(
                                        tint: theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight
                                    ))
                                Text(aiGenerator.progress)
                                    .font(.caption)
                                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))
                            }
                            .padding()
                        }
                        
                        // Resultado del análisis
                        if let analysis = analysisResult {
                            analysisCard(analysis)
                        }
                    }

                    // ---------------------------
                    // CAMPOS EDITABLES
                    // ---------------------------

                    VStack(spacing: 20) {
                        
                        // TÍTULO
                        inputWithDice(
                            label: "Título del producto",
                            text: $generatedTitle,
                            action: { regenerateTitle() }
                        )

                        // DESCRIPCIÓN
                        editorWithDice(
                            label: "Descripción de marketing",
                            text: $generatedDescription,
                            height: 120,
                            action: { regenerateDescription() }
                        )

                        // PRECIO Y PESO
                        HStack(spacing: 12) {
                            inputWithDice(
                                label: "Precio (MXN)",
                                text: $generatedPrice,
                                keyboard: .decimalPad,
                                action: { regeneratePrice() }
                            )
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Peso")
                                    .font(.subheadline)
                                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                                
                                TextField("", text: $generatedWeight)
                                    .keyboardType(.default)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                    .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                    .cornerRadius(18)
                            }
                        }

                        // NOTAS DE SABOR
                        editorWithDice(
                            label: "Notas de sabor",
                            text: $generatedTastingNotes,
                            height: 100,
                            action: { regenerateTastingNotes() }
                        )

                        // MÉTODOS DE PREPARACIÓN
                        editorWithDice(
                            label: "Métodos de preparación",
                            text: $generatedMethods,
                            height: 100,
                            action: { regenerateMethods() }
                        )

                        // CAMPOS ESPECÍFICOS
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Información adicional")
                                .font(.subheadline)
                                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))

                            TextEditor(text: $categoryFieldsText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .cornerRadius(18)
                                .frame(height: 120)
                        }

                        // BOTÓN GUARDAR
                        Button {
                            Task {
                                await saveProduct()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text(analysisResult != nil ? "Guardar Producto" : "Guardar (sin análisis)")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                            .cornerRadius(16)
                            .shadow(color: (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight).opacity(0.3), 
                                   radius: 8, y: 4)
                        }
                        .disabled(generatedTitle.isEmpty || generatedPrice.isEmpty)
                        .padding(.top, 10)
                    }

                }
                .padding(22)
            }
            .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Agregar imagen", isPresented: $showImageSourceDialog) {
                Button("📸 Tomar foto") {
                    showCamera = true
                }
                Button("🖼️ Elegir de galería") {
                    showImagePicker = true
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("El AI analizará la imagen automáticamente")
            }
            .photosPicker(isPresented: $showImagePicker, selection: $pickerItem, matching: .images)
            .onChange(of: pickerItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(image: $selectedImage)
            }
            .onChange(of: selectedImage) { _ in
                if let img = selectedImage {
                    Task {
                        await processImage(img)
                    }
                }
            }
        }
    }
    
    // MARK: - Analysis Card
    
    func analysisCard(_ analysis: ProductAIGenerator.ProductAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Análisis completado")
                        .font(.headline)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                    
                    Text("\(analysis.category.uppercased()) · \(Int(analysis.confidence * 100))% confianza")
                        .font(.subheadline)
                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                }
                
                Spacer()
                
                Button {
                    showAnalysisDetails.toggle()
                } label: {
                    Image(systemName: showAnalysisDetails ? "chevron.up" : "chevron.down")
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                }
            }
            
            if showAnalysisDetails {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    detailRow("Tueste", analysis.roastLevel.rawValue)
                    detailRow("Empaque", analysis.packagingType.rawValue)
                    
                    if !analysis.detectedText.isEmpty {
                        detailRow("Texto detectado", analysis.detectedText.prefix(3).joined(separator: ", "))
                    }
                }
                .font(.caption)
            }
        }
        .padding()
        .background(theme.isDarkMode ? AppColors.cardDark.opacity(0.5) : AppColors.cardLight.opacity(0.5))
        .cornerRadius(12)
    }
    
    func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label + ":")
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.6) : AppColors.textLight.opacity(0.6))
            Text(value)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
        }
    }

    // MARK: - Procesamiento de imagen con AI
    
    func processImage(_ image: UIImage) async {
        guard let analysis = await aiGenerator.analyzeProduct(image: image) else {
            return
        }
        
        analysisResult = analysis
        
        // Rellenar campos con los datos generados
        generatedTitle = analysis.title
        generatedDescription = analysis.description
        generatedPrice = String(format: "%.0f", analysis.suggestedPrice)
        generatedTastingNotes = analysis.tastingNotes.joined(separator: ", ")
        generatedMethods = analysis.brewingMethods.joined(separator: ", ")
        
        // Formatear campos específicos
        var fieldsText = ""
        for (key, value) in analysis.categorySpecificFields.sorted(by: { $0.key < $1.key }) {
            fieldsText += "\(key): \(value)\n"
        }
        categoryFieldsText = fieldsText
        
        if let weight = analysis.categorySpecificFields["Peso sugerido"] {
            generatedWeight = weight
        }
    }

    // MARK: - Guardado
    
    func saveProduct() async {
        guard let priceValue = Double(generatedPrice) else { return }

        let product = ProducerProduct(
            name: generatedTitle,
            price: priceValue,
            weight: generatedWeight,
            image: selectedImage?.jpegData(compressionQuality: 0.8),
            description: generatedDescription.isEmpty ? nil : generatedDescription,
            tastingNotes: generatedTastingNotes.isEmpty ? nil : generatedTastingNotes.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            brewingMethods: generatedMethods.isEmpty ? nil : generatedMethods.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            category: analysisResult?.category,
            roastLevel: analysisResult?.roastLevel.rawValue,
            packagingType: analysisResult?.packagingType.rawValue,
            categoryFields: analysisResult?.categorySpecificFields
        )
        
        let success = await store.saveProduct(product)
        
        if success {
            dismiss()
        }
    }

    // MARK: - Regeneración individual
    
    func regenerateTitle() {
        guard let analysis = analysisResult else { return }
        let alternatives = [
            "\(analysis.category) Premium",
            "Café \(analysis.category) Especial",
            "\(analysis.roastLevel.rawValue) - \(analysis.category)",
            "Selección \(analysis.category)"
        ]
        generatedTitle = alternatives.randomElement()!
    }
    
    func regenerateDescription() {
        guard let analysis = analysisResult else { return }
        let alternatives = [
            "Café de alta calidad con \(analysis.roastLevel.rawValue.lowercased()), perfecto para los amantes del buen café.",
            "Disfruta de un café excepcional con notas únicas que realzan cada taza.",
            "Café artesanal cuidadosamente seleccionado para ofrecerte la mejor experiencia."
        ]
        generatedDescription = alternatives.randomElement()!
    }
    
    func regeneratePrice() {
        guard let current = Double(generatedPrice) else { return }
        let variations = [current * 0.9, current, current * 1.1, current * 1.2]
        generatedPrice = String(format: "%.0f", variations.randomElement()!)
    }
    
    func regenerateTastingNotes() {
        let allNotes = ["Chocolate", "Caramelo", "Frutas rojas", "Cítrico", "Nueces", "Floral", "Especias", "Vainilla"]
        generatedTastingNotes = allNotes.shuffled().prefix(3).joined(separator: ", ")
    }
    
    func regenerateMethods() {
        let allMethods = ["Espresso", "Prensa francesa", "V60", "Chemex", "Aeropress", "Cold brew", "Cafetera"]
        generatedMethods = allMethods.shuffled().prefix(3).joined(separator: ", ")
    }

    // MARK: - Input with dice button
    
    func inputWithDice(label: String,
                       text: Binding<String>,
                       keyboard: UIKeyboardType = .default,
                       action: @escaping () -> Void) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(label)
                .font(.subheadline)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))

            HStack {
                TextField("", text: text)
                    .keyboardType(keyboard)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

                Button(action: action) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18))
                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        .padding(.trailing, 14)
                }
            }
            .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }

    // MARK: - Editor with dice button
    
    func editorWithDice(label: String,
                        text: Binding<String>,
                        height: CGFloat,
                        action: @escaping () -> Void) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(label)
                .font(.subheadline)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))

            ZStack(alignment: .topTrailing) {

                TextEditor(text: text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                    .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                    .cornerRadius(18)
                    .frame(height: height)
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)

                Button(action: action) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18))
                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        .padding(14)
                }
            }
        }
    }
}

// MARK: - CÁMARA

struct CameraView: UIViewControllerRepresentable {

    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        controller.sourceType = .camera
        controller.allowsEditing = false
        return controller
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let uiImg = info[.originalImage] as? UIImage {
                parent.image = uiImg
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
