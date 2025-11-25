//
//  RegisterPreferencesView.swift
//  KapitosApp
//

import SwiftUI

struct RegisterPreferencesView: View {

    @EnvironmentObject var theme: AppThemeManager
    @State private var index = 0
    @State private var goToSuccess = false

    // MULTI SELECT
    @State private var selectedProcesses: Set<String> = []
    @State private var selectedDrinks: Set<String> = []
    @State private var selectedNotes: Set<String> = []

    // SINGLE SELECT
    @State private var selectedRoast: String? = nil
    @State private var selectedTime: String? = nil
    @State private var selectedAcidity: String? = nil
    @State private var selectedWeekly: String? = nil

    // OPTIONS WITH ICONS
    let processes = [
        ("Lavado", "drop.fill"),
        ("Honey", "hexagon.fill"),
        ("Natural", "leaf.fill"),
        ("Anaeróbico", "wind"),
        ("Carbonic", "aqi.medium"),
        ("Experimental", "sparkles")
    ]

    let roasts = [
        ("Claro", "sun.max.fill"),
        ("Medio", "sunrise.fill"),
        ("Oscuro", "moon.fill")
    ]

    let drinks = [
        ("Espresso", "cup.and.saucer.fill"),
        ("Americano", "drop.circle"),
        ("Latte", "cup.and.saucer"),
        ("Cold Brew", "snowflake"),
        ("Cappuccino", "cloud.fill"),
        ("Cortado", "circle.grid.cross.fill")
    ]

    let times = [
        ("Mañana", "sun.max.fill"),
        ("Tarde", "sunset.fill"),
        ("Noche", "moon.fill")
    ]

    let acidity = [
        ("Alta", "bolt.fill"),
        ("Media", "bolt.horizontal"),
        ("Baja", "bolt.slash.fill")
    ]

    let notes = [
        ("Cítrico", "leaf.fill"),
        ("Dulce", "cube.fill"),
        ("Chocolate", "square.fill"),
        ("Floral", "leaf.fill")
    ]

    let weekly = [
        ("1–3 tazas", "1.circle.fill"),
        ("4–7 tazas", "5.circle.fill"),
        ("8+ tazas", "8.circle.fill")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // -------- SALTAR TODO --------
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                goToSuccess = true
                            }
                        } label: {
                            skipChip("Saltar todo")
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }

                    Spacer().frame(height: 10)

                    // -------- ICON --------
                    Image(systemName: currentIcon)
                        .font(.system(size: 70))
                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.textLight)
                        .padding(.bottom, 10)

                    // -------- TITLE --------
                    Text(currentTitle)
                        .font(.title.bold())
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    // -------- GRID --------
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(currentOptions, id: \.0) { option in
                            cardOption(option.0, icon: option.1)
                        }
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    // -------- NEXT --------
                    Button {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            if index == allQuestions.count - 1 {
                                goToSuccess = true
                            } else {
                                index += 1
                            }
                        }
                    } label: {
                        Text(index == allQuestions.count - 1 ? "Terminar" : "Siguiente")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background((theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 30)

                    // -------- SALTAR PREGUNTA --------
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if index == allQuestions.count - 1 {
                                goToSuccess = true
                            } else {
                                index += 1
                            }
                        }
                    } label: {
                        skipChip("Saltar pregunta")
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(isPresented: $goToSuccess) {
                SuccessView().environmentObject(theme)
            }
        }
    }

    // -------- CHIP UI --------
    func skipChip(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundColor(theme.isDarkMode ? AppColors.accentDark.opacity(0.85) : AppColors.textLight.opacity(0.75))
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.isDarkMode ? AppColors.cardDark.opacity(0.4) : AppColors.cardLight.opacity(0.7))
            )
            .shadow(color: theme.isDarkMode ? .black.opacity(0.2) : .black.opacity(0.08),
                    radius: 4, y: 2)
    }

    // -------- CARD OPTION --------
    func cardOption(_ text: String, icon: String) -> some View {

        let isSelected: Bool = {
            switch index {
            case 0: return selectedProcesses.contains(text)
            case 1: return selectedRoast == text
            case 2: return selectedDrinks.contains(text)
            case 3: return selectedTime == text
            case 4: return selectedAcidity == text
            case 5: return selectedNotes.contains(text)
            case 6: return selectedWeekly == text
            default: return false
            }
        }()

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                switch index {

                // MULTI SELECT
                case 0: toggleMulti(text, set: &selectedProcesses)
                case 2: toggleMulti(text, set: &selectedDrinks)
                case 5: toggleMulti(text, set: &selectedNotes)

                // SINGLE SELECT
                case 1: selectedRoast = text
                case 3: selectedTime = text
                case 4: selectedAcidity = text
                case 6: selectedWeekly = text

                default: break
                }
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(isSelected ? .white :
                        (theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight))

                Text(text)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(isSelected ? .white :
                        (theme.isDarkMode ? .white.opacity(0.85) : AppColors.textLight))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ?
                          (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight) :
                          (theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight))
            )
            .shadow(color: isSelected ? AppColors.accentDark.opacity(0.3) : .clear,
                    radius: isSelected ? 10 : 0, y: isSelected ? 4 : 0)
        }
    }

    // MARK: Multi-select toggle
    func toggleMulti(_ item: String, set: inout Set<String>) {
        if set.contains(item) { set.remove(item) }
        else { set.insert(item) }
    }

    // -------- QUESTIONS CONFIG --------
    var allQuestions: [(String, String, [(String, String)])] {
        [
            ("¿Qué procesos te gustan?", "drop.fill", processes),      // multi
            ("Tu tueste favorito", "flame.fill", roasts),                            // single
            ("¿Qué bebidas tomas?", "cup.and.saucer.fill", drinks),   // multi
            ("¿A qué hora tomas café?", "clock.fill", times),                        // single
            ("Acidez preferida", "bolt.heart.fill", acidity),                        // single
            ("¿Qué notas te gustan?", "leaf.fill", notes),                           // multi
            ("¿Cuánto café consumes por semana?", "chart.bar.fill", weekly)          // single
        ]
    }

    var currentTitle: String { allQuestions[index].0 }
    var currentIcon: String { allQuestions[index].1 }
    var currentOptions: [(String, String)] { allQuestions[index].2 }
}

#Preview {
    RegisterPreferencesView().environmentObject(AppThemeManager())
}
