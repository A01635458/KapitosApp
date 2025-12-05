
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
    let currentUserId: UUID

    var body: some View {
        NavigationStack {
            ZStack {

                // ===== BACKGROUND GENERAL =====
                (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                    .ignoresSafeArea()

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

                                HomeView(currentUserId: currentUserId)
                                    .environmentObject(theme)
                            }
                        }

                    case .map:
                        MapView().environmentObject(theme)

                    case .profile:
                        ProfileView(currentUserId: currentUserId).environmentObject(theme)

                    // ----------- NUEVO: CHAT CLIENTE -----------
                    case .mensajesCliente:
                        ClientChatListView(currentUserId: currentUserId)
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
        .environmentObject(theme)
    }
}

#Preview { 
    ContentView(currentUserId: UUID(uuidString: "3ba73474-dc62-4c5a-86a3-d70069097d17")!)
}
