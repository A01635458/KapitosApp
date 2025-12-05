
import SwiftUI
import Combine

enum AppScreen {
    case home
    case map
    case profile
    case mensajesCliente 
}

struct ContentView: View {

    @State private var showMenu = false
    @State private var currentScreen: AppScreen = .home
    @StateObject var theme = AppThemeManager()
    @State private var currentUserId: UUID?
    @State private var isLoadingUser = true
    @StateObject private var navigationManager = NavigationManager.shared

    var body: some View {
        NavigationStack {
            ZStack {

                // ===== BACKGROUND GENERAL =====
                (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                    .ignoresSafeArea()

                if isLoadingUser {
                    ProgressView("Cargando...")
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight))
                } else if let userId = currentUserId {
                    mainContent(userId: userId)
                } else {
                    Text("Error: No se pudo obtener el usuario")
                        .foregroundColor(.red)
                }
            }
        }
        .environmentObject(theme)
        .task {
            await loadCurrentUser()
        }
        .onChange(of: navigationManager.navigationScreen) { oldValue, newValue in
            if let screen = newValue {
                print("🧭 ContentView: Navigating to screen: \(screen)")
                currentScreen = screen
            }
        }
    }
    
    @ViewBuilder
    private func mainContent(userId: UUID) -> some View {
        ZStack {
            Group {
                switch currentScreen {

                case .home:
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {

                            Text("Home")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                                .padding(.horizontal, 20)

                            MapPreviewCard(currentScreen: $currentScreen)
                                .environmentObject(theme)

                            HomeView(currentUserId: userId)
                                .environmentObject(theme)
                        }
                    }

                case .map:
                    MapView(currentUserId: userId).environmentObject(theme)

                case .profile:
                    ProfileView(currentUserId: userId).environmentObject(theme)

                // ----------- CHAT CLIENTE -----------
                case .mensajesCliente:
                    ClientChatListView(currentUserId: userId)
                        .environmentObject(theme)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showMenu.toggle()
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    }
                }
            }

            if showMenu {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) { showMenu = false }
                    }
            }

            if showMenu {
                SideMenu(currentScreen: $currentScreen, showMenu: $showMenu)
                    .environmentObject(theme)
                    .offset(x: showMenu ? -70 : -260)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showMenu)
            }
        }
    }
    
    private func loadCurrentUser() async {
        currentUserId = await SupabaseClientManager.shared.getCurrentUserId()
        isLoadingUser = false
    }
}

#Preview { 
    ContentView()
}
