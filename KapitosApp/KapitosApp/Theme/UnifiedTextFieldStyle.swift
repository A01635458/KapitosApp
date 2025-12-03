//
//  UnifiedTextFieldStyle.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//

import SwiftUI

struct UnifiedTextFieldStyle: ViewModifier {

    @EnvironmentObject var theme: AppThemeManager
    let icon: String
    let text: String
    @Binding var value: String
    let isSecure: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {

            // ---- Caja ----
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .shadow(
                    color: .black.opacity(theme.isDarkMode ? 0.35 : 0.10),
                    radius: 6,
                    y: 3
                )

            HStack(spacing: 12) {

                // ---- Ícono ----
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .foregroundColor(
                            theme.isDarkMode
                            ? AppColors.accentDark
                            : AppColors.textLight.opacity(0.6)
                        )
                        .font(.system(size: 18))
                }

                // ---- Placeholder visible cuando value está vacío ----
                if value.isEmpty {
                    Text(text)
                        .foregroundColor(
                            theme.isDarkMode
                            ? AppColors.accentLight.opacity(0.65)  // ⭐ BEIGE CLARO PERFECTO EN DARK MODE
                            : AppColors.textLight.opacity(0.50)   // ⭐ Café clarito en Light Mode
                        )
                }

                // ---- Contenido editable ----
                if isSecure {
                    SecureField("", text: $value)
                        .foregroundColor(
                            theme.isDarkMode ? .white : AppColors.textLight
                        )
                } else {
                    TextField("", text: $value)
                        .foregroundColor(
                            theme.isDarkMode ? .white : AppColors.textLight
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .frame(height: 55)
    }
}

extension View {
    func unifiedTextField(icon: String, text: String, value: Binding<String>, isSecure: Bool = false) -> some View {
        self.modifier(
            UnifiedTextFieldStyle(
                icon: icon,
                text: text,
                value: value,
                isSecure: isSecure
            )
            
        )
    }
    
}
