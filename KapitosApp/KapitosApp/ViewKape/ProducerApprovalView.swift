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
    @State private var showSuccessMessage = false
    @State private var showErrorMessage = false
    @State private var isProcessing = false

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
                    
                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                        .cornerRadius(10)
                    
                    SecureField("Confirmar contraseña", text: $confirmPassword)
                        .padding()
                        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                        .cornerRadius(10)
                    
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
        VStack(alignment: .leading, spacing: 12) {
            Text(producer.displayName)
                .font(.title2.bold())
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            
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
                }
            }
        }
        .padding()
        .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
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
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
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
            shade_type: nil,
            annual_production_kg: nil,
            last_harvest_date: nil,
            yield_per_ha: nil,
            price_per_kg: nil,
            current_buyers: nil,
            min_contract_volume: nil,
            open_to_export: nil,
            sells_online: nil,
            online_store_url: nil,
            needs: nil,
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
            coffee_type: "Arábica",
            status: "pending",
            created_at: Date()
        ))
        .environmentObject(AppThemeManager())
    }
}

