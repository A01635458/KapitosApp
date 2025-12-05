//
//  EditProductView.swift
//  KapitosApp
//
//  Vista para editar productos existentes
//

import SwiftUI
import PhotosUI

struct EditProductView: View {
    
    @EnvironmentObject var store: ProducerStore
    @EnvironmentObject var theme: AppThemeManager
    @Environment(\.dismiss) var dismiss
    
    let product: ProducerProduct
    
    // Estados editables
    @State private var editedName: String
    @State private var editedDescription: String
    @State private var editedPrice: String
    @State private var editedWeight: String
    @State private var editedTastingNotes: String
    @State private var editedMethods: String
    @State private var editedCategoryFields: String
    
    // Imagen
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var showImageSourceDialog = false
    @State private var isSaving = false
    
    init(product: ProducerProduct) {
        self.product = product
        _editedName = State(initialValue: product.name)
        _editedDescription = State(initialValue: product.description ?? "")
        _editedPrice = State(initialValue: String(format: "%.0f", product.price))
        _editedWeight = State(initialValue: product.weight)
        _editedTastingNotes = State(initialValue: product.tastingNotes?.joined(separator: ", ") ?? "")
        _editedMethods = State(initialValue: product.brewingMethods?.joined(separator: ", ") ?? "")
        
        var fieldsText = ""
        if let fields = product.categoryFields {
            for (key, value) in fields.sorted(by: { $0.key < $1.key }) {
                fieldsText += "\(key): \(value)\n"
            }
        }
        _editedCategoryFields = State(initialValue: fieldsText)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 26) {
                    
                    Text("Editar Producto")
                        .font(.largeTitle.bold())
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                        .padding(.top, 6)
                    
                    // IMAGEN
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
                                } else if let imageUrl = product.imageUrl,
                                          let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 220)
                                                .clipped()
                                                .cornerRadius(16)
                                        case .failure(_), .empty:
                                            placeholderContent()
                                        @unknown default:
                                            placeholderContent()
                                        }
                                    }
                                } else if let imgData = product.image,
                                          let uiImg = UIImage(data: imgData) {
                                    Image(uiImage: uiImg)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 220)
                                        .clipped()
                                        .cornerRadius(16)
                                } else {
                                    placeholderContent()
                                }
                            }
                        }
                        
                        Text("Toca para cambiar la imagen")
                            .font(.caption)
                            .foregroundColor(theme.isDarkMode ? .white.opacity(0.6) : AppColors.textLight.opacity(0.6))
                    }
                    
                    // CAMPOS EDITABLES
                    VStack(spacing: 20) {
                        
                        // NOMBRE
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Nombre del producto")
                                .font(.subheadline)
                                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                            
                            TextField("", text: $editedName)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .cornerRadius(18)
                        }
                        
                        // DESCRIPCIÓN
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Descripción")
                                .font(.subheadline)
                                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                            
                            TextEditor(text: $editedDescription)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .cornerRadius(18)
                                .frame(height: 120)
                        }
                        
                        // PRECIO Y PESO
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Precio (MXN)")
                                    .font(.subheadline)
                                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                                
                                TextField("", text: $editedPrice)
                                    .keyboardType(.decimalPad)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                    .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                    .cornerRadius(18)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Peso")
                                    .font(.subheadline)
                                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                                
                                TextField("", text: $editedWeight)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                    .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                    .cornerRadius(18)
                            }
                        }
                        
                        // NOTAS DE SABOR
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Notas de sabor")
                                .font(.subheadline)
                                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                            
                            TextEditor(text: $editedTastingNotes)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .cornerRadius(18)
                                .frame(height: 100)
                        }
                        
                        // MÉTODOS DE PREPARACIÓN
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Métodos de preparación")
                                .font(.subheadline)
                                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                            
                            TextEditor(text: $editedMethods)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .cornerRadius(18)
                                .frame(height: 100)
                        }
                        
                        // INFORMACIÓN ADICIONAL
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Información adicional")
                                .font(.subheadline)
                                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                            
                            TextEditor(text: $editedCategoryFields)
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
                                await saveChanges()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Guardar Cambios")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                            )
                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
                        }
                        .disabled(editedName.isEmpty || editedPrice.isEmpty || isSaving)
                        .padding(.top, 10)
                    }
                }
                .padding(22)
            }
            .background(AppColors.backgroundLight)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                }
            }
            .confirmationDialog("Cambiar imagen", isPresented: $showImageSourceDialog) {
                Button("📸 Tomar foto") {
                    showCamera = true
                }
                Button("🖼️ Elegir de galería") {
                    showImagePicker = true
                }
                Button("Cancelar", role: .cancel) {}
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
        }
    }
    
    func placeholderContent() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
            Text("Sin imagen")
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight)
                .font(.subheadline)
        }
    }
    
    func saveChanges() async {
        guard let priceValue = Double(editedPrice) else { return }
        
        isSaving = true
        
        var updatedProduct = product
        updatedProduct.name = editedName
        updatedProduct.price = priceValue
        updatedProduct.weight = editedWeight
        updatedProduct.description = editedDescription.isEmpty ? nil : editedDescription
        updatedProduct.tastingNotes = editedTastingNotes.isEmpty ? nil : editedTastingNotes.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        updatedProduct.brewingMethods = editedMethods.isEmpty ? nil : editedMethods.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Si hay una nueva imagen, actualizarla
        if let newImage = selectedImage {
            updatedProduct.image = newImage.jpegData(compressionQuality: 0.8)
        }
        
        let success = await store.updateProduct(updatedProduct)
        
        isSaving = false
        
        if success {
            dismiss()
        }
    }
}
