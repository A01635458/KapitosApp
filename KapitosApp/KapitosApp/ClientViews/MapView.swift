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
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -7.9813, longitude: 112.6313),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    var body: some View {
        ZStack {
            Map(position: $position)
                .mapStyle(.standard)
                .overlay(
                    Rectangle()
                        .fill(
                            (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                                .opacity(theme.isDarkMode ? 0.28 : 0.4)
                        )
                )
                .ignoresSafeArea()

            VStack {
                Text("KOTA MALANG")
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    .padding(.top, 45)

                Spacer()

                Image(systemName: "location.fill")
                    .font(.largeTitle)
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    .padding()
                    .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                    .clipShape(Circle())
                    .shadow(radius: 8)

                Spacer()
            }
        }
    }
}
