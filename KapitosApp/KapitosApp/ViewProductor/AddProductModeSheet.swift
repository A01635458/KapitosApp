//
//  AddProductModeSheet.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 05/12/25.
//

import SwiftUI

struct AddProductModeSheet: View {

    @Binding var showAddOptions: Bool
    @EnvironmentObject var store: ProducerStore
    @State private var openManual = false
    @State private var openAI = false

    var body: some View {

        VStack(alignment: .leading, spacing: 22) {

            Text("Agregar Producto")
                .font(.title2.bold())
                .foregroundColor(AppColors.textLight)
                .padding(.top, 10)

            HStack(spacing: 18) {

                // MANUAL
                Button {
                    openManual = true
                } label: {
                    VStack(spacing: 12) {

                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 36))
                            .foregroundColor(AppColors.accentLight)

                        Text("Manual")
                            .font(.headline)
                            .foregroundColor(AppColors.textLight)
                    }
                    .frame(maxWidth: .infinity, minHeight: 130)
                    .background(AppColors.cardLight)
                    .cornerRadius(16)
                }

                // AI
                Button {
                    openAI = true
                } label: {
                    VStack(spacing: 12) {

                        Image(systemName: "sparkles")
                            .font(.system(size: 36))
                            .foregroundColor(AppColors.accentLight)

                        Text("Con AI")
                            .font(.headline)
                            .foregroundColor(AppColors.textLight)
                    }
                    .frame(maxWidth: .infinity, minHeight: 130)
                    .background(AppColors.cardLight)
                    .cornerRadius(16)
                }
            }

            Spacer()
        }
        .padding(24)
        .background(AppColors.backgroundLight)
        .sheet(isPresented: $openManual) {
            AddProductManualView()
                .environmentObject(store)
        }
        .sheet(isPresented: $openAI) {
            AddProductAIView()
                .environmentObject(store)
        }
    }
}
