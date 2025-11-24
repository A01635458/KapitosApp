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

    var body: some View {

        NavigationStack {

            ScrollView {
                VStack(alignment: .leading, spacing: 26) {

                    Text("Registro de Productor")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.top, 12)

                    // Secciones…
                    sectionCard("Datos personales", icon: "person.fill") {
                        formField("Nombre completo", text: $name)
                        formField("Teléfono", text: $phone)
                        formField("Correo electrónico", text: $email)
                    }

                    sectionCard("Datos de la finca", icon: "leaf.fill") {
                        formField("Nombre de la marca / finca", text: $brand)
                        formField("Tamaño de la finca (ha)", text: $farmSize)
                        formField("Ubicación (opcional)", text: $location)
                        formField("Altura de cultivo (msnm)", text: $altitude)
                        formField("Tipo de sombra", text: $shadeType)
                    }

                    sectionCard("Producción", icon: "drop.fill") {
                        formField("Producción anual (kg)", text: $production)
                        formField("Variedades", text: $varieties)
                        formField("Procesos", text: $processes)
                        formField("Tipo de café", text: $coffeeType)
                        formField("Última cosecha (mm/aaaa)", text: $harvestDate)
                        formField("Rendimiento (kg/ha)", text: $yield)
                    }

                    sectionCard("Comercial", icon: "cart.fill") {
                        formField("Precio por kg (MXN)", text: $price)
                        formField("¿A quién vendes?", text: $sellingTo)
                        formField("Volumen mínimo (kg)", text: $minVolume)
                        formField("¿Exportas? (sí/no)", text: $exportReady)
                        formField("¿Vendes en línea? (sí/no)", text: $onlineSales)
                        formField("Necesidades", text: $needs)
                    }

                    sectionCard("Turismo", icon: "location.viewfinder") {
                        formField("Área de degustación (sí/no)", text: $hasTastingArea)
                        formField("Acceso a turistas (sí/no)", text: $touristAccess)
                    }

                    sectionCard("Certificaciones", icon: "checkmark.seal.fill") {
                        formField("Certificaciones", text: $certifications)
                    }

                    submitButton
                    successBanner

                    Spacer()
                }
                .padding(.horizontal, 22)
            }
        }
    }

    // MARK: - SUBMIT BUTTON

    var submitButton: some View {
        Button {
            Task {
                do {
                    let form = ProducerFormModel(
                        name: name, phone: phone, email: email,
                        brand: brand, farmSize: farmSize, location: location,
                        altitude: altitude, shadeType: shadeType,
                        production: production, varieties: varieties,
                        processes: processes, coffeeType: coffeeType,
                        harvestDate: harvestDate, yield: yield,
                        price: price, sellingTo: sellingTo,
                        minVolume: minVolume, exportReady: exportReady,
                        onlineSales: onlineSales, needs: needs,
                        hasTastingArea: hasTastingArea, touristAccess: touristAccess,
                        certifications: certifications
                    )

                    try await registrationData.submitProducer(form: form)

                    withAnimation {
                        successText = "Datos enviados ✔️"
                        showSuccessMessage = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { showSuccessMessage = false }
                    }

                } catch {
                    withAnimation {
                        successText = "Error al enviar ❌"
                        showSuccessMessage = true
                    }
                }
            }
        } label: {
            Text("Enviar Registro")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(16)
        }
        .padding(.vertical, 8)
    }

    // MARK: - SUCCESS BANNER

    @ViewBuilder var successBanner: some View {
        if showSuccessMessage {
            HStack(spacing: 12) {
                Image(systemName: successText.contains("Error") ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.title2)

                Text(successText)
                    .foregroundColor(.white)
                    .font(.body.bold())
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(successText.contains("Error") ? Color.red : Color.green)
            .cornerRadius(14)
            .padding(.top, 4)
            .transition(.move(edge: .top).combined(with: .opacity))
        } else {
            EmptyView()
        }
    }

    // MARK: - UI HELPERS

    func sectionCard(_ title: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(title).font(.title3.bold())
            }
            VStack(spacing: 14) { content() }
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
        }
    }

    func formField(_ placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(placeholder).font(.footnote).foregroundColor(.gray)
            TextField(placeholder, text: text)
                .padding()
                .background(Color.gray.opacity(0.15))
                .cornerRadius(12)
        }
    }
}

#Preview {
    ProducerSurveyView().environmentObject(AppThemeManager())
}

