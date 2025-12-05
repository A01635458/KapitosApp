////
////  ProducerContentView.swift
////  KapitosApp
////
////  Created by Luisa Cardona on 25/11/25.
////
//
//import SwiftUI
//
//struct ProducerContentView: View {
//
//    @State private var showMenu = false
//    @State private var currentPage: ProducerScreen = .dashboard
//
//    @StateObject var theme = AppThemeManager()
//    @StateObject var store = ProducerStore()
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//
//                // ---------- BACKGROUND DINÁMICO ----------
//                (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
//                    .ignoresSafeArea()
//
//                // ---------- CURRENT PAGE ----------
//                Group {
//                    switch currentPage {
//                    case .dashboard:
//                        ProducerDashboardView()
//                            .environmentObject(theme)
//                            .environmentObject(store)
//
//                    case .business:
//                        ProducerBusinessView()
//                            .environmentObject(theme)
//                            .environmentObject(store)
//
//                    case .shop:
//                        ProducerShopView()
//                            .environmentObject(theme)
//                            .environmentObject(store)
//
//                    case .profile:
//                        ProducerProfileView()
//                            .environmentObject(theme)
//                            .environmentObject(store)
//
//                    case .customerPreview:
//                        ProducerCustomerPreviewView()
//                            .environmentObject(theme)
//                            .environmentObject(store)
//                    }
//                }
//                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Button {
//                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
//                                showMenu.toggle()
//                            }
//                        } label: {
//                            Image(systemName: "line.horizontal.3")
//                                .font(.system(size: 22, weight: .bold))
//                                .foregroundColor(
//                                    theme.isDarkMode ? AppColors.textDark : AppColors.textLight
//                                )
//                        }
//                    }
//                }
//
//                // ---------- TAP OUTSIDE TO CLOSE ----------
//                if showMenu {
//                    Color.black.opacity(0.35)
//                        .ignoresSafeArea()
//                        .onTapGesture {
//                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
//                                showMenu = false
//                            }
//                        }
//                }
//
//                // ---------- SIDE MENU ----------
//                if showMenu {
//                    ProducerSideMenu(
//                        current: $currentPage,
//                        showMenu: $showMenu
//                    )
//                    .environmentObject(theme)
//                    .environmentObject(store)
//                    .offset(x: showMenu ? -70 : -260)
//                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showMenu)
//                }
//            }
//        }
//        .environmentObject(theme)
//        .environmentObject(store)
//    }
//}
//
//#Preview {
//    ProducerContentView()
//}


import SwiftUI

struct ProducerContentView: View {

    let currentUserId: UUID
    
    @State private var showMenu = false
    @State private var currentPage: ProducerScreen = .dashboard

    @StateObject var theme = AppThemeManager()
    @StateObject private var store: ProducerStore
    
    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
        _store = StateObject(wrappedValue: ProducerStore(currentUserId: currentUserId))
    }

    var body: some View {
        NavigationStack {
            ZStack {

                (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                    .ignoresSafeArea()

                Group {
                    switch currentPage {

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

                    case .customerPreview:
                        ProducerCustomerPreviewView()
                            .environmentObject(theme)
                            .environmentObject(store)

                    case .profile:
                        ProducerProfileView()
                            .environmentObject(theme)
                            .environmentObject(store)

                    // ---------- NUEVO: MENSAJES PRODUCTOR ----------
                    case .mensajesProductor:
                        ProducerChatListView(currentUserId: currentUserId)
                            .environmentObject(theme)
                            .environmentObject(store)
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
                                .foregroundColor(
                                    theme.isDarkMode ? AppColors.textDark : AppColors.textLight
                                )
                        }
                    }
                }

                if showMenu {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showMenu = false
                            }
                        }
                }

                if showMenu {
                    ProducerSideMenu(
                        current: $currentPage,
                        showMenu: $showMenu
                    )
                    .environmentObject(theme)
                    .environmentObject(store)
                    .offset(x: showMenu ? -70 : -260)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showMenu)
                }
            }
        }
        .environmentObject(theme)
        .environmentObject(store)
    }
}

#Preview {
    ProducerContentView(currentUserId: UUID())
}
