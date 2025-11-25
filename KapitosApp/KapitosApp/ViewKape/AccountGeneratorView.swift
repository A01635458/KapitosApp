//
//  AccountGeneratorView.swift
//  KapitosApp
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct AccountGeneratorView: View {
    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var adminService = AdminDataService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole = "user"
    @State private var showSuccess = false
    @State private var showError = false
    @State private var isProcessing = false
    
    private let roles = [("user", "Cliente"), ("producer", "Productor"), ("admin", "Admin")]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Crear cuenta manual")
                    .font(.title.bold())
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                
                VStack(spacing: 16) {
                    TextField("Nombre completo", text: $fullName)
                        .padding()
                        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                        .cornerRadius(10)
                    
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding()
                        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                        .cornerRadius(10)
                    
                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                        .cornerRadius(10)
                    
                    SecureField("Confirmar contraseña", text: $confirmPassword)
                        .padding()
                        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                        .cornerRadius(10)
                    
                    if !password.isEmpty && password != confirmPassword {
                        Text("Las contraseñas no coinciden")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Role picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rol")
                            .font(.headline)
                            .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                        
                        HStack(spacing: 12) {
                            ForEach(roles, id: \.0) { role in
                                Button {
                                    selectedRole = role.0
                                } label: {
                                    Text(role.1)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(selectedRole == role.0 ? .white : (theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(selectedRole == role.0 ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight) : (theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight))
                                        )
                                }
                            }
                        }
                    }
                }
                
                Button {
                    Task { await handleCreateAccount() }
                } label: {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "person.badge.plus")
                            Text("Crear cuenta")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight) : Color.gray)
                    .cornerRadius(16)
                }
                .disabled(!isFormValid || isProcessing)
                
                if showSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Cuenta creada correctamente")
                    }
                    .foregroundColor(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                
                if showError, let error = adminService.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(error)
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
        }
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .navigationTitle("Crear Cuenta")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var isFormValid: Bool {
        !fullName.isEmpty
        && !email.isEmpty
        && email.contains("@")
        && password.count >= 6
        && password == confirmPassword
    }
    
    private func handleCreateAccount() async {
        isProcessing = true
        showSuccess = false
        showError = false
        
        let success = await adminService.createAccount(
            email: email,
            password: password,
            fullName: fullName,
            role: selectedRole
        )
        
        isProcessing = false
        
        if success {
            showSuccess = true
            // Clear form
            fullName = ""
            email = ""
            password = ""
            confirmPassword = ""
            selectedRole = "user"
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            dismiss()
        } else {
            showError = true
        }
    }
}
