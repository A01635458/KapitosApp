//
//  ProducerShopView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI

struct ProducerShopView: View {

    @EnvironmentObject var store: ProducerStore
    @State private var showAdd = false

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                HStack {
                    Text("Mis Productos")
                        .font(.largeTitle.bold())

                    Spacer()

                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                }

                if store.products.isEmpty {
                    Text("Aún no tienes productos")
                        .padding(.top, 50)
                } else {
                    ForEach(store.products) { product in
                        productCard(product)
                    }
                }

                Spacer().frame(height: 80)
            }
            .padding(22)
        }
        .sheet(isPresented: $showAdd) {
            AddProductView()
                .environmentObject(store)
        }
    }

    func productCard(_ product: ProducerProduct) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)

            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                Text("\(product.weight) · $\(product.price, specifier: "%.0f")")
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.12))
        .cornerRadius(14)
    }
}

struct AddProductView: View {

    @EnvironmentObject var store: ProducerStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var price = ""
    @State private var weight = ""

    var body: some View {

        NavigationStack {
            Form {
                TextField("Nombre", text: $name)
                TextField("Precio", text: $price)
                    .keyboardType(.numberPad)
                TextField("Peso", text: $weight)
            }
            .navigationTitle("Nuevo Producto")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        if let p = Double(price) {
                            store.products.append(
                                ProducerProduct(name: name, price: p, weight: weight, image: nil)
                            )
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
