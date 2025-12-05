# Sistema de Mensajería - Guía de Implementación

## Resumen

Se ha implementado un sistema completo de mensajería en tiempo real usando Supabase para la app KapitosApp. El sistema permite que clientes y productores se comuniquen directamente.

## Estructura de Archivos

### Nuevos Archivos Creados

1. **MessagingService.swift** - Servicio principal para manejar todas las operaciones de mensajería
   - Ubicación: `/KapitosApp/DM/MessagingService.swift`
   - Funcionalidad:
     - Fetch de conversaciones
     - Fetch de mensajes
     - Envío de mensajes
     - Marcar mensajes como leídos
     - Crear nuevas conversaciones

### Archivos Modificados

2. **Message.swift** - Modelo actualizado con timestamp, tipo de mensaje, URL de imagen
3. **ClientChatListView.swift** - Lista de conversaciones para clientes (ahora con datos reales)
4. **ClientChatDetailView.swift** - Vista de chat individual para clientes
5. **ClientMessageBubble.swift** - Burbuja de mensaje con timestamp
6. **ProducerChatListView.swift** - Lista de conversaciones para productores
7. **ProducerChatDetailView.swift** - Vista de chat individual para productores
8. **ProducerMessageBubble.swift** - Burbuja de mensaje con timestamp

## Base de Datos

### Tablas Utilizadas

La base de datos ya tenía las tablas necesarias:

```sql
- conversations: Almacena las conversaciones entre cliente y productor
- messages: Almacena los mensajes individuales
- unread_messages_count: Contador de mensajes no leídos (opcional)
- profiles: Perfiles de usuario con rol (user/producer/admin)
```

### Script de Datos de Prueba

Archivo: `insert_sample_conversations.sql`

Para usar:
1. Ve a Supabase SQL Editor
2. Ejecuta: `SELECT id, full_name, role FROM profiles;`
3. Copia los UUIDs reales
4. Edita el archivo SQL reemplazando los placeholders
5. Ejecuta el script

## Uso en las Vistas

### Para Cliente

```swift
// En HomeView o donde llames ClientChatListView
NavigationLink {
    ClientChatListView(currentUserId: currentUserUUID)
        .environmentObject(theme)
} label: {
    Text("Mensajes")
}
```

### Para Productor

```swift
// En ProducerContentView o donde llames ProducerChatListView
NavigationLink {
    ProducerChatListView(currentUserId: currentUserUUID)
        .environmentObject(theme)
} label: {
    Text("Mensajes")
}
```

## Características Implementadas

### ✅ Completadas

1. **Lista de Conversaciones**
   - Muestra todas las conversaciones activas
   - Último mensaje visible
   - Contador de mensajes no leídos
   - Formato de tiempo (hoy, ayer, fecha)
   - Pull to refresh

2. **Chat Individual**
   - Muestra historial completo de mensajes
   - Envío de mensajes en tiempo real
   - Auto-scroll al último mensaje
   - Timestamps en cada mensaje
   - Marca mensajes como leídos automáticamente
   - Estados de carga y vacío

3. **Funcionalidad de Mensajes**
   - Envío de mensajes de texto
   - Soporte para imágenes (estructura preparada)
   - Mensajes del sistema (estructura preparada)
   - Eliminación lógica de mensajes

### 🚧 Pendientes (Mejoras Futuras)

1. **Real-time Subscriptions**
   - Implementar Supabase Realtime para recibir mensajes instantáneamente
   - Notificaciones push cuando llegan mensajes nuevos

2. **Soporte de Imágenes**
   - Subir imágenes a Supabase Storage
   - Mostrar imágenes en las burbujas de mensaje

3. **Estado de Usuario**
   - Indicador de "en línea"
   - Último visto

4. **Funciones Adicionales**
   - Búsqueda en conversaciones
   - Eliminar conversaciones
   - Bloquear usuarios
   - Reportar mensajes

## Configuración de Supabase

### URL y API Key

Actualmente configurado en `MessagingService.swift`:
```swift
URL: https://vhjxtygfviesnyepsujw.supabase.co
API Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Políticas de Seguridad (RLS)

Asegúrate de tener las siguientes políticas en Supabase:

```sql
-- Conversations: usuarios solo pueden ver sus propias conversaciones
CREATE POLICY "Users can view their own conversations"
ON conversations FOR SELECT
USING (auth.uid() = client_id OR auth.uid() = producer_id);

-- Messages: usuarios solo pueden ver mensajes de sus conversaciones
CREATE POLICY "Users can view messages in their conversations"
ON messages FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM conversations
    WHERE conversations.id = messages.conversation_id
    AND (conversations.client_id = auth.uid() OR conversations.producer_id = auth.uid())
  )
);

-- Messages: usuarios pueden enviar mensajes a sus conversaciones
CREATE POLICY "Users can insert messages in their conversations"
ON messages FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM conversations
    WHERE conversations.id = messages.conversation_id
    AND (conversations.client_id = auth.uid() OR conversations.producer_id = auth.uid())
  )
);
```

## Cómo Iniciar una Conversación

Desde la vista de detalles de productor (por ejemplo, al ver un productor en el mapa):

```swift
Button("Contactar Productor") {
    Task {
        let service = MessagingService(currentUserId: currentUserUUID)
        if let conversationId = await service.getOrCreateConversation(withUserId: producerUUID) {
            // Navegar a ClientChatDetailView con conversationId
        }
    }
}
```

## Flujo de Datos

1. Usuario abre lista de conversaciones
2. `MessagingService.fetchConversations()` se ejecuta
3. Se obtienen conversaciones de Supabase
4. Para cada conversación, se obtiene:
   - Perfil del otro usuario
   - Último mensaje
   - Contador de no leídos
5. Usuario selecciona una conversación
6. `MessagingService.fetchMessages(conversationId:)` se ejecuta
7. Se muestran todos los mensajes
8. Mensajes no leídos se marcan como leídos automáticamente
9. Usuario escribe y envía mensaje
10. `MessagingService.sendMessage()` se ejecuta
11. Mensaje se guarda en Supabase
12. Mensaje aparece en la lista localmente

## Manejo de Errores

El servicio incluye manejo de errores con:
- `@Published var errorMessage: String?`
- Mensajes descriptivos en español
- Estados de carga con `isLoading`

## Testing

Para probar el sistema:

1. Crea al menos 2 usuarios (1 cliente, 1 productor) en Supabase Auth
2. Asegúrate de que existan en la tabla `profiles` con roles correctos
3. Ejecuta el script `insert_sample_conversations.sql` con UUIDs reales
4. Inicia sesión como cliente y verifica que veas la conversación
5. Inicia sesión como productor y verifica lo mismo
6. Prueba enviar mensajes desde ambos lados

## Notas Importantes

- **Usuario Actual**: Necesitas pasar el UUID del usuario actual al crear las vistas
- **Autenticación**: El sistema asume que ya tienes autenticación funcionando
- **Theme**: Todas las vistas usan `@EnvironmentObject var theme: AppThemeManager`
- **Navegación**: Las vistas usan NavigationStack, asegúrate de que estén dentro de una NavigationView/Stack

## Próximos Pasos

1. Integrar las vistas de mensajería en la navegación principal
2. Agregar botón "Contactar" en las vistas de productores
3. Configurar políticas RLS en Supabase
4. Probar con datos reales
5. (Opcional) Implementar Supabase Realtime para mensajes instantáneos
