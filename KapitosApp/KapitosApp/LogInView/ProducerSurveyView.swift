//
//  Encuesta.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 23/11/25.
//

//
//  ProducerSurveyView.swift
//  KapitosApp
//

import SwiftUI

struct ProducerSurveyView: View {

    @EnvironmentObject var theme: AppThemeManager
    @State private var goToSuccess = false

    // --- DATOS PERSONALES ---
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""

    // --- FINCA ---
    @State private var brand = ""
    @State private var farmSize = ""
    @State private var location = ""
    @State private var altitude = ""
    @State private var shadeType = ""

    // --- PRODUCCIÓN ---
    @State private var production = ""
    @State private var varieties = ""
    @State private var processes = ""
    @State private var coffeeType = ""
    @State private var harvestDate = ""
    @State private var yield = ""

    // --- COMERCIAL ---
    @State private var price = ""
    @State private var sellingTo = ""
    @State private var minVolume = ""
    @State private var exportReady = ""
    @State private var onlineSales = ""
    @State private var needs = ""

    // --- TURISMO ---
    @State private var hasTastingArea = ""
    @State private var touristAccess = ""

    // --- CERTIFICACIONES ---
    @State private var certifications = ""

    var body: some View {

        NavigationStack {

            ZStack {
                (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {

                        Text("Registro de Productor")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                            .padding(.top, 12)

                        // ----------------------------
                        // SECCIÓN: datos personales
                        // ----------------------------
                        sectionCard("Datos personales", icon: "person.fill") {
                            formField("Nombre completo", text: $name)
                            formField("Teléfono", text: $phone)
                            formField("Correo electrónico", text: $email)
                        }

                        // ----------------------------
                        // FINCA
                        // ----------------------------
                        sectionCard("Datos de la finca", icon: "leaf.fill") {
                            formField("Nombre de la marca / finca", text: $brand)
                            formField("Tamaño de la finca (ha)", text: $farmSize)
                            formField("Ubicación (opcional)", text: $location)
                            formField("Altura de cultivo (msnm)", text: $altitude)
                            formField("Tipo de sombra (nativa, mixta…)", text: $shadeType)
                        }

                        // ----------------------------
                        // PRODUCCIÓN
                        // ----------------------------
                        sectionCard("Producción", icon: "drop.fill") {
                            formField("Producción anual (kg)", text: $production)
                            formField("Variedades cultivadas", text: $varieties)
                            formField("Procesos (lavado, honey, natural…)", text: $processes)
                            formField("Tipo de café (pergamino, verde, tostado…)", text: $coffeeType)
                            formField("Última cosecha (mm/aaaa)", text: $harvestDate)
                            formField("Rendimiento (kg/ha)", text: $yield)
                        }

                        // ----------------------------
                        // COMERCIAL
                        // ----------------------------
                        sectionCard("Comercial", icon: "cart.fill") {
                            formField("Precio promedio por kg (MXN)", text: $price)
                            formField("¿A quién vendes actualmente?", text: $sellingTo)
                            formField("Volumen mínimo de venta (kg)", text: $minVolume)
                            formField("¿Estás abierto a exportar? (sí/no)", text: $exportReady)
                            formField("¿Vendes en línea? (sí/no + link)", text: $onlineSales)
                            formField("Necesidades actuales", text: $needs)
                        }

                        // ----------------------------
                        // TURISMO
                        // ----------------------------
                        sectionCard("Turismo / Visitas", icon: "location.viewfinder") {
                            formField("Área de degustación (sí/no)", text: $hasTastingArea)
                            formField("Acceso para turistas (sí/no)", text: $touristAccess)
                        }

                        // ----------------------------
                        // CERTIFICACIONES
                        // ----------------------------
                        sectionCard("Certificaciones", icon: "checkmark.seal.fill") {
                            formField("Certificaciones (orgánico, DO, etc.)", text: $certifications)
                        }

                        // ----------------------------
                        // BOTÓN
                        // ----------------------------
                        Button {
                            withAnimation {
                                goToSuccess = true
                            }
                        } label: {
                            Text("Enviar Registro")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                .cornerRadius(16)
                        }
                        .padding(.top, 10)

                        Spacer()
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(isPresented: $goToSuccess) {
                ProducerSuccessView().environmentObject(theme)
            }
        }
    }

    // MARK: - COMPONENTES UI

    func sectionCard(_ title: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.textLight)

                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            }

            VStack(spacing: 14) {
                content()
            }
            .padding(16)
            .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
            .cornerRadius(16)
            .shadow(color: theme.isDarkMode ? .black.opacity(0.4) : .black.opacity(0.1),
                    radius: 8, y: 4)
        }
    }

    func formField(_ placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(placeholder)
                .font(.footnote)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.8))

            TextField(placeholder, text: text)
                .padding()
                .background(theme.isDarkMode ? AppColors.backgroundDark.opacity(0.4)
                                            : AppColors.cardLight.opacity(0.8))
                .cornerRadius(12)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
        }
    }
}

#Preview {
    ProducerSurveyView().environmentObject(AppThemeManager())
}
