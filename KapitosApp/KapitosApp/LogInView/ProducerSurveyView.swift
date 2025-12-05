import SwiftUI
import MapKit

struct ProducerSurveyView: View {

    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var registrationData = ProducerRegistrationData()

    @State private var showSuccessMessage = false
    @State private var successText = ""

    @State private var goToSuccess = false   // ⭐ NUEVO

    // --- DATOS PERSONALES ---
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var experienceYears = 5

    // --- FINCA ---
    @State private var brand = ""
    @State private var farmSize = 5
    @State private var location = ""
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    @State private var locationAddress: String? = nil
    @State private var showLocationPicker = false
    @State private var altitude = 1200
    @State private var shadeCoverage = 50
    @State private var extractedState: String? = nil
    @State private var extractedMunicipality: String? = nil

    // --- PRODUCCIÓN ---
    @State private var production = 1000
    @State private var selectedVarieties: Set<String> = []
    @State private var selectedProcesses: Set<String> = []
    @State private var harvestMonth = 12
    @State private var harvestYear = 2024
    @State private var yieldPerHa = 500

    // --- COMERCIAL ---
    @State private var price = 100
    @State private var selectedSalesTypes: Set<String> = []
    @State private var minVolume = 50
    @State private var exportReady = false
    @State private var onlineSales = false

    // --- TURISMO ---
    @State private var hasTastingArea = false
    @State private var touristAccess = false

    // --- CERTIFICACIONES ---
    @State private var selectedCertifications: Set<String> = []
    
    // --- CONSENTIMIENTOS ---
    @State private var consentGPS = true
    @State private var consentAI = true
    @State private var consentNotifications = true

    // --- ERRORES ---
    @State private var errors: [String: String] = [:]

    // Opciones disponibles
    let varieties = ["Typica", "Bourbon", "Caturra", "Catuaí", "Mundo Novo", "Maragogipe", "Garnica", "Geisha", "Arábica", "Robusta"]
    let processes = ["Lavado", "Honey", "Natural"]
    let salesTypes = ["Exportación", "Mayoreo Nacional (>1000kg)", "Medio Mayoreo (100-1000kg)", "Menudeo (directo)", "Tours/Turismo"]
    let certifications = ["USDA Organic", "Rainforest Alliance", "Fair Trade", "UTZ Certified", "4C", "Orgánico CERTIMEX", "Bird Friendly", "Smithsonian Migratory Bird Center"]
    
    var isFormEligible: Bool {
        return !name.isEmpty &&
               !phone.isEmpty &&
               !email.isEmpty &&
               !brand.isEmpty &&
               !location.isEmpty &&
               latitude != nil &&
               longitude != nil
    }

    var body: some View {

        NavigationStack {

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {

                    // ⭐ REDIRECCIÓN A SUCCESS VIEW
                    NavigationLink("", destination: ProducerSuccessView(), isActive: $goToSuccess)
                        .hidden()

                    Text("Registro de Productor")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                        .padding(.top, 12)

                    // MARK: SECCIONES
                    sectionCard("Datos personales", icon: "person.fill") {
                        imagePickerField
                        validatedField("Nombre completo", text: $name, key: "name")
                        validatedPhoneField("Teléfono (10 dígitos)", text: $phone, key: "phone")
                        validatedEmailField("Correo electrónico", text: $email, key: "email")
                        pickerField("Años de experiencia", value: $experienceYears, range: 1...50, key: "experience")
                    }

                    sectionCard("Datos de la finca", icon: "leaf.fill") {
                        validatedField("Nombre de la marca / finca", text: $brand, key: "brand")
                        pickerField("Tamaño de la finca (ha)", value: $farmSize, range: 1...100, key: "farmSize")
                        locationPickerField
                        pickerField("Altura de cultivo (msnm)", value: $altitude, range: 400...2500, step: 100, key: "altitude")
                        pickerField("Porcentaje de sombra (%)", value: $shadeCoverage, range: 0...100, step: 10, key: "shadeCoverage")
                    }

                    sectionCard("Producción", icon: "drop.fill") {
                        pickerField("Producción anual (kg)", value: $production, range: 100...50000, step: 100, key: "production")
                        multipleCheckboxField("Variedades", options: varieties, selected: $selectedVarieties)
                        multipleCheckboxField("Procesos", options: processes, selected: $selectedProcesses)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Última cosecha")
                                .font(.footnote.bold())
                                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Mes")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Picker("Mes", selection: $harvestMonth) {
                                        ForEach(1...12, id: \.self) { month in
                                            Text(monthName(month)).tag(month)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 100)
                                    .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.cardLight)
                                    .cornerRadius(12)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Año")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Picker("Año", selection: $harvestYear) {
                                        ForEach(2020...2025, id: \.self) { year in
                                            Text("\(year)").tag(year)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 100)
                                    .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.cardLight)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        pickerField("Rendimiento (kg/ha)", value: $yieldPerHa, range: 100...5000, step: 50, key: "yieldPerHa")
                    }

                    sectionCard("Comercial", icon: "cart.fill") {
                        pickerField("Precio por kg (MXN)", value: $price, range: 50...500, step: 10, key: "price")
                        multipleCheckboxField("Tipos de venta", options: salesTypes, selected: $selectedSalesTypes)
                        pickerField("Volumen mínimo (kg)", value: $minVolume, range: 10...1000, step: 10, key: "minVolume")
                        toggleField("¿Exportas?", isOn: $exportReady)
                        toggleField("¿Vendes en línea?", isOn: $onlineSales)
                    }

                    sectionCard("Turismo", icon: "location.viewfinder") {
                        toggleField("Área de degustación", isOn: $hasTastingArea)
                        toggleField("Acceso a turistas", isOn: $touristAccess)
                    }

                    sectionCard("Certificaciones", icon: "checkmark.seal.fill") {
                        multipleCheckboxField("Certificaciones", options: certifications, selected: $selectedCertifications)
                    }
                    
                    sectionCard("Consentimientos", icon: "hand.raised.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Para mejorar tu experiencia en la plataforma")
                                .font(.caption)
                                .foregroundColor(theme.isDarkMode ? .white.opacity(0.6) : AppColors.textLight.opacity(0.6))
                            
                            toggleField("Compartir ubicación GPS en el mapa", isOn: $consentGPS)
                            toggleField("Usar IA para análisis de calidad del café", isOn: $consentAI)
                            toggleField("Recibir notificaciones de clientes", isOn: $consentNotifications)
                        }
                    }

                    submitButton
                }
                .padding(.horizontal, 22)
            }
            .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
            .scrollContentBackground(.hidden)
        }
        .sheet(isPresented: $showLocationPicker) {
            MapLocationPickerView { locationData in
                latitude = locationData.coordinate.latitude
                longitude = locationData.coordinate.longitude
                locationAddress = locationData.address
                location = locationData.address
                extractedState = locationData.state
                extractedMunicipality = locationData.municipality
            }
            .environmentObject(theme)
        }
    }

    // MARK: VALIDACIONES
    func validate() -> Bool {
        errors.removeAll()

        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            errors["name"] = "Este campo es obligatorio"
        }
        
        if phone.count != 10 || Int(phone) == nil {
            errors["phone"] = "Debe tener 10 dígitos numéricos"
        }

        if !email.contains("@") || !email.contains(".") {
            errors["email"] = "Correo inválido"
        }
        
        if brand.trimmingCharacters(in: .whitespaces).isEmpty {
            errors["brand"] = "Este campo es obligatorio"
        }

        if latitude == nil || longitude == nil {
            errors["location"] = "Debe seleccionar ubicación en el mapa"
        }

        return errors.isEmpty
    }

    // MARK: SUBMIT BUTTON

    var submitButton: some View {
        Button {
            if !validate() { return }

            Task {
                let form = ProducerFormModel(
                    name: name,
                    phone: phone,
                    email: email,
                    profileImage: selectedImage,
                    experienceYears: String(experienceYears),
                    brand: brand,
                    farmSize: String(farmSize),
                    location: location,
                    latitude: latitude,
                    longitude: longitude,
                    locationAddress: locationAddress,
                    state: extractedState,
                    municipality: extractedMunicipality,
                    altitude: String(altitude),
                    shadeCoverage: String(shadeCoverage),
                    production: String(production),
                    varieties: Array(selectedVarieties).joined(separator: ", "),
                    processes: Array(selectedProcesses).joined(separator: ", "),
                    harvestMonth: harvestMonth,
                    harvestYear: harvestYear,
                    yield: String(yieldPerHa),
                    price: String(price),
                    salesTypes: Array(selectedSalesTypes).joined(separator: ", "),
                    minVolume: String(minVolume),
                    exportReady: exportReady ? "Sí" : "No",
                    onlineSales: onlineSales ? "Sí" : "No",
                    hasTastingArea: hasTastingArea ? "Sí" : "No",
                    touristAccess: touristAccess ? "Sí" : "No",
                    certifications: Array(selectedCertifications).joined(separator: ", "),
                    consentGPS: consentGPS,
                    consentAI: consentAI,
                    consentNotifications: consentNotifications
                )

                await registrationData.submitProducer(form: form)

                if registrationData.submitMessage != nil {
                    goToSuccess = true   // ⭐ REDIRECCIÓN FINAL
                }
            }

        } label: {
            if registrationData.isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Enviar Registro")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isFormEligible ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight) : Color.gray)
        .cornerRadius(16)
        .disabled(!isFormEligible || registrationData.isLoading)
        .padding(.vertical, 8)
    }

    // MARK: UI BUILDERS (SE MANTIENE IGUAL)

    func sectionCard(_ title: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.textLight)
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            }

            VStack(spacing: 14) { content() }
                .padding(16)
                .background(
                    theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight
                )
                .cornerRadius(16)
        }
    }

    func formField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.footnote)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))

            Color.clear
                .unifiedTextField(
                    icon: "",
                    text: title,
                    value: text
                )
                .environmentObject(theme)
        }
    }

    func validatedField(_ title: String, text: Binding<String>, key: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            formField(title, text: text)
            if let err = errors[key] {
                Text(err)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }

    func validatedNumberField(_ title: String, text: Binding<String>, key: String) -> some View {
        validatedField(title, text: text, key: key)
    }

    func validatedPhoneField(_ title: String, text: Binding<String>, key: String) -> some View {
        validatedField(title, text: text, key: key)
    }

    func validatedEmailField(_ title: String, text: Binding<String>, key: String) -> some View {
        validatedField(title, text: text, key: key)
    }

    func validatedYesNoField(_ title: String, text: Binding<String>, key: String) -> some View {
        validatedField(title, text: text, key: key)
    }
    
    // MARK: - NUEVOS COMPONENTES UI
    
    func pickerField(_ title: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int = 1, key: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))
            
            Picker(title, selection: value) {
                ForEach(Array(stride(from: range.lowerBound, through: range.upperBound, by: step)), id: \.self) { num in
                    Text("\(num)").tag(num)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.cardLight)
            .cornerRadius(12)
        }
    }
    
    func multipleCheckboxField(_ title: String, options: [String], selected: Binding<Set<String>>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.footnote.bold())
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(options, id: \.self) { option in
                    Button {
                        if selected.wrappedValue.contains(option) {
                            selected.wrappedValue.remove(option)
                        } else {
                            selected.wrappedValue.insert(option)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: selected.wrappedValue.contains(option) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selected.wrappedValue.contains(option) 
                                    ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                    : .gray)
                            
                            Text(option)
                                .font(.caption)
                                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selected.wrappedValue.contains(option)
                                    ? (theme.isDarkMode ? AppColors.accentDark.opacity(0.2) : AppColors.accentLight.opacity(0.2))
                                    : (theme.isDarkMode ? AppColors.backgroundDark : Color.white))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selected.wrappedValue.contains(option)
                                            ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                            : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    func toggleField(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
        }
        .padding(12)
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.cardLight)
        .cornerRadius(12)
    }
    
    var imagePickerField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Logo / Foto del Productor")
                .font(.footnote.bold())
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.8) : AppColors.textLight.opacity(0.8))
            
            Button {
                showImagePicker = true
            } label: {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight, lineWidth: 2)
                        )
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("Toca para seleccionar")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 120, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.isDarkMode ? AppColors.backgroundDark : Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                            )
                    )
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }

    var locationPickerField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ubicación de la finca")
                .font(.footnote)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))

            Button(action: {
                showLocationPicker = true
            }) {
                HStack {
                    Image(systemName: "map.fill")
                        .foregroundColor(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)

                    if location.isEmpty {
                        Text("Seleccionar en el mapa")
                            .foregroundColor(.gray)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location)
                                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                                .lineLimit(2)

                            if let lat = latitude, let lon = longitude {
                                Text("Lat: \(String(format: "%.6f", lat)), Lon: \(String(format: "%.6f", lon))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(14)
                .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.cardLight)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(errors["location"] != nil ? Color.red : Color.clear, lineWidth: 1)
                )
            }

            if let err = errors["location"] {
                Text(err)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Helpers
    
    func monthName(_ month: Int) -> String {
        let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                     "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
        return months[month - 1]
    }
}

#Preview {
    ProducerSurveyView().environmentObject(AppThemeManager())
}
