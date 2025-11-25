//
//  MapView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 15/11/25.
//

import SwiftUI
import MapKit

struct MapView: View {

    @EnvironmentObject var theme: AppThemeManager
    @State private var showStore = false

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: mockCafe.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.20, longitudeDelta: 0.20)
        )
    )

    var body: some View {

        ZStack {
            Map(
                position: $position,
                interactionModes: .all
            ) {
                // Café de Córdoba PIN
                Annotation(mockCafe.name, coordinate: mockCafe.coordinate) {
                    Button {
                        showStore = true
                    } label: {
                        VStack(spacing: 4) {

                            Image(mockCafe.profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight, lineWidth: 3)
                                )
                                .shadow(radius: 6)

                            Image(systemName: "triangle.fill")
                                .font(.system(size: 12))
                                .rotationEffect(.degrees(180))
                                .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        }
                    }
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea()

            VStack {
                Text("Tiendas de Café")
                    .font(.title3.bold())
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    .padding(.top, 35)
                Spacer()
            }
        }
        .sheet(isPresented: $showStore) {
            ProducerStoreFrontView(producer: mockCafe)
                .environmentObject(theme)
        }
    }
}
