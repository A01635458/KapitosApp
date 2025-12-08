//
//  ProducerApprovalView.swift
//  KapitosApp
//  Created by Luisa Cardona on 23/11/25.
//

import SwiftUI

struct ProducerApprovalView: View {
    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var approvalService = ProducerApprovalService.shared
    @Environment(\.dismiss) private var dismiss
    
    let producer: Producer
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    @State private var showSuccessMessage = false
    @State private var showErrorMessage = false
    @State private var isProcessing = false
    @State private var showFullDetails = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Producer Info Card
                producerInfoCard
                
                // Credentials Form
                VStack(spacing: 16) {
                    Text("Crear credenciales de acceso")
                        .font(.headline)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Email del productor", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding()
                        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                        .cornerRadius(10)
                    
                    // Campo de contraseña con visibilidad
                    ZStack(alignment: .trailing) {
                        if showPassword {
                            TextField("Contraseña", text: $password)
                                .padding()
                                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .cornerRadius(10)
                        } else {
                            SecureField("Contraseña", text: $password)
                                .padding()
                                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .cornerRadius(10)
                        }
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                showPassword.toggle()
                            }
                        } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }
                    
                    // Campo de confirmar contraseña con visibilidad
                    ZStack(alignment: .trailing) {
                        if showConfirmPassword {
                            TextField("Confirmar contraseña", text: $confirmPassword)
                                .padding()
                                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .cornerRadius(10)
                        } else {
                            SecureField("Confirmar contraseña", text: $confirmPassword)
                                .padding()
                                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .cornerRadius(10)
                        }
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                showConfirmPassword.toggle()
                            }
                        } label: {
                            Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }
                    
                    if !password.isEmpty && password != confirmPassword {
                        Text("Las contraseñas no coinciden")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(theme.isDarkMode ? AppColors.cardDark.opacity(0.5) : AppColors.cardLight.opacity(0.8))
                .cornerRadius(16)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        Task { await handleApprove() }
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Aprobar y crear cuenta")
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight) : Color.gray)
                        .cornerRadius(16)
                    }
                    .disabled(!isFormValid || isProcessing)
                    
                    Button {
                        Task { await handleReject() }
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Rechazar solicitud")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(16)
                    }
                    .disabled(isProcessing)
                }
                
                // Messages
                if showSuccessMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("¡Productor aprobado exitosamente!")
                    }
                    .foregroundColor(.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                
                if showErrorMessage, let error = approvalService.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(error)
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
        }
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .navigationTitle("Revisar Solicitud")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Subviews
    private var producerInfoCard: some View {
        Button {
            showFullDetails = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(producer.displayName)
                        .font(.title2.bold())
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(theme.isDarkMode ? .white.opacity(0.5) : AppColors.textLight.opacity(0.5))
                }
                
                if !producer.location.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                        Text(producer.location)
                    }
                    .font(.subheadline)
                    .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                }
                
                Divider()
                
                // Details Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    if let years = producer.experience_years {
                        infoItem(icon: "clock.fill", label: "Experiencia", value: "\(years) años")
                    }
                    if let altitude = producer.altitude {
                        infoItem(icon: "mountain.2.fill", label: "Altitud", value: "\(altitude)m")
                    }
                    if let size = producer.farm_size_ha {
                        infoItem(icon: "leaf.fill", label: "Tamaño", value: String(format: "%.1f ha", size))
                    }
                    if let phone = producer.phone {
                        infoItem(icon: "phone.fill", label: "Teléfono", value: phone)
                    }
                }
                
                if let varieties = producer.varieties, !varieties.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Variedades")
                            .font(.caption.bold())
                            .foregroundColor(theme.isDarkMode ? .white.opacity(0.6) : AppColors.textLight.opacity(0.6))
                        Text(varieties.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
                
                Text("Toca para ver solicitud completa")
                    .font(.caption)
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
            .padding()
            .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showFullDetails) {
            fullDetailsSheet
        }
    }
    
    private func infoItem(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(theme.isDarkMode ? .white.opacity(0.6) : AppColors.textLight.opacity(0.6))
            
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
        }
    }
    
    // MARK: - Full Details Sheet
    private var fullDetailsSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // DATOS PERSONALES
                    detailSection(title: "Datos Personales", icon: "person.fill") {
                        detailRow(label: "Nombre", value: producer.displayName)
                        if let phone = producer.phone {
                            detailRow(label: "Teléfono", value: phone)
                        }
                        if let years = producer.experience_years {
                            detailRow(label: "Años de experiencia", value: "\(years)")
                        }
                        if let photoUrl = producer.photo_url {
                            detailRow(label: "Foto", value: photoUrl)
                        }
                    }
                    
                    // DATOS DE LA FINCA
                    detailSection(title: "Datos de la Finca", icon: "leaf.fill") {
                        if let size = producer.farm_size_ha {
                            detailRow(label: "Tamaño (ha)", value: String(format: "%.1f", size))
                        }
                        if !producer.location.isEmpty {
                            detailRow(label: "Ubicación", value: producer.location)
                        }
                        if let state = producer.state {
                            detailRow(label: "Estado", value: state)
                        }
                        if let municipality = producer.municipality {
                            detailRow(label: "Municipio", value: municipality)
                        }
                        if let altitude = producer.altitude {
                            detailRow(label: "Altitud (msnm)", value: "\(altitude)")
                        }
                        if let shade = producer.shade_coverage_percent {
                            detailRow(label: "Cobertura de sombra", value: "\(shade)%")
                        }
                        if let lat = producer.latitude, let lon = producer.longitude {
                            detailRow(label: "Coordenadas", value: "(\(lat), \(lon))")
                        }
                    }
                    
                    // PRODUCCIÓN
                    detailSection(title: "Producción", icon: "drop.fill") {
                        if let production = producer.annual_production_kg {
                            detailRow(label: "Producción anual (kg)", value: "\(production)")
                        }
                        if let varieties = producer.varieties, !varieties.isEmpty {
                            detailRow(label: "Variedades", value: varieties.joined(separator: ", "))
                        }
                        if let processes = producer.processes, !processes.isEmpty {
                            detailRow(label: "Procesos", value: processes.joined(separator: ", "))
                        }
                        if let harvestDate = producer.last_harvest_date {
                            detailRow(label: "Última cosecha", value: harvestDate)
                        }
                        if let yieldVal = producer.yield_per_ha {
                            detailRow(label: "Rendimiento (kg/ha)", value: String(format: "%.1f", yieldVal))
                        }
                    }
                    
                    // COMERCIAL
                    detailSection(title: "Información Comercial", icon: "cart.fill") {
                        if let price = producer.price_per_kg {
                            detailRow(label: "Precio por kg (MXN)", value: String(format: "%.2f", price))
                        }
                        if let salesTypes = producer.sales_types, !salesTypes.isEmpty {
                            detailRow(label: "Tipos de venta", value: salesTypes.joined(separator: ", "))
                        }
                        if let minVol = producer.min_contract_volume {
                            detailRow(label: "Volumen mínimo (kg)", value: "\(minVol)")
                        }
                        if let export = producer.open_to_export {
                            detailRow(label: "Exporta", value: export ? "Sí" : "No")
                        }
                        if let online = producer.sells_online {
                            detailRow(label: "Vende en línea", value: online ? "Sí" : "No")
                        }
                        if let storeUrl = producer.online_store_url {
                            detailRow(label: "Tienda en línea", value: storeUrl)
                        }
                    }
                    
                    // TURISMO
                    detailSection(title: "Turismo", icon: "location.viewfinder") {
                        if let tasting = producer.has_tourist_area {
                            detailRow(label: "Área de degustación", value: tasting ? "Sí" : "No")
                        }
                        if let accessible = producer.tourist_accessible {
                            detailRow(label: "Acceso a turistas", value: accessible ? "Sí" : "No")
                        }
                        if let details = producer.tourism_details {
                            detailRow(label: "Detalles turísticos", value: details)
                        }
                    }
                    
                    // CERTIFICACIONES
                    if let certifications = producer.certifications, !certifications.isEmpty {
                        detailSection(title: "Certificaciones", icon: "checkmark.seal.fill") {
                            detailRow(label: "Certificaciones", value: certifications.joined(separator: ", "))
                        }
                    }
                    
                    // CONSENTIMIENTOS
                    detailSection(title: "Consentimientos", icon: "hand.raised.fill") {
                        if let gps = producer.consent_gps {
                            detailRow(label: "GPS compartido", value: gps ? "Sí" : "No")
                        }
                        if let ai = producer.consent_ai {
                            detailRow(label: "Análisis con IA", value: ai ? "Sí" : "No")
                        }
                        if let notif = producer.consent_notifications {
                            detailRow(label: "Notificaciones", value: notif ? "Sí" : "No")
                        }
                    }
                }
                .padding()
            }
            .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
            .navigationTitle("Solicitud Completa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        showFullDetails = false
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private func detailSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                Text(title)
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
            .padding()
            .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
            .cornerRadius(12)
        }
    }
    
    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.6) : AppColors.textLight.opacity(0.6))
            Text(value)
                .font(.subheadline)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Validation
    private var isFormValid: Bool {
        !email.isEmpty
        && email.contains("@")
        && password.count >= 6
        && password == confirmPassword
    }
    
    // MARK: - Actions
    private func handleApprove() async {
        isProcessing = true
        showSuccessMessage = false
        showErrorMessage = false
        
        let success = await approvalService.approveProducer(
            producerId: producer.id,
            email: email,
            password: password
        )
        
        isProcessing = false
        
        if success {
            showSuccessMessage = true
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            dismiss()
        } else {
            showErrorMessage = true
        }
    }
    
    private func handleReject() async {
        isProcessing = true
        showErrorMessage = false
        
        let success = await approvalService.rejectProducer(producerId: producer.id)
        
        isProcessing = false
        
        if success {
            dismiss()
        } else {
            showErrorMessage = true
        }
    }
}

#Preview {
    NavigationStack {
        ProducerApprovalView(producer: Producer(
            id: UUID(),
            farm_name: "Finca El Paraíso",
            experience_years: 15,
            phone: "123456789",
            photo_url: nil,
            farm_size_ha: 5.5,
            country: "Colombia",
            state: "Antioquia",
            municipality: "Jardín",
            latitude: 5.5983,
            longitude: -75.8208,
            shade_coverage_percent: 70,
            annual_production_kg: nil,
            last_harvest_date: nil,
            yield_per_ha: nil,
            price_per_kg: nil,
            sales_types: ["Mayoreo Nacional (>1000kg)", "Menudeo (directo)"],
            min_contract_volume: nil,
            open_to_export: nil,
            sells_online: nil,
            online_store_url: nil,
            has_tourist_area: nil,
            tourist_accessible: nil,
            tourism_details: nil,
            consent_gps: nil,
            consent_ai: nil,
            consent_notifications: nil,
            varieties: ["Caturra", "Castillo"],
            processes: ["Lavado", "Natural"],
            certifications: ["Orgánico"],
            altitude: 1800,
            status: "pending",
            created_at: Date()
        ))
        .environmentObject(AppThemeManager())
    }
}
