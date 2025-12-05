
//
//  AddProductAIView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 05/12/25.
//

import SwiftUI
import PhotosUI
import CoreML
import Vision

struct AddProductAIView: View {

    @EnvironmentObject var store: ProducerStore
    @Environment(\.dismiss) var dismiss

    // Imagen
    @State private var selectedImage: UIImage?
    @State private var detectedCategory: String?

    // Contenido generado
    @State private var generatedTitle = ""
    @State private var generatedDescription = ""
    @State private var generatedPrice = ""
    @State private var generatedTastingNotes = ""
    @State private var generatedMethods = ""
    @State private var categoryFields = ""

    // Estados
    @State private var isGenerating = false
    @State private var showImagePicker = false
    @State private var showCamera = false

    // Core ML Model
    private let coffeeModel = CoffeeType()

    var body: some View {

        ScrollView {
            VStack(spacing: 26) {

                Text("Agregar con AI")
                    .font(.largeTitle.bold())
                    .foregroundColor(AppColors.textLight)
                    .padding(.top, 6)

                // ---------------------------
                // IMAGEN
                // ---------------------------

                Button { mostrarOpcionesImagen() } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.cardLight)
                            .frame(height: 200)

                        if let img = selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(16)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "camera")
                                    .font(.system(size: 34))
                                    .foregroundColor(AppColors.accentLight)
                                Text("Tomar foto o elegir")
                                    .foregroundColor(AppColors.textLight)
                            }
                        }
                    }
                }

                // 🔥 CLASIFICACIÓN MOSTRADA
                if let cat = detectedCategory {
                    Text("Detectamos: **\(cat.uppercased())**")
                        .font(.headline)
                        .foregroundColor(AppColors.textLight)
                }

                if isGenerating {
                    ProgressView("Generando información…")
                }

                // ---------------------------
                // TÍTULO (con dado)
                // ---------------------------

                inputWithDice(
                    label: "Título del producto",
                    text: $generatedTitle,
                    action: generateTitle
                )

                // ---------------------------
                // DESCRIPCIÓN (with dice)
                // ---------------------------

                editorWithDice(
                    label: "Descripción de marketing",
                    text: $generatedDescription,
                    height: 150,
                    action: generateDescription
                )

                // ---------------------------
                // PRECIO
                // ---------------------------

                inputWithDice(
                    label: "Precio sugerido",
                    text: $generatedPrice,
                    keyboard: .decimalPad,
                    action: generatePrice
                )

                // ---------------------------
                // NOTAS
                // ---------------------------

                editorWithDice(
                    label: "Notas de sabor",
                    text: $generatedTastingNotes,
                    height: 120,
                    action: generateTastingNotes
                )

                // ---------------------------
                // MÉTODOS
                // ---------------------------

                editorWithDice(
                    label: "Métodos de preparación",
                    text: $generatedMethods,
                    height: 120,
                    action: generateMethods
                )

                // ---------------------------
                // CAMPOS ESPECÍFICOS
                // ---------------------------

                VStack(alignment: .leading, spacing: 6) {
                    Text("Campos específicos")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textLight.opacity(0.8))

                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(AppColors.cardLight)
                            .frame(height: 110)
                            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)

                        TextEditor(text: $categoryFields)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(AppColors.textLight)
                    }
                }

                // ---------------------------
                // GUARDAR
                // ---------------------------

                Button {
                    saveProduct()
                } label: {
                    Text("Guardar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.accentLight)
                        .cornerRadius(16)
                }
                .padding(.top, 20)

            }
            .padding(22)
        }
        .photosPicker(isPresented: $showImagePicker,
                      selection: .constant(nil),
                      matching: .images)
        .sheet(isPresented: $showCamera) {
            CameraView(image: $selectedImage)
        }
        .onChange(of: selectedImage) { _ in
            if let img = selectedImage {
                classifyImage(img)
            }
        }
    }

    // ---------------------------
    // GUARDADO
    // ---------------------------

    func saveProduct() {
        guard let p = Double(generatedPrice) else { return }

        store.products.append(
            ProducerProduct(
                name: generatedTitle,
                price: p,
                weight: generatedMethods,
                image: selectedImage?.jpegData(compressionQuality: 0.8)
            )
        )

        dismiss()
    }

    // ---------------------------
    // CLASIFICACIÓN CON CORE ML
    // ---------------------------

    func classifyImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }

        do {
            let vnModel = try VNCoreMLModel(for: coffeeModel.model)

            let request = VNCoreMLRequest(model: vnModel) { request, error in

                if let results = request.results as? [VNClassificationObservation],
                   let top = results.first {

                    DispatchQueue.main.async {
                        detectedCategory = top.identifier
                        generatedTitle = top.identifier.capitalized   // ⭐ LO QUE PEDISTE
                    }
                }
            }

            let handler = VNImageRequestHandler(ciImage: ciImage)
            try handler.perform([request])

        } catch {
            print("❌ Error clasificando: \(error)")
        }
    }

    // ---------------------------
    // PLACEHOLDERS DADOS
    // ---------------------------

    func generateTitle() { generatedTitle = ["Café Especial", "Blend de la Casa", "Café Orgánico"].randomElement()! }
    func generateDescription() { generatedDescription = ["Descripción A", "Descripción B", "Descripción C"].randomElement()! }
    func generatePrice() { generatedPrice = ["120", "140", "180"].randomElement()! }
    func generateTastingNotes() { generatedTastingNotes = ["Notas dulces", "Chocolate", "Frutal"].randomElement()! }
    func generateMethods() { generatedMethods = ["Espresso", "Filtro", "Cold Brew"].randomElement()! }

    // ---------------------------
    // MENÚ DE IMAGEN
    // ---------------------------

    func mostrarOpcionesImagen() {
        let alert = UIAlertController(title: "Agregar imagen",
                                      message: nil,
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Tomar foto", style: .default) { _ in
            showCamera = true
        })

        alert.addAction(UIAlertAction(title: "Elegir de galería", style: .default) { _ in
            showImagePicker = true
        })

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }

    // ---------------------------
    // INPUT C/ DADO
    // ---------------------------

    func inputWithDice(label: String,
                       text: Binding<String>,
                       keyboard: UIKeyboardType = .default,
                       action: @escaping () -> Void) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.textLight.opacity(0.8))

            HStack {
                TextField("", text: text)
                    .keyboardType(keyboard)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .foregroundColor(AppColors.textLight)

                Button(action: action) {
                    Image(systemName: "dice")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.accentLight)
                        .padding(.trailing, 14)
                }
            }
            .background(AppColors.cardLight)
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
    }

    // ---------------------------
    // EDITOR C/ DADO
    // ---------------------------

    func editorWithDice(label: String,
                        text: Binding<String>,
                        height: CGFloat,
                        action: @escaping () -> Void) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.textLight.opacity(0.8))

            ZStack(alignment: .topTrailing) {

                RoundedRectangle(cornerRadius: 18)
                    .fill(AppColors.cardLight)
                    .frame(height: height)
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)

                TextEditor(text: text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(AppColors.textLight)
                    .frame(height: height)

                Button(action: action) {
                    Image(systemName: "dice")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.accentLight)
                        .padding(14)
                }
            }
        }
    }
}

//
//  CÁMARA
//

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
