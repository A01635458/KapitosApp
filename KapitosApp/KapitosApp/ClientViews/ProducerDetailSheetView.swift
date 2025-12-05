//
//  ProducerDetailSheetView.swift
//  KapitosApp
//
//  Created by GitHub Copilot on 04/12/25.
//

import SwiftUI
import MapKit

struct ProducerDetailSheetView: View {
    
    let producer: ProducerMapData
    let currentUserId: UUID
    @EnvironmentObject var theme: AppThemeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isCreatingConversation = false
    @State private var showChatView = false
    @State private var conversationId: UUID?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header with image
                    headerSection
                    
                    // Basic info
                    infoSection
                    
                    // Location
                    locationSection
                    
                    // Varieties and processes
                    if let varieties = producer.varieties, !varieties.isEmpty {
                        detailCard("Variedades", items: varieties, icon: "leaf.fill")
                    }
                    
                    if let processes = producer.processes, !processes.isEmpty {
                        detailCard("Procesos", items: processes, icon: "gearshape.fill")
                    }
                    
                    if let certifications = producer.certifications, !certifications.isEmpty {
                        detailCard("Certificaciones", items: certifications, icon: "checkmark.seal.fill")
                    }
                    
                    // Tourism info
                    if producer.has_tourist_area == true || producer.tourist_accessible == true {
                        tourismSection
                    }
                    
                    // Map preview
                    if let coordinate = producer.coordinate {
                        mapPreview(coordinate: coordinate)
                    }
                }
                .padding()
            }
            .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
            .navigationTitle(producer.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showChatView) {
                if let conversationId = conversationId {
                    NavigationStack {
                        ClientChatDetailView(
                            conversationId: conversationId,
                            currentUserId: currentUserId,
                            otherUserName: producer.displayName
                        )
                        .environmentObject(theme)
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            if let photoUrl = producer.photo_url, !photoUrl.isEmpty {
                AsyncImage(url: URL(string: photoUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        .frame(height: 200)
                    
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                Text(producer.displayName)
                    .font(.title2.bold())
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            }
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.gray)
                Text(producer.locationDescription)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            // Message Button
            Button(action: {
                Task {
                    await createConversationAndOpenChat()
                }
            }) {
                HStack {
                    if isCreatingConversation {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "message.fill")
                        Text("Enviar mensaje")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isCreatingConversation)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isDarkMode ? AppColors.cardDark : .white)
        .cornerRadius(16)
    }
    
    // MARK: - Location Section
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                Text("Ubicación")
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            }
            
            if let lat = producer.latitude, let lon = producer.longitude {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Coordenadas:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("Lat: \(lat, specifier: "%.6f")")
                            .font(.caption.monospacedDigit())
                        Text("Lon: \(lon, specifier: "%.6f")")
                            .font(.caption.monospacedDigit())
                    }
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isDarkMode ? AppColors.cardDark : .white)
        .cornerRadius(16)
    }
    
    // MARK: - Detail Card
    
    private func detailCard(_ title: String, items: [String], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                Text(title)
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            }
            
            FlowLayout(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.cardLight)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isDarkMode ? AppColors.cardDark : .white)
        .cornerRadius(16)
    }
    
    // MARK: - Tourism Section
    
    private var tourismSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                Text("Información Turística")
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            }
            
            if producer.has_tourist_area == true {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Área de degustación disponible")
                        .font(.body)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                }
            }
            
            if producer.tourist_accessible == true {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Accesible para turistas")
                        .font(.body)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isDarkMode ? AppColors.cardDark : .white)
        .cornerRadius(16)
    }
    
    // MARK: - Map Preview
    
    private func mapPreview(coordinate: CLLocationCoordinate2D) -> some View {
        Map(initialPosition: .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )) {
            Marker(producer.displayName, coordinate: coordinate)
        }
        .mapStyle(.standard(elevation: .realistic))
        .preferredColorScheme(theme.isDarkMode ? .dark : .light)
        .frame(height: 200)
        .cornerRadius(16)
        .disabled(true)
    }
    
    // MARK: - Helper Functions
    
    private func createConversationAndOpenChat() async {
        isCreatingConversation = true
        
        let messagingService = MessagingService(currentUserId: currentUserId)
        
        if let newConversationId = await messagingService.getOrCreateConversation(withUserId: producer.id) {
            conversationId = newConversationId
            showChatView = true
        }
        
        isCreatingConversation = false
    }
}

// MARK: - Flow Layout Helper

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    ProducerDetailSheetView(
        producer: ProducerMapData(
            id: UUID(),
            farm_name: "Finca El Triunfo",
            latitude: 15.1150,
            longitude: -92.0868,
            municipality: "Ángel Albino Corzo",
            state: "Chiapas",
            photo_url: nil,
            varieties: ["Typica", "Bourbon", "Caturra"],
            processes: ["Lavado", "Natural"],
            certifications: ["Comercio Justo", "Orgánico"],
            has_tourist_area: true,
            tourist_accessible: true,
            status: "approved"
        ),
        currentUserId: UUID()
    )
    .environmentObject(AppThemeManager())
}
