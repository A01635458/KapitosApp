import SwiftUI

// Enum para controlar la pantalla actual
enum AppScreen {
    case home
    case map
    case profile
}

struct ContentView: View {

    @State private var showMenu = false
    @State private var currentScreen: AppScreen = .home
    @StateObject var theme = AppThemeManager()

    var body: some View {
        NavigationStack {
            ZStack {
                
                // --- CURRENT SCREEN ---
                Group {
                    switch currentScreen {
                    case .home:
                        HomeView()
                            .environmentObject(theme)
                    case .map:
                        MapView()
                            .environmentObject(theme)
                    case .profile:
                        ProfileView()
                            .environmentObject(theme)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showMenu.toggle() // Abre o cierra el menú
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        }
                    }
                }

                //cerrar picando afuera
                if showMenu {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showMenu = false // Cierra el menú si tocas afuera
                            }
                        }
                }

                //side menbu
                if showMenu {
                    SideMenu(
                        currentScreen: $currentScreen,
                        showMenu: $showMenu
                    )
                    .environmentObject(theme)
                    .offset(x: showMenu ? -70 : -260)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showMenu)
                }
            }
        }
        .environmentObject(theme)
    }
}

#Preview {
    ContentView()
}
