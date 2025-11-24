//
//  KapeAdminView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct KapeAdminView: View {

    @EnvironmentObject var theme: AppThemeManager
    @State private var showMenu = false
    @State private var currentPage: KapePage = .dashboard

    var body: some View {
        NavigationStack {
            ZStack {

                // ------ CURRENT PAGE ------
                Group {
                    switch currentPage {
                    case .dashboard:
                        DashboardView()

                    case .requests:
                        RequestsListView()

                    case .producers:
                        ProducersListView()

                    case .clients:
                        ClientsListView()

                    case .accounts:
                        AccountGeneratorView()
                    }
                }
                .environmentObject(theme)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation(.spring()) { showMenu.toggle() }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.textLight)
                        }
                    }
                }

                // ------ TAP OUTSIDE ------
                if showMenu {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showMenu = false } }
                }

                // ------ SIDE MENU ------
                if showMenu {
                    KapeSideMenu(currentPage: $currentPage, showMenu: $showMenu)
                        .environmentObject(theme)
                        .transition(.move(edge: .leading))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

enum KapePage {
    case dashboard, requests, producers, clients, accounts
}

#Preview {
    KapeAdminView().environmentObject(AppThemeManager())
}
