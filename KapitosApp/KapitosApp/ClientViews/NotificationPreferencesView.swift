//
//  NotificationPreferencesView.swift
//  KapitosApp
//

import SwiftUI

struct NotificationPreferencesView: View {
    
    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var notificationService = SmartNotificationService.shared
    @Environment(\.dismiss) var dismiss
    
    let currentUserId: UUID
    
    @State private var notifyNewMatches = true
    @State private var notifyHarvests = true
    @State private var notifyTours = true
    @State private var notifyMessages = true
    @State private var notifyRadius: Double = 50 // km
    @State private var showTestNotification = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notificaciones Inteligentes")
                            .font(.title.bold())
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        
                        Text("Recibe alertas personalizadas sobre productores, cosechas y tours cercanos")
                            .font(.subheadline)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.7) : AppColors.textLight.opacity(0.7))
                    }
                    .padding(.bottom, 8)
                    
                    // Permission Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Estado de Permisos")
                            .font(.headline)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        
                        permissionRow(
                            title: "Notificaciones",
                            isGranted: notificationService.notificationPermissionGranted,
                            icon: "bell.fill"
                        )
                        
                        permissionRow(
                            title: "Ubicación",
                            isGranted: notificationService.locationPermissionGranted,
                            icon: "location.fill"
                        )
                        
                        if !notificationService.notificationPermissionGranted {
                            Button {
                                Task {
                                    _ = await notificationService.requestNotificationPermission()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "bell.badge")
                                    Text("Activar Notificaciones")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        
                        if !notificationService.locationPermissionGranted {
                            Button {
                                notificationService.requestLocationPermission()
                            } label: {
                                HStack {
                                    Image(systemName: "location.circle")
                                    Text("Activar Ubicación")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.isDarkMode ? AppColors.cardDark : Color.white)
                            .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                    )
                    
                    // Notification Types
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tipos de Notificaciones")
                            .font(.headline)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        
                        notificationToggle(
                            title: "Nuevos Productores Compatibles",
                            description: "Te notificaremos cuando haya nuevos productores que coincidan con tus preferencias",
                            icon: "sparkles",
                            color: .yellow,
                            isOn: $notifyNewMatches
                        )
                        
                        notificationToggle(
                            title: "Alertas de Cosecha",
                            description: "Recibe avisos cuando la cosecha de productores compatibles esté próxima",
                            icon: "leaf.fill",
                            color: .green,
                            isOn: $notifyHarvests
                        )
                        
                        notificationToggle(
                            title: "Tours Cercanos",
                            description: "Descubre productores con tours de cafetales cerca de tu ubicación",
                            icon: "map.fill",
                            color: .orange,
                            isOn: $notifyTours
                        )
                        
                        notificationToggle(
                            title: "Mensajes",
                            description: "Notificaciones de nuevos mensajes de productores",
                            icon: "message.fill",
                            color: .blue,
                            isOn: $notifyMessages
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.isDarkMode ? AppColors.cardDark : Color.white)
                            .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                    )
                    
                    // Proximity Settings
                    if notifyTours {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Radio de Búsqueda")
                                .font(.headline)
                                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Distancia máxima para tours")
                                        .font(.subheadline)
                                        .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.8) : AppColors.textLight.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    Text("\(Int(notifyRadius)) km")
                                        .font(.subheadline.bold())
                                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                }
                                
                                Slider(value: $notifyRadius, in: 10...200, step: 10)
                                    .accentColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                
                                HStack {
                                    Text("10 km")
                                        .font(.caption)
                                        .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.6) : AppColors.textLight.opacity(0.6))
                                    
                                    Spacer()
                                    
                                    Text("200 km")
                                        .font(.caption)
                                        .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.6) : AppColors.textLight.opacity(0.6))
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(theme.isDarkMode ? AppColors.cardDark : Color.white)
                                .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                        )
                    }
                    
                    // Test & Generate Notifications
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await notificationService.generateContextualNotifications(userId: currentUserId)
                                showTestNotification = true
                            }
                        } label: {
                            HStack {
                                if notificationService.isSchedulingNotifications {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "bell.badge.fill")
                                    Text("Generar Notificaciones Ahora")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(notificationService.isSchedulingNotifications || !notificationService.notificationPermissionGranted)
                        
                        // INSTRUCCIONES IMPORTANTES
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Cómo ver las notificaciones")
                                    .font(.headline)
                                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top, spacing: 8) {
                                    Text("1️⃣")
                                    Text("Presiona \"Generar Notificaciones Ahora\"")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                HStack(alignment: .top, spacing: 8) {
                                    Text("2️⃣")
                                    Text("Minimiza la app (presiona el botón Home)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                HStack(alignment: .top, spacing: 8) {
                                    Text("3️⃣")
                                    Text("Espera 5-10 segundos para ver las notificaciones")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    Text("Con la app abierta verás banners arriba. Para ver el banner completo del sistema, minimiza la app")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                        )
                        
                        Button {
                            notificationService.removeAllPendingNotifications()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Limpiar Notificaciones Pendientes")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.isDarkMode ? AppColors.cardDark : Color.white)
                            .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                    )
                    
                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            
                            Text("Cómo funciona")
                                .font(.headline)
                                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        }
                        
                        Text("• Las notificaciones se generan automáticamente basadas en tus preferencias\n• Solo recibirás alertas de productores altamente compatibles (>60%)\n• Las notificaciones de ubicación requieren permiso de ubicación activo\n• Puedes desactivar cualquier tipo en cualquier momento")
                            .font(.caption)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.7) : AppColors.textLight.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .padding(20)
            }
            .background((theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        savePreferences()
                        dismiss()
                    }
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                }
            }
            .alert("Notificaciones Generadas", isPresented: $showTestNotification) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Las notificaciones contextuales han sido programadas. Revisa tus notificaciones pendientes.")
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func permissionRow(title: String, isGranted: Bool, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isGranted ? .green : .red)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
            
            Spacer()
            
            HStack(spacing: 4) {
                Circle()
                    .fill(isGranted ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(isGranted ? "Activo" : "Inactivo")
                    .font(.caption)
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.7) : AppColors.textLight.opacity(0.7))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.isDarkMode ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
        )
    }
    
    private func notificationToggle(
        title: String,
        description: String,
        icon: String,
        color: Color,
        isOn: Binding<Bool>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: isOn) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.subheadline.bold())
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                        
                        Text(description)
                            .font(.caption)
                            .foregroundColor(theme.isDarkMode ? AppColors.textDark.opacity(0.6) : AppColors.textLight.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .tint(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.isDarkMode ? Color.white.opacity(0.05) : Color.gray.opacity(0.1))
        )
    }
    
    // MARK: - Save Preferences
    
    private func savePreferences() {
        // TODO: Save preferences to database (user_preferences table or new notification_preferences table)
        print("💾 Saving notification preferences:")
        print("  - New Matches: \(notifyNewMatches)")
        print("  - Harvests: \(notifyHarvests)")
        print("  - Tours: \(notifyTours)")
        print("  - Messages: \(notifyMessages)")
        print("  - Radius: \(Int(notifyRadius)) km")
        
        // For now, just print. In production, save to Supabase
    }
}

#Preview {
    NotificationPreferencesView(currentUserId: UUID())
        .environmentObject(AppThemeManager())
}
