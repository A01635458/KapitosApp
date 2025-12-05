//
//  ProfileView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 18/11/25.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @EnvironmentObject var theme: AppThemeManager
    let currentUserId: UUID
    
    @State private var showNotificationPreferences = false
    @State private var showImageSourceSelector = false
    @State private var isUploadingPhoto = false
    @State private var userProfile: UserProfile?
    @State private var profileImage: UIImage?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
        supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    )

    var body: some View {
        ZStack {
            (theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
                .ignoresSafeArea()

            if isLoading {
                ProgressView("Cargando perfil...")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Error al cargar perfil")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                VStack(spacing: 20) {
                    // Profile Photo with Edit Button
                    ZStack(alignment: .bottomTrailing) {
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight, lineWidth: 3)
                                )
                        } else {
                            Circle()
                                .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                                )
                        }
                        
                        // Edit button
                        Button {
                            showImageSourceSelector = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                    .frame(width: 36, height: 36)
                                
                                if isUploadingPhoto {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: profileImage == nil ? "camera.fill" : "pencil")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                            }
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isUploadingPhoto)
                    }

                    Text(userProfile?.full_name ?? "Usuario")
                        .font(.title2)
                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    
                    Text(userProfile?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Role Badge
                    Text(userProfile?.displayRole ?? "")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    
                    // Notification Settings Button
                    Button {
                        showNotificationPreferences = true
                    } label: {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                            Text("Notificaciones Inteligentes")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.isDarkMode ? AppColors.cardDark : Color.white)
                                .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
                        )
                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showNotificationPreferences) {
            NotificationPreferencesView(currentUserId: currentUserId)
                .environmentObject(theme)
        }
        .background {
            ImageSourceSelector(image: Binding(
                get: { nil },
                set: { newImage in
                    if let img = newImage {
                        Task {
                            await uploadProfilePhoto(img)
                        }
                    }
                }
            ), showActionSheet: $showImageSourceSelector)
        }
        .task {
            await loadUserProfile()
        }
    }
    
    // MARK: - Load User Profile
    
    private func loadUserProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let profile: UserProfile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUserId.uuidString)
                .single()
                .execute()
                .value
            
            userProfile = profile
            
            // Load profile image if URL exists
            if let photoUrl = profile.photo_url, !photoUrl.isEmpty {
                await loadProfileImageFromURL(photoUrl)
            }
            
            isLoading = false
        } catch {
            print("❌ Error loading user profile: \(error)")
            errorMessage = "No se pudo cargar el perfil"
            isLoading = false
        }
    }
    
    // MARK: - Load Profile Image
    
    private func loadProfileImageFromURL(_ urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.profileImage = image
                }
            }
        } catch {
            print("❌ Error loading profile image: \(error)")
        }
    }
    
    // MARK: - Upload Profile Photo
    
    private func uploadProfilePhoto(_ image: UIImage) async {
        isUploadingPhoto = true
        
        do {
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                print("❌ Could not convert image to JPEG")
                isUploadingPhoto = false
                return
            }
            
            print("📤 Uploading profile photo for user: \(currentUserId.uuidString)")
            
            let fileName = "\(currentUserId.uuidString)/profile.jpg"
            let bucket = "user_photo"
            
            // Upload to storage
            try await supabase.storage
                .from(bucket)
                .upload(
                    path: fileName,
                    file: imageData,
                    options: .init(contentType: "image/jpeg", upsert: true)
                )
            
            // Get public URL
            let publicURL = try supabase.storage
                .from(bucket)
                .getPublicURL(path: fileName)
            
            let urlString = publicURL.absoluteString
            print("✅ Profile photo uploaded to: \(urlString)")
            
            // Update user profile with new photo_url
            try await supabase
                .from("profiles")
                .update(["photo_url": urlString])
                .eq("id", value: currentUserId.uuidString)
                .execute()
            
            print("✅ User photo_url updated in database")
            
            // Update local state
            await MainActor.run {
                self.profileImage = image
            }
            
            isUploadingPhoto = false
        } catch {
            print("❌ Error uploading profile photo: \(error)")
            isUploadingPhoto = false
        }
    }
}
