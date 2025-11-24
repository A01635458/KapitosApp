//
//  SuccessView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct SuccessView: View {

    @EnvironmentObject var theme: AppThemeManager

    var body: some View {
        ZStack {
            (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                .ignoresSafeArea()

            VStack(spacing: 30) {

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 90))
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    .shadow(radius: 10)

                Text("¡Bienvenido a Kapitos!")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                    .multilineTextAlignment(.center)

                Text("Tu perfil está listo. Vamos a comenzar.")
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                NavigationLink {
                    LoginView()
                        .environmentObject(theme)
                        .navigationBarBackButtonHidden(true)  // <-- no back in login
                } label: {
                    Text("Ir al inicio de sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)    // <-- no back in this screen
    }
}

#Preview {
    SuccessView().environmentObject(AppThemeManager())
}
