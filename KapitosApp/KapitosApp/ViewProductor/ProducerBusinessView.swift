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
    @State private var showBannerPicker = false

    var body: some View {

        ScrollView {
            VStack(spacing: 28) {

                Text("Mi Negocio")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(AppColors.textLight)

                // -----------------------------------------------------
                // 🟫 BANNER DEL NEGOCIO
                // -----------------------------------------------------
                VStack(alignment: .leading, spacing: 12) {

                    Text("Banner del negocio")
                        .font(.headline)
                        .foregroundColor(AppColors.textLight)

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColors.cardLight)
                            .frame(height: 180)
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)

                        if let img = store.bannerImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.accentLight)

                                Text("Aún no tienes un banner")
                                    .foregroundColor(AppColors.textLight.opacity(0.6))
                            }
                        }
                    }

                    Button {
                        showBannerPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Subir banner")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.accentLight)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                    }
                }

                // -----------------------------------------------------
                // CAMPOS DEL NEGOCIO
                // -----------------------------------------------------

                editableField("Nombre del negocio", text: $store.businessName)
                editableField("Teléfono", text: $store.phone)
                editableField("Ubicación", text: $store.address)
                // schedule eliminado
                editableField("Descripción", text: $store.description)

                Spacer().frame(height: 80)
            }
            .padding(22)
        }
        .background(AppColors.backgroundLight)
        .photosPicker(isPresented: $showBannerPicker, selection: .constant(nil), matching: .images, preferredItemEncoding: .automatic)
        .onChange(of: showBannerPicker) { _ in
            // NOTE: handling inside .onChange for PhotosPicker below
        }
        .photosPicker(isPresented: $showBannerPicker, selection: Binding.constant(nil), matching: .images)
        .onChange(of: showBannerPicker) { _ in /* no-op */ }
        .onAppear { }
        .background(AppColors.backgroundLight)
        // Real picker binding:
        .photosPicker(isPresented: $showBannerPicker, selection: $tempBannerSelection, matching: .images)
        .onChange(of: tempBannerSelection) { _ in loadBannerImage() }
    }

    // Temporary selection container
    @State private var tempBannerSelection: PhotosPickerItem?

    // Load image chosen from picker
    func loadBannerImage() {
        Task {
            if let item = tempBannerSelection,
               let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                store.bannerImage = image
            }
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
