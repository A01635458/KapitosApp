//
//  ProducerBusinessView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//


import SwiftUI
import PhotosUI

struct ProducerBusinessView: View {

    @EnvironmentObject var store: ProducerStore
    @State private var showImageSourceSelector = false
    @State private var tempLogoSelection: PhotosPickerItem?
    @State private var isUploadingLogo = false

    var body: some View {

        ScrollView {
            VStack(spacing: 28) {

                Text("Mi Negocio")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(AppColors.textLight)

                // -----------------------------------------------------
                // 🟫 LOGO DEL NEGOCIO
                // -----------------------------------------------------
                VStack(alignment: .leading, spacing: 12) {

                    Text("Logo del negocio")
                        .font(.headline)
                        .foregroundColor(AppColors.textLight)

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColors.cardLight)
                            .frame(width: 180, height: 180)
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)

                        if let img = store.logoImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "photo.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.accentLight)

                                Text("Sin logo")
                                    .foregroundColor(AppColors.textLight.opacity(0.6))
                            }
                        }
                        
                        if isUploadingLogo {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Button {
                        showImageSourceSelector = true
                    } label: {
                        HStack {
                            Image(systemName: isUploadingLogo ? "hourglass" : "square.and.arrow.up")
                            Text(isUploadingLogo ? "Subiendo..." : (store.logoImage == nil ? "Subir logo" : "Actualizar logo"))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isUploadingLogo ? AppColors.accentLight.opacity(0.6) : AppColors.accentLight)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                    }
                    .disabled(isUploadingLogo)
                }

                // -----------------------------------------------------
                // CAMPOS DEL NEGOCIO
                // -----------------------------------------------------

                editableField("Nombre del negocio", text: $store.businessName)
                editableField("Teléfono", text: $store.phone)
                
                Text("Ubicación")
                    .font(.headline)
                    .foregroundColor(AppColors.textLight)
                Text(store.address.isEmpty ? "Sin ubicación registrada" : store.address)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cardLight.opacity(0.5))
                    .cornerRadius(14)
                    .foregroundColor(AppColors.textLight.opacity(0.7))
                
                // Guardar cambios
                Button {
                    Task {
                        await store.saveBusinessInfo()
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Guardar cambios")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.accentLight)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                }

                Spacer().frame(height: 80)
            }
            .padding(22)
        }
        .background(AppColors.backgroundLight)
        .background {
            ImageSourceSelector(image: Binding(
                get: { nil },
                set: { newImage in
                    if let img = newImage {
                        Task {
                            isUploadingLogo = true
                            let success = await store.uploadLogo(img)
                            isUploadingLogo = false
                            
                            if !success {
                                print("❌ Failed to upload logo")
                            }
                        }
                    }
                }
            ), showActionSheet: $showImageSourceSelector)
        }
    }

    // Reusable field UI
    func editableField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundColor(AppColors.textLight)

            TextField(label, text: text)
                .padding()
                .background(AppColors.cardLight)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                .foregroundColor(AppColors.textLight)
        }
    }
}
