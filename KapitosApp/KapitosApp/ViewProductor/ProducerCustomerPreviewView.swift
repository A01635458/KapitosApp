//
//  ProducerCustomerPreviewView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI

struct ProducerCustomerPreviewView: View {

    @EnvironmentObject var store: ProducerStore

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 210)
                    .overlay(Text("Banner")).foregroundColor(.white)

                Text(store.businessName)
                    .font(.largeTitle.bold())

                Text(store.description)
                    .foregroundColor(.gray)

                Text("Productos")
                    .font(.title2.bold())
                    .padding(.top)

                ForEach(store.products) { product in
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 60, height: 60)

                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.headline)
                            Text("\(product.weight) · $\(product.price, specifier: "%.0f")")
                                .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 10)
                }

                Spacer().frame(height: 80)
            }
            .padding(22)
        }
    }
}
