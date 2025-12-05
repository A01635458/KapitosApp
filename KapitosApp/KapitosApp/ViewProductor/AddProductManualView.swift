//
//  AddProductManualView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 05/12/25.
//

import SwiftUI

struct AddProductManualView: View {

    @EnvironmentObject var store: ProducerStore
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var tastingNotes = ""
    @State private var methods = ""
    @State private var categoryFields = ""

    var body: some View {

        NavigationStack {

            ScrollView {
                VStack(spacing: 26) {

                    // ---------------------------
                    // TÍTULO
                    // ---------------------------

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Título del producto")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textLight.opacity(0.8))

                        HStack {
                            TextField("", text: $title)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .foregroundColor(AppColors.textLight)
                        }
                        .background(AppColors.cardLight)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
                    }

                    // ---------------------------
                    // DESCRIPCIÓN
                    // ---------------------------

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Descripción de marketing")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textLight.opacity(0.8))

                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(AppColors.cardLight)
                                .frame(height: 150)
                                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)

                            TextEditor(text: $description)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .foregroundColor(AppColors.textLight)
                                .frame(height: 150)
                        }
                    }

                    // ---------------------------
                    // PRECIO
                    // ---------------------------

                    VStack(alignment: .leading, spacing: 6) {

                        Text("Precio sugerido")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textLight.opacity(0.8))

                        HStack {
                            TextField("", text: $price)
                                .keyboardType(.decimalPad)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .foregroundColor(AppColors.textLight)
                        }
                        .background(AppColors.cardLight)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
                    }

                    // ---------------------------
                    // NOTAS DE SABOR
                    // ---------------------------

                    VStack(alignment: .leading, spacing: 6) {

                        Text("Notas de sabor")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textLight.opacity(0.8))

                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(AppColors.cardLight)
                                .frame(height: 120)
                                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)

                            TextEditor(text: $tastingNotes)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .foregroundColor(AppColors.textLight)
                                .frame(height: 120)
                        }
                    }

                    // ---------------------------
                    // MÉTODOS DE PREPARACIÓN
                    // ---------------------------

                    VStack(alignment: .leading, spacing: 6) {

                        Text("Métodos de preparación")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textLight.opacity(0.8))

                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(AppColors.cardLight)
                                .frame(height: 120)
                                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)

                            TextEditor(text: $methods)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .foregroundColor(AppColors.textLight)
                                .frame(height: 120)
                        }
                    }

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
                                .background(Color.clear)
                                .foregroundColor(AppColors.textLight)
                                .frame(height: 110)
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
            .navigationTitle("Agregar Manualmente")
        }
    }

    func saveProduct() {
        if let p = Double(price) {
            store.products.append(
                ProducerProduct(name: title,
                                price: p,
                                weight: methods,
                                image: nil)
            )
            dismiss()
        }
    }
}
