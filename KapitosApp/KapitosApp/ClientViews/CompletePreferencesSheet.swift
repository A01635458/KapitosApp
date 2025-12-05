import SwiftUI
import Supabase

struct CompletePreferencesSheet: View {
    @EnvironmentObject var theme: AppThemeManager
    @Environment(\.dismiss) var dismiss
    
    let currentUserId: UUID
    @State private var step = 0
    @State private var isSubmitting = false
    @State private var submitSuccess = false
    
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
                if submitSuccess {
                    successView
                } else {
                    preferencesForm
                }
            }
            .padding(.horizontal, 24)
            .background((theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Completa tu Perfil")
                        .font(.headline)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                }
            }
        }
    }
    
    private var preferencesForm: some View {
        VStack(spacing: 22) {
            Image(systemName: currentIcon)
                .font(.system(size: 60))
                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.textLight)
            
            Text(currentTitle)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                .padding(.horizontal, 12)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(currentOptions, id: \.0) { option in
                        optionCard(option.0, icon: option.1)
                    }
                }
            }
            
            Spacer()
            
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<allSteps.count, id: \.self) { index in
                    Circle()
                        .fill(index == step ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight) : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 8)
            
            Button {
                Task {
                    if step == allSteps.count - 1 {
                        await savePreferences()
                    } else {
                        withAnimation { step += 1 }
                    }
                }
            } label: {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(step == allSteps.count - 1 ? "Guardar Preferencias" : "Siguiente")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                .cornerRadius(16)
            }
            .disabled(isSubmitting)
            
            Button {
                if step == allSteps.count - 1 {
                    dismiss()
                } else {
                    withAnimation { step += 1 }
                }
            } label: {
                Text("Saltar")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark.opacity(0.85) : AppColors.textLight.opacity(0.75))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
            }
            .padding(.bottom, 20)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("¡Preferencias Guardadas!")
                .font(.title.bold())
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            
            Text("Ahora recibirás mejores recomendaciones personalizadas")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Continuar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    .cornerRadius(16)
            }
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Helpers
    
    private var allSteps: [(String, String, [(String, String)])] {
        [
            ("¿Qué proceso te gusta?", "drop.fill", processes),
            ("¿Tu tueste favorito?", "flame.fill", roasts),
            ("¿Qué bebida tomas más?", "cup.and.saucer.fill", drinks),
            ("¿A qué hora tomas café?", "clock.fill", times),
            ("¿Qué acidez prefieres?", "bolt.heart.fill", acidity),
            ("¿Qué notas prefieres?", "leaf.fill", notes),
            ("¿Cuánto café consumes por semana?", "chart.bar.fill", weekly)
        ]
    }
    
    private var currentTitle: String { allSteps[step].0 }
    private var currentIcon: String { allSteps[step].1 }
    private var currentOptions: [(String, String)] { allSteps[step].2 }
    
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
                if selected {
                    binding.wrappedValue.remove(text)
                } else {
                    binding.wrappedValue.insert(text)
                }
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(selected ? .white : (theme.isDarkMode ? .white.opacity(0.85) : AppColors.textLight))
                Text(text)
                    .font(.caption.weight(.medium))
                    .foregroundColor(selected ? .white : (theme.isDarkMode ? .white.opacity(0.9) : AppColors.textLight))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight) :
                          (theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight))
            )
            .shadow(color: selected ? AppColors.accentDark.opacity(0.3) : .clear,
                    radius: selected ? 8 : 0, y: selected ? 4 : 0)
        }
    }
    
    private func savePreferences() async {
        isSubmitting = true
        
        struct UserPreferencesInsertDTO: Encodable {
            let user_id: UUID
            let processes: [String]?
            let roasts: [String]?
            let drinks: [String]?
            let times: [String]?
            let acidity: [String]?
            let flavor_notes: [String]?
            let weekly_consumption: String?
        }
        
        let dto = UserPreferencesInsertDTO(
            user_id: currentUserId,
            processes: emptyFiltered(selectedProcesses),
            roasts: emptyFiltered(selectedRoasts),
            drinks: emptyFiltered(selectedDrinks),
            times: emptyFiltered(selectedTimes),
            acidity: emptyFiltered(selectedAcidity),
            flavor_notes: emptyFiltered(selectedNotes),
            weekly_consumption: selectedWeekly.first
        )
        
        do {
            let client = SupabaseClient(
                supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
                supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
            )
            
            try await client.from("user_preferences").upsert(dto).execute()
            
            await MainActor.run {
                isSubmitting = false
                withAnimation {
                    submitSuccess = true
                }
            }
        } catch {
            print("Error saving preferences: \(error)")
            await MainActor.run {
                isSubmitting = false
            }
        }
    }
    
    private func emptyFiltered(_ set: Set<String>) -> [String]? {
        let arr = set.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        return arr.isEmpty ? nil : arr.sorted()
    }
}
