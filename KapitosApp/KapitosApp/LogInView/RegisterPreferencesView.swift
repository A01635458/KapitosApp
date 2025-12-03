import SwiftUI

struct RegisterPreferencesView: View {
    @EnvironmentObject var theme: AppThemeManager
    @EnvironmentObject var flowModel: RegistrationFlowModel
    @EnvironmentObject var registrationService: UserRegistrationService

    @State private var step = 0
    @State private var navigateToLogin = false

    @State private var goToSuccess = false   // <-- NUEVO

    @State private var selectedProcesses: Set<String> = []
    @State private var selectedRoasts: Set<String> = []
    @State private var selectedDrinks: Set<String> = []
    @State private var selectedTimes: Set<String> = []
    @State private var selectedAcidity: Set<String> = []
    @State private var selectedNotes: Set<String> = []
    @State private var selectedWeekly: Set<String> = []

    private let processes = [("Lavado","drop.fill"),("Honey","hexagon.fill"),("Natural","leaf.fill"),("Anaeróbico","wind"),("Carbonic","aqi.medium"),("Experimental","sparkles")]
    private let roasts = [("Claro","sun.max.fill"),("Medio","sunrise.fill"),("Oscuro","moon.fill")]
    private let drinks = [("Espresso","cup.and.saucer.fill"),("Americano","drop.circle"),("Latte","cup.and.saucer"),("Cold Brew","snowflake"),("Cappuccino","cloud.fill"),("Cortado","circle.grid.cross.fill")]
    private let times = [("Mañana","sun.max.fill"),("Tarde","sunset.fill"),("Noche","moon.fill")]
    private let acidity = [("Alta","bolt.fill"),("Media","bolt.horizontal"),("Baja","bolt.slash.fill")]
    private let notes = [("Cítrico","leaf.fill"),("Dulce","cube.fill"),("Chocolate","square.fill"),("Floral","leaf.fill")]
    private let weekly = [("1–3 tazas","1.circle.fill"),("4–7 tazas","5.circle.fill"),("8+ tazas","8.circle.fill")]

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {

                HStack {
                    Spacer()
                    Button { Task { await finish(skipAll: true) } } label: { chip("Saltar todo") }
                }
                .padding(.top, 12)

                Image(systemName: currentIcon)
                    .font(.system(size: 70))
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.textLight)

                Text(currentTitle)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                    .padding(.horizontal, 12)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(currentOptions, id: \.0) { option in
                        optionCard(option.0, icon: option.1)
                    }
                }

                Spacer()

                Button {
                    Task {
                        if step == allSteps.count - 1 {
                            await finish(skipAll: false)
                        } else {
                            withAnimation { step += 1 }
                        }
                    }
                } label: {
                    Text(step == allSteps.count - 1 ? "Terminar" : "Siguiente")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        .cornerRadius(16)
                }

                Button {
                    Task {
                        if step == allSteps.count - 1 {
                            await finish(skipAll: true)
                        } else {
                            withAnimation { step += 1 }
                        }
                    }
                } label: {
                    chip("Saltar pregunta")
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
            .background((theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight).ignoresSafeArea())

            // --- DESTINATIONS ---
            .navigationDestination(isPresented: $goToSuccess) {
                SuccessView()                      // <-- AQUI TE MANDA
                    .environmentObject(theme)
            }

            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView().environmentObject(theme)
            }
        }
    }

    // MARK: Helpers
    private var allSteps: [(String,String,[(String,String)])] {
        [
            ("¿Qué proceso te gusta?","drop.fill",processes),
            ("¿Tu tueste favorito?","flame.fill",roasts),
            ("¿Qué bebida tomas más?","cup.and.saucer.fill",drinks),
            ("¿A qué hora tomas café?","clock.fill",times),
            ("¿Qué acidez prefieres?","bolt.heart.fill",acidity),
            ("¿Qué notas prefieres?","leaf.fill",notes),
            ("¿Cuánto café consumes por semana?","chart.bar.fill",weekly)
        ]
    }

    private var currentTitle: String { allSteps[step].0 }
    private var currentIcon: String { allSteps[step].1 }
    private var currentOptions: [(String,String)] { allSteps[step].2 }

    private var currentSelectionBinding: Binding<Set<String>> {
        switch step {
        case 0: return $selectedProcesses
        case 1: return $selectedRoasts
        case 2: return $selectedDrinks
        case 3: return $selectedTimes
        case 4: return $selectedAcidity
        case 5: return $selectedNotes
        case 6: return $selectedWeekly
        default: return $selectedProcesses
        }
    }

    private func optionCard(_ text: String, icon: String) -> some View {
        let binding = currentSelectionBinding
        let selected = binding.wrappedValue.contains(text)
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                if selected { binding.wrappedValue.remove(text) }
                else { binding.wrappedValue.insert(text) }
                syncToFlow()
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(selected ? .white : (theme.isDarkMode ? .white.opacity(0.85) : AppColors.textLight))
                Text(text)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(selected ? .white : (theme.isDarkMode ? .white.opacity(0.9) : AppColors.textLight))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selected ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight) :
                                      (theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight))
            )
            .shadow(color: selected ? AppColors.accentDark.opacity(0.35) : .clear,
                    radius: selected ? 10 : 0, y: selected ? 4 : 0)
        }
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundColor(theme.isDarkMode ? AppColors.accentDark.opacity(0.85) : AppColors.textLight.opacity(0.75))
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(theme.isDarkMode ? AppColors.cardDark.opacity(0.4) : AppColors.cardLight.opacity(0.7)))
    }

    private func syncToFlow() {
        flowModel.preferences.processes = selectedProcesses
        flowModel.preferences.roasts = selectedRoasts
        flowModel.preferences.drinks = selectedDrinks
        flowModel.preferences.times = selectedTimes
        flowModel.preferences.acidity = selectedAcidity
        flowModel.preferences.notes = selectedNotes
        flowModel.preferences.weekly = selectedWeekly
    }

    private func finish(skipAll: Bool) async {
        if skipAll { syncToFlow() }

        if !registrationService.isSubmitting {
            await registrationService.completeRegistration(flow: flowModel)
        }

        withAnimation {
            goToSuccess = true          // <-- AHORA VA A SUCCESSVIEW
        }
    }
}

#Preview {
    RegisterPreferencesView()
        .environmentObject(AppThemeManager())
        .environmentObject(RegistrationFlowModel())
        .environmentObject(UserRegistrationService.shared)
}
