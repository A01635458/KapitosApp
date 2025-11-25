//
//  ProducerBusinessView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI

struct ProducerBusinessView: View {

    @EnvironmentObject var store: ProducerStore

    var body: some View {

        ScrollView {
            VStack(spacing: 22) {

                Text("Mi Negocio")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                editableField("Nombre del negocio", text: $store.businessName)
                editableField("Teléfono", text: $store.phone)
                editableField("Ubicación", text: $store.address)
                editableField("Horario", text: $store.schedule)
                editableField("Descripción", text: $store.description)

                Spacer().frame(height: 80)
            }
            .padding(22)
        }
    }

    func editableField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.headline)
            TextField(label, text: text)
                .padding()
                .background(Color.gray.opacity(0.12))
                .cornerRadius(12)
        }
    }
}
