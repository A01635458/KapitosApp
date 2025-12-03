//
//  RegisterView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//


import SwiftUI

struct RegisterView: View {

    @EnvironmentObject var theme: AppThemeManager

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var goToPreferences = false

    var body: some View {
        NavigationStack {
            ZStack {

                (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {

                        Text("Crea tu cuenta")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.textLight)
                            .padding(.top, 20)

                        // -------- NOMBRE --------
                        Color.clear
                            .unifiedTextField(
                                icon: "person.fill",        // ← SE MANTIENE
                                text: "Nombre completo",
                                value: $name
                            )
                            .environmentObject(theme)

                        // -------- EMAIL --------
                        Color.clear
                            .unifiedTextField(
                                icon: "envelope.fill",      // ← SE MANTIENE
                                text: "Correo electrónico",
                                value: $email
                            )
                            .environmentObject(theme)

                        // -------- PASSWORDS --------
                        VStack(spacing: 16) {

                            // CONTRASEÑA
                            Color.clear
                                .unifiedTextField(
                                    icon: "lock.fill",       // ← SE MANTIENE
                                    text: "Contraseña",
                                    value: $password,
                                    isSecure: true
                                )
                                .environmentObject(theme)

                            // REPETIR CONTRASEÑA
                            Color.clear
                                .unifiedTextField(
                                    icon: "lock.fill",       // ← SE MANTIENE
                                    text: "Repetir contraseña",
                                    value: $confirmPassword,
                                    isSecure: true
                                )
                                .environmentObject(theme)
                        }

                        // -------- CHECKLIST --------
                        checklistView

                        // -------- CONTINUAR --------
                        Button {
                            flowModel.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            flowModel.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
                            flowModel.password = password
                            goToPreferences = true
                        } label: {
                            Text("Continuar")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.headline)
                                .foregroundColor(.white)
                                .background(isValid ? AppColors.accentDark : Color.gray)
                                .cornerRadius(14)
                        }
                        .disabled(!isValid)
                        .padding(.top, 12)

                        Spacer()
                    }
                    .padding(.horizontal, 26)
                }
            }
            .navigationDestination(isPresented: $goToPreferences) {
                RegisterPreferencesView()
                    .environmentObject(flowModel)
                    .environmentObject(registrationService)
            }
        }
    }

    // MARK: VALIDATION LOGIC
    var ruleLength: Bool { password.count >= 8 }
    var ruleUpper: Bool { password.rangeOfCharacter(from: .uppercaseLetters) != nil }
    var ruleNumber: Bool { password.rangeOfCharacter(from: .decimalDigits) != nil }
    var ruleSymbol: Bool { password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>/?")) != nil }
    var ruleMatch: Bool { !password.isEmpty && password == confirmPassword }

    var isValid: Bool {
        ruleLength && ruleUpper && ruleNumber && ruleSymbol && ruleMatch && !name.isEmpty && !email.isEmpty
    }

    // MARK: CHECKLIST
    var checklistView: some View {
        VStack(alignment: .leading, spacing: 8) {
            checklistItem("Mínimo 8 caracteres", ok: ruleLength)
            checklistItem("1 mayúscula", ok: ruleUpper)
            checklistItem("1 número", ok: ruleNumber)
            checklistItem("1 símbolo (!@#$…)", ok: ruleSymbol)
            checklistItem("Las contraseñas coinciden", ok: ruleMatch)
        }
        .padding(.horizontal, 4)
    }

    func checklistItem(_ text: String, ok: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(ok ? .green : .red)
                .font(.system(size: 16))
            Text(text)
                .foregroundColor(
                    theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.9)
                )
                .font(.footnote)
        }
    }
}

// MARK: - Flow / Service Instances
private let flowModel = RegistrationFlowModel()
private let registrationService = UserRegistrationService.shared

#Preview {
    RegisterView().environmentObject(AppThemeManager())
}
