import SwiftUI

struct ProducerSurveyView: View {

    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var registrationData = ProducerRegistrationData()

    @State private var showSuccessMessage = false
    @State private var successText = ""

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

    // --- ERRORES ---
    @State private var errors: [String: String] = [:]

    var body: some View {

        NavigationStack {

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {

                    Text("Registro de Productor")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)
                        .padding(.top, 12)

                    // MARK: SECCIONES
                    sectionCard("Datos personales", icon: "person.fill") {
                        validatedField("Nombre completo", text: $name, key: "name")
                        validatedPhoneField("Teléfono (10 dígitos)", text: $phone, key: "phone")
                        validatedEmailField("Correo electrónico", text: $email, key: "email")
                    }

                    sectionCard("Datos de la finca", icon: "leaf.fill") {
                        validatedField("Nombre de la marca / finca", text: $brand, key: "brand")
                        validatedNumberField("Tamaño de la finca (ha)", text: $farmSize, key: "farmSize")
                        validatedField("Ubicación", text: $location, key: "location")
                        validatedNumberField("Altura de cultivo (msnm)", text: $altitude, key: "altitude")
                        validatedField("Tipo de sombra", text: $shadeType, key: "shadeType")
                    }

                    sectionCard("Producción", icon: "drop.fill") {
                        validatedNumberField("Producción anual (kg)", text: $production, key: "production")
                        validatedField("Variedades", text: $varieties, key: "varieties")
                        validatedField("Procesos", text: $processes, key: "processes")
                        validatedField("Tipo de café", text: $coffeeType, key: "coffeeType")
                        validatedField("Última cosecha (mm/aaaa)", text: $harvestDate, key: "harvestDate")
                        validatedNumberField("Rendimiento (kg/ha)", text: $yield, key: "yield")
                    }

                    sectionCard("Comercial", icon: "cart.fill") {
                        validatedNumberField("Precio por kg (MXN)", text: $price, key: "price")
                        validatedField("¿A quién vendes?", text: $sellingTo, key: "sellingTo")
                        validatedNumberField("Volumen mínimo (kg)", text: $minVolume, key: "minVolume")
                        validatedYesNoField("¿Exportas? (sí/no)", text: $exportReady, key: "exportReady")
                        validatedYesNoField("¿Vendes en línea? (sí/no)", text: $onlineSales, key: "onlineSales")
                        formField("Necesidades", text: $needs)
                    }

                    sectionCard("Turismo", icon: "location.viewfinder") {
                        validatedYesNoField("Área de degustación (sí/no)", text: $hasTastingArea, key: "hasTastingArea")
                        validatedYesNoField("Acceso a turistas (sí/no)", text: $touristAccess, key: "touristAccess")
                    }

                    sectionCard("Certificaciones", icon: "checkmark.seal.fill") {
                        formField("Certificaciones", text: $certifications)
                    }

                    submitButton
                    successBanner

                }
                .padding(.horizontal, 22)
            }
            .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: VALIDACIONES
    func validate() -> Bool {
        errors.removeAll()

        let required: [(String, String)] = [
            ("name", name), ("phone", phone), ("email", email),
            ("brand", brand), ("farmSize", farmSize), ("location", location),
            ("altitude", altitude), ("shadeType", shadeType), ("production", production),
            ("varieties", varieties), ("processes", processes), ("coffeeType", coffeeType),
            ("harvestDate", harvestDate), ("yield", yield), ("price", price),
            ("sellingTo", sellingTo), ("minVolume", minVolume), ("exportReady", exportReady),
            ("onlineSales", onlineSales), ("hasTastingArea", hasTastingArea), ("touristAccess", touristAccess)
        ]

        for (key, value) in required {
            if value.trimmingCharacters(in: .whitespaces).isEmpty {
                errors[key] = "Este campo es obligatorio"
            }
        }

        if phone.count != 10 || Int(phone) == nil {
            errors["phone"] = "Debe tener 10 dígitos numéricos"
        }

        if !email.contains("@") || !email.contains(".") {
            errors["email"] = "Correo inválido"
        }

        let numeric = ["farmSize", "altitude", "production", "yield", "price", "minVolume"]
        for key in numeric {
            if Int(getValue(for: key)) == nil {
                errors[key] = "Debe ser un número"
            }
        }

        let yesNo = ["exportReady", "onlineSales", "hasTastingArea", "touristAccess"]
        for key in yesNo {
            let v = getValue(for: key).lowercased()
            if !(v == "sí" || v == "si" || v == "no") {
                errors[key] = "Debe ser sí o no"
            }
        }

        return errors.isEmpty
    }

    func getValue(for key: String) -> String {
        switch key {
        case "farmSize": return farmSize
        case "altitude": return altitude
        case "production": return production
        case "yield": return yield
        case "price": return price
        case "minVolume": return minVolume
        case "exportReady": return exportReady
        case "onlineSales": return onlineSales
        case "hasTastingArea": return hasTastingArea
        case "touristAccess": return touristAccess
        default: return ""
        }
    }

    // MARK: SUBMIT BUTTON

    var submitButton: some View {
        Button {
            if !validate() { return }

            withAnimation {
                successText = "Datos enviados correctamente"
                showSuccessMessage = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { showSuccessMessage = false }
            }

        } label: {
            Text("Enviar Registro")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(validate() ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight) : Color.gray)
                .cornerRadius(16)
        }
        .disabled(!validate())
        .padding(.vertical, 8)
    }

    // MARK: UI BUILDERS

    @ViewBuilder var successBanner: some View {
        if showSuccessMessage {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                Text(successText).foregroundColor(.white).bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.green)
            .cornerRadius(14)
        }
    }

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

    // ============================================================
    // MARK: ——— INPUT FIELDS (sin iconos)
    // ============================================================

    func formField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.footnote)
                .foregroundColor(theme.isDarkMode ? .white.opacity(0.7) : AppColors.textLight.opacity(0.7))

            Color.clear
                .unifiedTextField(
                    icon: "",        // 🔥 SIN ICONO
                    text: title,
                    value: text
                )
                .environmentObject(theme)
        }
    }

    func validatedField(_ title: String, text: Binding<String>, key: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            formField(title, text: text)
            if let err = errors[key] { Text(err).foregroundColor(.red).font(.caption) }
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
}

#Preview {
    ProducerSurveyView().environmentObject(AppThemeManager())
}
