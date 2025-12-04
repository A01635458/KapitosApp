# 🎯 Guía Rápida de Uso - Selector de Ubicación

## Para Desarrolladores

### Importar el Componente

```swift
import SwiftUI
import MapKit
```

### Uso Básico

```swift
struct MyView: View {
    @State private var showLocationPicker = false
    @State private var selectedLocation: LocationData?
    @EnvironmentObject var theme: AppThemeManager
    
    var body: some View {
        Button("Seleccionar Ubicación") {
            showLocationPicker = true
        }
        .sheet(isPresented: $showLocationPicker) {
            MapLocationPickerView { locationData in
                selectedLocation = locationData
                // Usar:
                // locationData.coordinate.latitude
                // locationData.coordinate.longitude
                // locationData.address
            }
            .environmentObject(theme)
        }
    }
}
```

### Integración con Formulario

```swift
struct FormView: View {
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var address: String = ""
    @State private var showPicker = false
    
    var body: some View {
        Form {
            // Botón para abrir selector
            Button(action: { showPicker = true }) {
                HStack {
                    Image(systemName: "map.fill")
                    if address.isEmpty {
                        Text("Seleccionar ubicación")
                            .foregroundColor(.gray)
                    } else {
                        VStack(alignment: .leading) {
                            Text(address)
                            Text("Lat: \(latitude ?? 0, specifier: "%.6f")")
                                .font(.caption)
                        }
                    }
                }
            }
            
            // Submit button
            Button("Guardar") {
                saveData()
            }
            .disabled(latitude == nil)
        }
        .sheet(isPresented: $showPicker) {
            MapLocationPickerView { location in
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                address = location.address
            }
            .environmentObject(theme)
        }
    }
}
```

### Validación de Ubicación

```swift
func validateLocation() -> Bool {
    guard let lat = latitude, let lon = longitude else {
        errors["location"] = "Debe seleccionar una ubicación"
        return false
    }
    
    // Validar que esté en México
    let inMexico = lat >= 14.5 && lat <= 32.7 &&
                   lon >= -118.4 && lon <= -86.7
    
    if !inMexico {
        errors["location"] = "La ubicación debe estar en México"
        return false
    }
    
    return true
}
```

## Para Usuarios (Productores)

### Paso a Paso

#### 1️⃣ Abrir Selector
- En el formulario de registro, sección "Datos de la finca"
- Toca el botón "Seleccionar en el mapa"

#### 2️⃣ Buscar Ubicación
- Escribe el nombre de tu finca o ubicación
- Aparecerán resultados mientras escribes
- Ejemplos:
  - "Coatepec, Veracruz"
  - "Finca El Triunfo"
  - "Pluma Hidalgo, Oaxaca"

#### 3️⃣ Seleccionar Resultado
- Toca el resultado que más se acerque
- El mapa se moverá a esa ubicación
- Verás un pin en el centro del mapa

#### 4️⃣ Ajustar Posición
- Mueve el mapa con el dedo (arrastra)
- El pin permanece fijo en el centro
- Coloca tu finca exactamente bajo el pin
- Puedes hacer zoom con pellizco

#### 5️⃣ Verificar Información
- Revisa la dirección mostrada
- Verifica las coordenadas (Lat/Lon)
- Asegúrate que sea la ubicación correcta

#### 6️⃣ Confirmar
- Toca el botón "Confirmar Ubicación"
- Regresarás al formulario
- La ubicación quedará guardada

### Consejos de Uso

✅ **Hacer:**
- Buscar primero con nombre de municipio
- Hacer zoom para mayor precisión
- Verificar coordenadas antes de confirmar
- Usar nombres oficiales de lugares

❌ **Evitar:**
- No buscar por coordenadas directamente
- No confirmar sin verificar
- No usar nombres genéricos ("mi finca")

### Ejemplos de Búsqueda

**Búsquedas Efectivas:**
- ✅ "Coatepec, Veracruz"
- ✅ "Tapachula, Chiapas"
- ✅ "Pluma Hidalgo"
- ✅ "Huatusco"

**Búsquedas Menos Efectivas:**
- ⚠️ "Mi finca"
- ⚠️ "Cerca del pueblo"
- ⚠️ "Zona cafetalera"

## FAQ - Preguntas Frecuentes

### ¿Necesito estar en mi finca para registrarla?
No. Puedes buscar y seleccionar tu finca desde cualquier lugar con internet.

### ¿Qué tan preciso debe ser?
Lo más preciso posible. La ubicación se usa para mostrar tu finca en el mapa y calcular distancias.

### ¿Puedo cambiar la ubicación después?
Sí, puedes editar tu perfil y actualizar la ubicación en cualquier momento.

### ¿Por qué no encuentra mi finca?
- Intenta buscar por el municipio o poblado más cercano
- Usa el mapa para navegar manualmente
- Verifica que escribiste el nombre correctamente

### ¿Se guarda mi ubicación GPS actual?
No. Solo guardas la ubicación que selecciones manualmente en el mapa.

### ¿Necesito activar ubicación en mi teléfono?
No es necesario. La app no usa tu ubicación actual.

### ¿Qué pasa si me equivoco?
Puedes volver a abrir el selector y cambiar la ubicación antes de enviar el formulario.

## Casos de Uso Especiales

### Fincas sin Dirección Formal

Si tu finca no tiene dirección:
1. Busca el pueblo o municipio más cercano
2. Navega manualmente en el mapa
3. Usa referencias geográficas conocidas
4. Confirma las coordenadas

### Múltiples Parcelas

Si tienes varias parcelas:
- Registra la parcela principal
- Puedes agregar otras ubicaciones posteriormente
- Usa la más representativa o la más grande

### Zonas Remotas

Para fincas muy alejadas:
1. Busca el poblado más cercano
2. Haz zoom out para ver área mayor
3. Navega manualmente hasta tu finca
4. Usa puntos de referencia (ríos, montañas, caminos)

## Soporte Técnico

### Problemas Comunes

**"No aparecen resultados de búsqueda"**
- Verifica tu conexión a internet
- Intenta con un nombre más general
- Navega manualmente en el mapa

**"El mapa no se mueve"**
- Asegúrate de arrastrar el mapa, no el pin
- El pin siempre está en el centro
- Usa gestos normales de mapa (arrastre, zoom)

**"La dirección es incorrecta"**
- La dirección es aproximada
- Las coordenadas son lo más importante
- Puedes ver las coordenadas exactas abajo

**"No puedo confirmar"**
- Espera a que cargue la dirección
- Verifica que el botón esté habilitado
- Asegúrate de haber seleccionado una ubicación

### Contacto

Para problemas técnicos:
- Email: soporte@larutadelcafe.mx
- WhatsApp: [Tu número]
- App: Menú > Ayuda > Contactar Soporte

## Changelog

### Versión 1.0 (Diciembre 2025)
- ✨ Lanzamiento inicial
- 🗺️ Búsqueda de ubicaciones en México
- 📍 Selector interactivo de coordenadas
- 💾 Guardado de lat/lon en base de datos
- 🎨 Soporte para tema claro/oscuro

---

**Desarrollado por:** Equipo KapitosApp  
**Última actualización:** 4 de diciembre, 2025
