//
//  RequestDetailView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct RequestDetailView: View {

    @EnvironmentObject var theme: AppThemeManager
    let producerName: String           // <-- IMPORTANTE

    @State private var goToApproval = false

    var body: some View {
        VStack(spacing: 20) {

            Text(producerName)
                .font(.largeTitle.bold())
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                .multilineTextAlignment(.center)
                .padding(.top, 20)

            Text("Revisa los datos completos y decide si aceptar o rechazar.")
                .font(.callout)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            Spacer()

            Button {
                goToApproval = true
            } label: {
                Text("Aprobar productor")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 26)

            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $goToApproval) {
            ProducerApprovalView(producerName: producerName)
                .environmentObject(theme)
        }
    }
}

#Preview {
    RequestDetailView(producerName: "Finca San José")
        .environmentObject(AppThemeManager())
}
