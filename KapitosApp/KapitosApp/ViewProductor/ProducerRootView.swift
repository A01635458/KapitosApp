//
//  ProducerRootView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 25/11/25.
//
import SwiftUI

enum ProducerScreen {
    case dashboard
    case business
    case shop
    case profile
    case customerPreview
    case mensajesProductor
}

struct ProducerRootView: View {

    let currentUserId: UUID
    
    @StateObject private var store: ProducerStore
    @StateObject var theme = AppThemeManager()

    @State private var showMenu = false
    @State private var screen: ProducerScreen = .dashboard
    
    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
        _store = StateObject(wrappedValue: ProducerStore(currentUserId: currentUserId))
    }

    var body: some View {
        NavigationStack {
            ZStack {

                // --- CURRENT SCREEN ---
                Group {
                    switch screen {

                    case .dashboard:
                        ProducerDashboardView(currentUserId: currentUserId)
                            .environmentObject(theme)
                            .environmentObject(store)

                    case .business:
                        ProducerBusinessView()
                            .environmentObject(theme)
                            .environmentObject(store)

                    case .shop:
                        ProducerShopView()
                            .environmentObject(theme)
                            .environmentObject(store)

                    case .profile:
                        ProducerProfileView()
                            .environmentObject(theme)
                            .environmentObject(store)

                    case .customerPreview:
                        ProducerCustomerPreviewView()
                            .environmentObject(theme)
                            .environmentObject(store)
                        
                case .mensajesProductor:
                    ProducerChatListView(currentUserId: currentUserId)
                        .environmentObject(theme)
                        .environmentObject(store)                    }
                }
                .environmentObject(theme)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showMenu.toggle()
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(theme.isDarkMode ? .white : .black)
                        }
                    }
                }

                // ---- DARK OVERLAY ----
                if showMenu {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showMenu = false
                            }
                        }
                }

                // ---- SIDE MENU ----
                if showMenu {
                    ProducerSideMenu(
                        current: $screen,
                        showMenu: $showMenu
                    )
                    .environmentObject(theme)
                    .environmentObject(store)
                    .offset(x: showMenu ? -60 : -260)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showMenu)
                }
            }
        }
    }
}

#Preview {
    ProducerRootView(currentUserId: UUID())
}
