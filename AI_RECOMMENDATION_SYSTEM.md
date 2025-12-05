# Sistema de Recomendaciones Inteligentes + Notificaciones Contextuales

## 🎯 Descripción

Sistema de IA integrado con Apple Foundation Models que proporciona:
1. **Recomendaciones personalizadas** de productores basadas en preferencias del usuario
2. **Notificaciones contextuales inteligentes** sobre nuevos productores, cosechas, y tours cercanos

---

## 📦 Componentes Implementados

### Modelos de Datos
- **`UserPreferences.swift`** - Modelo para preferencias del usuario (processes, roasts, drinks, acidity, flavor_notes)
- **`RecommendationScore.swift`** - Modelo para puntuación de compatibilidad con desglose

### Servicios
- **`UserPreferencesService.swift`** - Servicio para cargar preferencias de Supabase
- **`RecommendationEngine.swift`** - Motor de IA con scoring multi-criterio usando NaturalLanguage framework
- **`SmartNotificationService.swift`** - Servicio de notificaciones contextuales con UNUserNotificationCenter

### UI Components
- **`RecommendedProducerCard.swift`** - Card de productor recomendado con score de compatibilidad
- **`RecommendationDetailView.swift`** - Vista detallada del desglose de compatibilidad
- **`NotificationPreferencesView.swift`** - Panel de configuración de notificaciones
- **`HomeView.swift`** (actualizado) - Integra sección "Recomendados para Ti"
- **`ProfileView.swift`** (actualizado) - Botón para acceder a preferencias de notificaciones

### Configuración
- **`AppDelegate.swift`** - Configuración de UNUserNotificationCenterDelegate
- **`KapitosAppApp.swift`** (actualizado) - Integra AppDelegate

---

## 🧠 Algoritmo de Scoring

El `RecommendationEngine` calcula un score de 0-100 basado en:

### 1. Coincidencia de Preferencias (40 puntos)
- **Procesos** (15 pts): Coincidencia entre `user_preferences.processes` y `producers.processes`
- **Variedades/Notas** (15 pts): Similitud semántica entre `user_preferences.flavor_notes` y `producers.varieties` usando `NLEmbedding`
- **Certificaciones** (10 pts): Bonus por certificaciones orgánicas, comercio justo, etc.

### 2. Proximidad Geográfica (30 puntos)
- < 50km = 30 puntos
- 50-100km = 25 puntos
- 100-200km = 20 puntos
- 200-500km = 15 puntos
- > 500km = 10 puntos

### 3. Engagement Score (20 puntos)
- Basado en historial de conversaciones en `conversations` table
- 5+ conversaciones = 20 puntos
- 3-4 conversaciones = 15 puntos
- 1-2 conversaciones = 10 puntos

### 4. Tours Disponibles (10 puntos)
- `has_tourist_area=true` + `tourist_accessible=true` = 10 puntos
- Solo `has_tourist_area=true` = 5 puntos

---

## 🔔 Tipos de Notificaciones

### 1. Nuevos Productores Compatibles
**Trigger**: Nuevo productor aprobado en los últimos 7 días con score >60%

**Ejemplo**:
```
🌟 Nuevo Productor Compatible
Nuevo productor en Veracruz con proceso Natural que te encanta (85% compatible)
```

### 2. Alertas de Cosecha
**Trigger**: `last_harvest_date` + 365 días en ventana de 60-90 días

**Ejemplo**:
```
☕️ Próxima Cosecha
La cosecha de Café Los Altos (95% compatible) estará lista en 14 días
```

### 3. Tours Cercanos
**Trigger**: Usuario dentro de 50km de productor con `has_tourist_area=true`

**Ejemplo**:
```
🗺️ Tour de Cafetal Cercano
Finca El Paraíso ofrece tours de cafetales a solo 12km de ti
```

### 4. Mensajes Nuevos
**Trigger**: Nuevo mensaje en `messages` table

**Ejemplo**:
```
💬 Nuevos Mensajes
3 nuevos mensajes de Café Don José
```

---

## 🚀 Uso

### Para Activar Recomendaciones

Las recomendaciones se cargan automáticamente en `HomeView`:

```swift
HomeView(currentUserId: currentUserId)
    .environmentObject(theme)
```

El sistema:
1. Carga preferencias del usuario desde `user_preferences`
2. Obtiene todos los productores aprobados
3. Calcula scores usando el algoritmo multi-criterio
4. Muestra top 5 en sección "Recomendados para Ti"

### Para Configurar Notificaciones

1. Usuario navega a **Perfil → Notificaciones Inteligentes**
2. Solicita permisos de notificaciones y ubicación
3. Activa/desactiva tipos de notificaciones
4. Ajusta radio de búsqueda (10-200km)
5. Presiona **"Generar Notificaciones Ahora"** para crear notificaciones inmediatas

### Para Generar Notificaciones Programáticamente

```swift
Task {
    await SmartNotificationService.shared.generateContextualNotifications(userId: userId)
}
```

---

## 📋 Requisitos de Base de Datos

### Tablas Necesarias (ya existen):
- ✅ `user_preferences` - Preferencias del usuario
- ✅ `producers` - Información de productores
- ✅ `conversations` - Historial de conversaciones
- ✅ `messages` - Mensajes individuales

### Permisos RLS (Row Level Security):
Asegúrate de que las políticas de Supabase permitan:
- Usuarios pueden leer sus propias preferencias
- Usuarios pueden leer productores aprobados (`status='approved'`)
- Usuarios pueden leer sus propias conversaciones

---

## 🔐 Permisos iOS

### Info.plist Requerido:

Agrega estos keys en tu `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte productores cercanos con tours de cafetales</string>

<key>NSUserNotificationsUsageDescription</key>
<string>Te enviaremos notificaciones sobre productores compatibles, cosechas y tours cercanos</string>
```

---

## 🎨 Tecnologías Apple Utilizadas

### Natural Language Framework
- **`NLEmbedding`** - Embeddings de palabras para similitud semántica
- **`distanceType: .cosine`** - Distancia coseno entre vectores

### Core Location
- **`CLLocationManager`** - Gestión de ubicación del usuario
- **`CLLocation.distance(from:)`** - Cálculo de distancia entre coordenadas

### User Notifications
- **`UNUserNotificationCenter`** - Centro de notificaciones
- **`UNNotificationCategory`** - Categorías con acciones personalizadas
- **`UNTimeIntervalNotificationTrigger`** - Trigger basado en tiempo
- **`UNLocationNotificationTrigger`** - Trigger basado en ubicación (próximamente)

---

## 📊 Métricas y Analytics

### Para Rastrear (futuras mejoras):
- CTR de notificaciones (click-through rate)
- Tasa de conversión (mensajes enviados después de ver recomendación)
- Precisión de scoring (feedback del usuario)
- Tipos de notificaciones más efectivas

---

## 🔄 Próximas Mejoras

### Fase 2:
1. **Geofencing real** con `UNLocationNotificationTrigger`
2. **Background refresh** usando `BGTaskScheduler` para notificaciones periódicas
3. **Cache de scores** en tabla `producer_recommendations` para optimización
4. **A/B testing** de diferentes algoritmos de scoring

### Fase 3:
1. **Modelo Core ML personalizado** entrenado con datos de café mexicano
2. **Análisis de sentimiento** en mensajes para mejorar engagement score
3. **Predicción de cosechas** con ML basado en patrones históricos
4. **Recomendaciones colaborativas** (users with similar preferences also liked...)

---

## 🐛 Testing

### Para Probar Recomendaciones:
1. Crea usuario con preferencias configuradas
2. Asegúrate de tener productores aprobados en DB
3. Navega a HomeView
4. Deberías ver sección "Recomendados para Ti"
5. Toca una card para ver perfil del productor
6. Long-press para ver desglose de compatibilidad

### Para Probar Notificaciones:
1. Ve a Perfil → Notificaciones Inteligentes
2. Activa permisos de notificaciones
3. Presiona "Generar Notificaciones Ahora"
4. Minimiza la app
5. Deberías recibir notificaciones en 2-8 segundos
6. Toca notificación para ver acciones

---

## 📝 Notas de Implementación

### Configuración de Xcode:
1. Agrega **`NaturalLanguage.framework`** en Build Phases → Link Binary
2. Agrega **`CoreLocation.framework`**
3. Agrega **`UserNotifications.framework`**
4. Actualiza `Info.plist` con keys de permisos

### Supabase:
- Asegúrate de que `anon` key tiene permisos de lectura en tablas necesarias
- Configura RLS policies apropiadas
- Considera agregar índices en `producers(status, created_at)` para performance

### Apple Intelligence:
- `NLEmbedding.wordEmbedding(for: .spanish)` solo funciona en **iOS 17+**
- Fallback a string matching simple si embeddings no disponibles
- Considera descargar modelos custom para mejor precisión

---

## 🎉 Resultado Final

El sistema ahora proporciona:
- ✅ Recomendaciones personalizadas en tiempo real
- ✅ Explicaciones claras de compatibilidad
- ✅ Notificaciones contextuales inteligentes
- ✅ Control granular de preferencias
- ✅ UI/UX pulida e intuitiva
- ✅ 100% integrado con arquitectura existente

**¡La Ruta del Café ahora usa Apple Intelligence para conectar clientes con productores de forma inteligente!** 🚀☕️
