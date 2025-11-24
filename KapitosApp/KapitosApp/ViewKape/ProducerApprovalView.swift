//
//  ProducerApprovalView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct ProducerApprovalView: View {

    @EnvironmentObject var theme: AppThemeManager
    var producerName: String

    @State private var username = ""
    @State private var password = ""
    @State private var done = false

    var body: some View {
        VStack(spacing: 22) {

            Text("Aprobar a \(producerName)")
                .font(.title.bold())
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

            TextField("Nuevo usuario", text: $username)
                .padding()
                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .cornerRadius(10)

            SecureField("Contraseña", text: $password)
                .padding()
                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .cornerRadius(10)

            Button {
                done = true
            } label: {
                Text("Guardar credenciales")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    .cornerRadius(16)
            }

            if done {
                Text("¡Productor aprobado!")
                    .foregroundColor(.green)
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(false)
    }
}
