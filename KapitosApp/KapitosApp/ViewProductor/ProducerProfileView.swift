//
//  ProducerProfileView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//

import SwiftUI

struct ProducerProfileView: View {

    @EnvironmentObject var store: ProducerStore

    var body: some View {

        VStack(spacing: 22) {

            Spacer().frame(height: 40)

            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 120)

            Text(store.businessName)
                .font(.title.bold())

            Text(store.address)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
    }
}
