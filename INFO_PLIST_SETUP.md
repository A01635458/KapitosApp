# Configuración de Info.plist para IA y Notificaciones

## Keys Requeridos en Info.plist

Agrega estos keys en el archivo `Info.plist` de tu proyecto Xcode:

### 1. Permisos de Ubicación

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para mostrarte productores de café cercanos con tours de cafetales y enviarte notificaciones cuando estés cerca de productores compatibles.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Queremos enviarte notificaciones cuando estés cerca de productores de café que coincidan con tus preferencias, incluso cuando la app esté cerrada.</string>
```

### 2. Permisos de Notificaciones

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Te enviaremos notificaciones inteligentes sobre nuevos productores compatibles, cosechas próximas y tours de cafetales cercanos basadas en tus preferencias.</string>
```

### 3. Background Modes (opcional para Fase 2)

Para notificaciones en segundo plano:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## Cómo Agregar en Xcode

### Método 1: Editor Visual
1. Abre tu proyecto en Xcode
2. Selecciona el target `KapitosApp`
3. Ve a la pestaña **Info**
4. Click en el botón **+** al lado de cualquier key existente
5. Escribe el nombre del key (ej: `NSLocationWhenInUseUsageDescription`)
6. Presiona Enter y escribe el valor (la descripción)

### Método 2: Editar como XML
1. En el navegador de archivos, encuentra `Info.plist`
2. Click derecho → **Open As** → **Source Code**
3. Copia y pega los XML blocks arriba dentro de `<dict>...</dict>`
4. Guarda el archivo

---

## Verificación

Para verificar que los permisos están correctos:

1. **Build el proyecto** (⌘+B)
2. **Run en simulador** (⌘+R)
3. Cuando la app solicite permisos, deberías ver:
   - Diálogo de ubicación con tu mensaje personalizado
   - Diálogo de notificaciones con tu mensaje
4. Si los mensajes aparecen en inglés o no personalizados, revisa el Info.plist

---

## Capabilities en Xcode

Además del Info.plist, habilita estas capabilities:

1. Ve a **Project Settings** → **Signing & Capabilities**
2. Click en **+ Capability**
3. Agrega:
   - ✅ **Push Notifications** (para notificaciones remotas futuras)
   - ✅ **Background Modes** → Location updates, Background fetch

---

## Testing de Permisos

```swift
// En NotificationPreferencesView, verifica el status:
@StateObject private var notificationService = SmartNotificationService.shared

// El servicio automáticamente checa permisos en init()
// Verás en consola:
// ✅ Notification permission granted
// 📍 Location permission status: 3 (authorized)
```

---

## Troubleshooting

### "Permission request not showing"
- Verifica que el key está en Info.plist
- Desinstala la app del simulador
- Clean Build Folder (⇧⌘K)
- Reinstala

### "Location always authorization denied"
- iOS requiere primero "When In Use"
- Luego puedes solicitar "Always"
- No solicites "Always" en primera pantalla

### "Notifications not arriving"
- Verifica que el device/simulator permite notificaciones
- Checa Settings → Notifications → KapitosApp
- Verifica que no está en Do Not Disturb

---

¡Listo para probar el sistema de IA! 🚀
