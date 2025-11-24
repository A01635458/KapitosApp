//
//  AccountGeneratorView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct AccountGeneratorView: View {

    @EnvironmentObject var theme: AppThemeManager

    @State private var username = ""
    @State private var password = ""
    @State private var created = false

    var body: some View {
        VStack(spacing: 22) {

            Text("Crear cuenta manual")
                .font(.title.bold())
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

            TextField("Usuario", text: $username)
                .padding()
                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .cornerRadius(10)

            SecureField("Contraseña", text: $password)
                .padding()
                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .cornerRadius(10)

            Button {
                created = true
            } label: {
                Text("Crear cuenta")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    .cornerRadius(16)
            }

            if created {
                Text("Cuenta creada correctamente")
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
