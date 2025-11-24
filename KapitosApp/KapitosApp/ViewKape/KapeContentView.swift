//
//  KapeContentView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct KapeContentView: View {

    @State private var showMenu = false
    @State private var currentPage: KapePage = .dashboard
    @StateObject var theme = AppThemeManager()

    var body: some View {
        NavigationStack {
            ZStack {

                // -------- CURRENT PAGE --------
                Group {
                    switch currentPage {
                    case .dashboard:
                        DashboardView().environmentObject(theme)
                    case .requests:
                        RequestsListView().environmentObject(theme)
                    case .producers:
                        ProducersListView().environmentObject(theme)
                    case .clients:
                        ClientsListView().environmentObject(theme)
                    case .accounts:
                        AccountGeneratorView().environmentObject(theme)
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

                // -------- TAP OUTSIDE TO CLOSE --------
                if showMenu {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showMenu = false
                            }
                        }
                }

                // -------- SIDE MENU --------
                if showMenu {
                    KapeSideMenu(
                        currentPage: $currentPage,
                        showMenu: $showMenu
                    )
                    .environmentObject(theme)
                    .offset(x: showMenu ? -70 : -260)   // IGUAL QUE TU MENU PRINCIPAL
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showMenu)
                }
            }
        }
    }
}

#Preview {
    KapeContentView()
}
