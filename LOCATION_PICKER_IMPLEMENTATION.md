# Selector de Ubicación para Registro de Productores

## 📍 Implementación Completa

Se ha implementado exitosamente un selector de ubicación interactivo con MapKit para el registro de productores cafetaleros en "La Ruta del Café".

## 🗂️ Archivos Creados

### 1. **LocationPickerViewModel.swift**
- Maneja la lógica de búsqueda de ubicaciones
- Integración con `MKLocalSearch` para búsqueda en México
- Geocodificación inversa para obtener direcciones
- Gestión del estado del mapa y coordenadas

### 2. **MapLocationPickerView.swift**
- Vista completa del selector de ubicación
- Campo de búsqueda con resultados en tiempo real
- Mapa interactivo con pin central fijo
- Información de coordenadas y dirección
- Botón de confirmación

### 3. **add_location_coordinates.sql**
- Script SQL para agregar campos `latitude` y `longitude` a la tabla `producers`
- Restricciones de rango para coordenadas válidas
- Índice para consultas espaciales

## 📝 Archivos Modificados

### 1. **ProducerFormModel.swift**
Agregados campos:
```swift
let latitude: Double?
let longitude: Double?
let locationAddress: String?
```

### 2. **ProducerInsertDTO.swift**
Agregados campos para la base de datos:
```swift
let latitude: Double?
let longitude: Double?
```

### 3. **ProducerRegistrationData.swift**
- Actualizado para incluir coordenadas en el DTO
- Usa `locationAddress` si está disponible, sino usa `location`

### 4. **ProducerSurveyView.swift**
- Agregado botón de selección de ubicación en la sección "Datos de la finca"
- Estados para `latitude`, `longitude`, `locationAddress`
- Validación de coordenadas obligatorias
- Sheet modal para `MapLocationPickerView`
- Actualizado el submit para incluir los nuevos campos

## 🚀 Cómo Funciona

### Flujo de Usuario:

1. **Búsqueda Inicial**
   - El productor escribe el nombre de su finca o ubicación
   - Aparecen resultados de búsqueda en tiempo real
   - Limitado a ubicaciones en México

2. **Selección de Resultado**
   - Al tocar un resultado, el mapa se centra en esa ubicación
   - Se muestra un pin fijo en el centro del mapa

3. **Ajuste Preciso**
   - El productor puede mover/arrastrar el mapa
   - El pin permanece en el centro
   - La dirección se actualiza automáticamente

4. **Confirmación**
   - Se muestran las coordenadas exactas (lat/lon)
   - Al confirmar, se guardan:
     - `latitude`: Latitud decimal
     - `longitude`: Longitud decimal  
     - `locationAddress`: Dirección formateada

5. **Validación**
   - El formulario requiere que se seleccione una ubicación
   - No se puede enviar sin coordenadas válidas

## 📦 Base de Datos

### Ejecutar Migración:

Conecta a tu base de datos Supabase y ejecuta:

```sql
-- En el SQL Editor de Supabase
ALTER TABLE public.producers
ADD COLUMN IF NOT EXISTS latitude numeric,
ADD COLUMN IF NOT EXISTS longitude numeric;

ALTER TABLE public.producers
ADD CONSTRAINT latitude_range CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90));

ALTER TABLE public.producers
ADD CONSTRAINT longitude_range CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180));

CREATE INDEX IF NOT EXISTS idx_producers_coordinates ON public.producers(latitude, longitude);
```

O importa el archivo `add_location_coordinates.sql` en tu proyecto Supabase.

## 🎨 Interfaz de Usuario

### Características:
- ✅ Campo de búsqueda con autocompletado
- ✅ Lista de resultados con iconos y direcciones
- ✅ Mapa interactivo estilo estándar
- ✅ Pin central fijo que no se mueve
- ✅ Indicador de "mueve el mapa para ajustar"
- ✅ Tarjeta de información con dirección y coordenadas
- ✅ Botón de confirmación destacado
- ✅ Soporte para temas claro/oscuro
- ✅ Animaciones y transiciones suaves

### Diseño:
- Usa los colores del tema de la app (`AppColors`)
- Integrado con `AppThemeManager` para dark mode
- Presentado como sheet modal
- UI consistente con el resto de la app

## 🔧 Integración en ProducerSurveyView

El campo de ubicación ahora es un botón que abre el selector:

```swift
// Antes
validatedField("Ubicación", text: $location, key: "location")

// Ahora
locationPickerField  // Botón que abre MapLocationPickerView
```

## 📱 Uso

### Para el Usuario (Productor):
1. En el formulario de registro, en la sección "Datos de la finca"
2. Toca el botón "Seleccionar en el mapa"
3. Busca tu finca escribiendo el nombre o ubicación
4. Selecciona el resultado más cercano
5. Ajusta la posición moviendo el mapa
6. Confirma cuando el pin esté en la ubicación exacta
7. Continúa con el resto del formulario

### Para el Desarrollador:
```swift
// El componente es reutilizable
MapLocationPickerView { locationData in
    // locationData.coordinate.latitude
    // locationData.coordinate.longitude
    // locationData.address
}
.environmentObject(theme)
```

## 🌟 Características Técnicas

- **MKLocalSearch**: Búsqueda nativa de Apple Maps
- **Geocodificación Inversa**: Conversión de coordenadas a direcciones
- **Región México**: Búsqueda limitada a coordenadas mexicanas
- **Async/Await**: Uso de Swift Concurrency moderno
- **@MainActor**: Actualizaciones seguras de UI
- **Debouncing**: Optimización de búsquedas en tiempo real
- **Task Cancellation**: Cancelación de búsquedas anteriores
- **MapKit SwiftUI**: Uso de Map() moderno de iOS 17+

## ⚠️ Requisitos

- iOS 17.0+
- Xcode 15+
- Permisos de ubicación NO requeridos (búsqueda solamente)
- Conexión a internet para búsquedas

## 🔐 Privacidad

- No se usa la ubicación actual del dispositivo
- No se requieren permisos de ubicación
- El productor busca y selecciona manualmente
- Ideal para registrar desde cualquier lugar

## 🐛 Notas

- La búsqueda está optimizada para México
- Los resultados incluyen direcciones, POIs y municipios
- El formato de coordenadas es decimal (WGS84)
- La precisión es de 6 decimales (~0.1 metros)

## 📊 Próximos Pasos

Para usar las coordenadas guardadas:
1. Mostrar fincas en un mapa (MapView existente)
2. Calcular distancias entre usuario y fincas
3. Filtrar fincas por región geográfica
4. Crear rutas de café (coffee tours)
5. Análisis geoespacial de producción

## ✅ Testing

Para probar:
1. Ejecuta el SQL en Supabase
2. Compila la app en Xcode
3. Ve a la vista de registro de productor
4. Selecciona ubicación en el mapa
5. Completa y envía el formulario
6. Verifica en Supabase que se guardaron lat/lon

---

**Fecha:** 4 de diciembre, 2025  
**Proyecto:** La Ruta del Café - KapitosApp
