# Ejemplos de Uso - Sistema de IA

## 🎯 Casos de Uso Reales

### Caso 1: Usuario Nuevo se Registra

**Flujo**:
1. Usuario completa registro en `RegisterView`
2. Usuario configura preferencias en `RegisterPreferencesView`:
   - Procesos: Lavado, Natural
   - Notas: Cítrico, Dulce
   - Tueste: Medio
   - Consumo: 4-7 tazas/semana
3. Datos se guardan en `user_preferences` table
4. Usuario ingresa a `HomeView`
5. **Sistema automáticamente genera recomendaciones**:
   ```
   ✅ Loaded preferences for user abc123
   ✅ Loaded 45 producers from database
   ✅ Generated 5 recommendations (top score: 92)
   ```

**Resultado en UI**:
```
┌─────────────────────────────────────┐
│ ✨ Recomendados para Ti            │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [Foto] Café Don José            │ │
│ │        📍 Veracruz              │ │
│ │        ⭐ 92% compatible        │ │
│ │        Usa procesos que         │ │
│ │        prefieres: Natural       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [Foto] Finca Los Altos          │ │
│ │        📍 Chiapas               │ │
│ │        ⭐ 87% compatible        │ │
│ │        Compatible con notas:    │ │
│ │        Cítrico, Dulce           │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

### Caso 2: Nuevo Productor se Aprueba

**Escenario**:
- Admin aprueba productor "Café El Paraíso" en Oaxaca
- Productor usa proceso: Natural, Honey
- Tiene certificación: Orgánico

**Sistema detecta**:
```swift
// En SmartNotificationService.generateContextualNotifications()
// Se ejecuta checkNewMatchingProducers()

Usuario: María (preferences: [Natural, Honey])
Nuevo Productor: Café El Paraíso [Natural, Honey]
Match Score: 100% (2/2 procesos coinciden)

✅ Scheduled notification for new match: Café El Paraíso (100%)
```

**Notificación enviada**:
```
┌─────────────────────────────────────┐
│ 🌟 Nuevo Productor Compatible       │
│                                     │
│ Nuevo productor en Oaxaca con      │
│ proceso Natural que te encanta     │
│ (100% compatible)                  │
│                                     │
│ [Ver Perfil]  [Enviar Mensaje]     │
└─────────────────────────────────────┘
```

---

### Caso 3: Cosecha Próxima

**Datos en DB**:
```sql
-- Productor: Café Don José
last_harvest_date = '2024-12-10'
processes = ['Lavado', 'Natural']
farm_name = 'Café Don José'
```

**Sistema calcula**:
```swift
// Hoy: 2025-12-05
// Last harvest: 2024-12-10
// Next harvest: 2025-12-10 (last + 365 días)
// Days until: 5 días

// Está en ventana de 60-90 días? NO (demasiado cerca)
// Revisará en la próxima ejecución cuando falten 60-90 días
```

**Notificación se programará cuando falten 75 días**:
```
┌─────────────────────────────────────┐
│ ☕️ Próxima Cosecha                  │
│                                     │
│ La cosecha de Café Don José        │
│ (95% compatible) estará lista en   │
│ 75 días                            │
│                                     │
│ [Ver Perfil]  [Cerrar]             │
└─────────────────────────────────────┘
```

---

### Caso 4: Usuario Cerca de Tour

**Escenario**:
- Usuario activa ubicación
- Usuario está en CDMX (19.4326° N, 99.1332° W)
- Productor "Finca Vista Hermosa" en Estado de México
  - Location: (19.2500° N, 99.2000° W)
  - has_tourist_area: true
  - tourist_accessible: true
  - Distancia: ~15km

**Sistema detecta**:
```swift
// En SmartNotificationService.checkNearbyTours()

let userLocation = CLLocation(latitude: 19.4326, longitude: -99.1332)
let producerLocation = CLLocation(latitude: 19.2500, longitude: -99.2000)
let distanceKm = 15.2

// distanceKm <= 50km ✅
✅ Scheduled tour notification for Finca Vista Hermosa at 15km
```

**Notificación enviada**:
```
┌─────────────────────────────────────┐
│ 🗺️ Tour de Cafetal Cercano         │
│                                     │
│ Finca Vista Hermosa ofrece tours  │
│ de cafetales a solo 15km de ti     │
│                                     │
│ [Ver Perfil]  [Cerrar]             │
└─────────────────────────────────────┘
```

---

### Caso 5: Usuario Explora Detalles de Compatibilidad

**Acción**: Usuario hace long-press en RecommendedProducerCard

**UI Mostrada**:
```
┌─────────────────────────────────────┐
│ ¿Por qué recomendamos este          │
│ productor?                    [X]   │
│                                     │
│         92%                         │
│    Compatible contigo               │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Desglose de Compatibilidad      │ │
│ │                                 │ │
│ │ ❤️ Preferencias de café         │ │
│ │    35/40  ████████░░            │ │
│ │                                 │ │
│ │ 📍 Proximidad                   │ │
│ │    28/30  █████████░            │ │
│ │                                 │ │
│ │ 💬 Interacción previa           │ │
│ │    20/20  ██████████            │ │
│ │                                 │ │
│ │ 🗺️ Tours disponibles            │ │
│ │    10/10  ██████████            │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Razones principales             │ │
│ │                                 │ │
│ │ ✓ Usa procesos que prefieres:  │ │
│ │   Natural, Lavado               │ │
│ │                                 │ │
│ │ ✓ Compatible con tus notas:    │ │
│ │   Cítrico, Dulce                │ │
│ │                                 │ │
│ │ ✓ Ubicado en Veracruz           │ │
│ │                                 │ │
│ │ ✓ Ofrece tours y área de cata  │ │
│ │                                 │ │
│ │ ✓ Certificaciones: Orgánico    │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

## 🔧 Código de Ejemplo

### Generar Recomendaciones Manualmente

```swift
import SwiftUI

struct MyCustomView: View {
    @StateObject private var recommendationEngine = RecommendationEngine()
    let userId: UUID
    
    var body: some View {
        VStack {
            if recommendationEngine.isLoading {
                ProgressView("Generando recomendaciones...")
            } else {
                ForEach(recommendationEngine.recommendations) { rec in
                    Text("\(rec.producer.displayName): \(rec.scorePercentage)")
                }
            }
        }
        .task {
            await recommendationEngine.generateRecommendations(
                for: userId,
                userLocation: nil, // Opcional: pasar CLLocation
                limit: 10
            )
        }
    }
}
```

### Generar Notificaciones con Botón

```swift
struct TestNotificationsView: View {
    let userId: UUID
    
    var body: some View {
        Button("Generar Notificaciones") {
            Task {
                let service = SmartNotificationService.shared
                
                // Solicitar permisos si no están dados
                let granted = await service.requestNotificationPermission()
                
                if granted {
                    // Generar notificaciones
                    await service.generateContextualNotifications(userId: userId)
                    print("✅ Notificaciones programadas")
                }
            }
        }
    }
}
```

### Acceder a Top Match Directo

```swift
struct QuickMatchView: View {
    @StateObject private var engine = RecommendationEngine()
    let userId: UUID
    
    var body: some View {
        VStack {
            if let topMatch = engine.recommendations.first {
                Text("Tu mejor match:")
                Text(topMatch.producer.displayName)
                Text(topMatch.scorePercentage)
                Text(topMatch.primaryReason)
            }
        }
        .task {
            // Obtener solo el top match
            await engine.generateRecommendations(for: userId, limit: 1)
        }
    }
}
```

---

## 📊 Logs de Debug

### Logs Esperados en Consola

**Al cargar recomendaciones**:
```
✅ Loaded preferences for user 3ba73474-dc62-4c5a-86a3-d70069097d17
✅ Loaded 45 producers from database
✅ Generated 5 recommendations (top score: 92.5)
```

**Al generar notificaciones**:
```
✅ Scheduled notification for new match: Café El Paraíso (100%)
✅ Scheduled harvest alert for Finca Los Altos in 75 days
✅ Scheduled tour notification for Vista Hermosa at 15km
✅ Scheduled notification: new-match-abc-123
✅ Scheduled notification: harvest-def-456
✅ Scheduled notification: tour-ghi-789
```

**Al detectar permisos**:
```
✅ Notification permission granted
📍 Location permission status: 3
```

---

## 🎨 Personalización

### Ajustar Umbral de Score

En `RecommendationEngine.swift`:

```swift
// Cambiar de 60% a 80% para notificaciones más selectivas
if matchScore >= 80 { // Era 60
    // Enviar notificación
}
```

### Modificar Scoring Weights

En `calculateScore()`:

```swift
// Dar más peso a proximidad (de 30 a 40)
let proximityScore = calculateProximityScore(...) * 1.33 // 30→40
let preferenceScore = calculatePreferenceMatch(...) * 0.75 // 40→30
```

### Agregar Nuevas Razones

En `generateReasons()`:

```swift
// Agregar bonus por precio competitivo
if let price = producer.price_per_kg, price < 150 {
    reasons.append("Precio competitivo: $\(Int(price))/kg")
}

// Agregar bonus por producción grande
if let production = producer.annual_production_kg, production > 5000 {
    reasons.append("Gran productor (\(production)kg/año)")
}
```

---

## ✅ Checklist de Testing

- [ ] Crear usuario con preferencias configuradas
- [ ] Ver "Recomendados para Ti" en HomeView
- [ ] Tocar una recomendación para ver perfil
- [ ] Long-press para ver detalles de compatibilidad
- [ ] Navegar a Perfil → Notificaciones Inteligentes
- [ ] Solicitar permisos de notificaciones
- [ ] Solicitar permisos de ubicación
- [ ] Activar/desactivar tipos de notificaciones
- [ ] Ajustar radio de búsqueda
- [ ] Presionar "Generar Notificaciones Ahora"
- [ ] Minimizar app y recibir notificaciones
- [ ] Tocar notificación para ver acciones
- [ ] Verificar que no hay errores en consola

---

¡El sistema está listo para usar! 🚀☕️
