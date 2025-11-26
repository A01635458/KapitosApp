import SwiftUI

//admin@kapitos.com
//Teamleche123@

//productor1@kapitos.com
//Productor123!

struct LoginView: View {

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false

    @State private var showRegister = false
    @State private var showProducerSurvey = false
    @State private var goToApp = false
    @State private var goToAdmin = false
    @State private var goToProducer = false

    @StateObject private var auth = AuthenticationService.shared

    @EnvironmentObject var theme: AppThemeManager

    var body: some View {
        NavigationStack {
            ZStack {

                (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                    .ignoresSafeArea()

                VStack(spacing: 28) {

                    Spacer()

                    Text("La Ruta del Cafe")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.textLight)
                        .shadow(color: theme.isDarkMode ? AppColors.accentDark.opacity(0.5) : .clear,
                                radius: 8)

                    VStack(spacing: 20) {

                        inputField(
                            icon: "envelope.fill",
                            placeholder: "Correo electrónico",
                            text: $email
                        )

                        // PASSWORD FIELD CON OJITO
                        passwordField()

                        Button {
                            Task { await handleLogin() }
                        } label: {
                            Text("Iniciar Sesión")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                .cornerRadius(14)
                                .shadow(color: theme.isDarkMode ? AppColors.accentDark.opacity(0.6) : .clear,
                                        radius: 10, y: 4)
                        }
                        .disabled(email.isEmpty || password.isEmpty || auth.isLoading)

                        if let msg = auth.message {
                            HStack(spacing: 10) {
                                Image(systemName: msg.contains("exitoso") ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(.white)
                                Text(msg)
                                    .foregroundColor(.white)
                                    .font(.footnote.bold())
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(msg.contains("exitoso") ? Color.green : Color.red)
                            .cornerRadius(12)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        if auth.isLoading {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(
                                        tint: theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight
                                    )
                                )
                        }

                        Button {
                            showRegister = true
                        } label: {
                            Text("¿No tienes cuenta? Regístrate")
                                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight)
                                .font(.callout)
                        }

                    }
                    .padding(28)
                    .background(
                        (theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                            .opacity(0.85)
                    )
                    .cornerRadius(22)
                    .shadow(color: theme.isDarkMode ?
                            Color.black.opacity(0.65) :
                            Color.black.opacity(0.1),
                            radius: 20, y: 10)

                    Spacer()

                    VStack(spacing: 6) {
                        Text("¿Eres productor?")
                            .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight)

                        Button {
                            showProducerSurvey = true
                        } label: {
                            Text("Regístrate aquí")
                                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                .underline()
                        }
                    }
                    .padding(.bottom, 30)

                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .navigationDestination(isPresented: $showProducerSurvey) {
                ProducerSurveyView()
            }
            .navigationDestination(isPresented: $goToApp) {
                ContentView().environmentObject(theme)
            }
            .navigationDestination(isPresented: $goToAdmin) {
                KapeContentView().environmentObject(theme)
            }
            .navigationDestination(isPresented: $goToProducer) {
                ProducerContentView()
                    .environmentObject(theme)
            }
        }
    }

    // MARK: - CUSTOM FIELDS
    @ViewBuilder
    func inputField(icon: String,
                    placeholder: String,
                    text: Binding<String>,
                    isSecure: Bool = false) -> some View {

        HStack(spacing: 14) {

            Image(systemName: icon)
                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.textLight.opacity(0.6))
                .font(.system(size: 18))

            if isSecure {
                SecureField(placeholder, text: text)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            } else {
                TextField(placeholder, text: text)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(
            (theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .opacity(theme.isDarkMode ? 0.5 : 1)
        )
        .cornerRadius(14)
        .shadow(color: theme.isDarkMode ? AppColors.accentDark.opacity(0.3) : Color.black.opacity(0.05),
                radius: 8, y: 4)
    }

    // MARK: - PASSWORD FIELD COMPLETO CON OJITO
    @ViewBuilder
    func passwordField() -> some View {
        HStack(spacing: 14) {

            Image(systemName: "lock.fill")
                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.textLight.opacity(0.6))
                .font(.system(size: 18))

            if showPassword {
                TextField("Contraseña", text: $password)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                    .autocapitalization(.none)
            } else {
                SecureField("Contraseña", text: $password)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    showPassword.toggle()
                }
            } label: {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 18))
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))
            }
        }
        .padding()
        .background(
            (theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .opacity(theme.isDarkMode ? 0.5 : 1)
        )
        .cornerRadius(14)
        .shadow(color: theme.isDarkMode ? AppColors.accentDark.opacity(0.3) : Color.black.opacity(0.05),
                radius: 8, y: 4)
    }
}

// MARK: - LOGIN LOGIC
extension LoginView {
    private func handleLogin() async {

        if email.lowercased() == "productor1@kapitos.com"
            && password == "Productor123!" {

            withAnimation { goToProducer = true }
            return
        }

        let success = await auth.signIn(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )

        if success {
            if auth.userRole == "admin" {
                withAnimation { goToAdmin = true }
            } else {
                withAnimation { goToApp = true }
            }
        }
    }
}

#Preview {
    LoginView().environmentObject(AppThemeManager())
}
