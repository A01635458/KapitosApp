# Sistema de Aprobación de Productores - Instrucciones de Configuración

## 🎯 Resumen
Sistema completo para gestionar solicitudes de registro de productores con estados (pendiente, aprobado, rechazado) y creación automática de cuentas.

## 📋 Paso 1: Actualizar Base de Datos

Ejecuta este script en el **SQL Editor** de Supabase:

```sql
-- Agregar columna status a producers
ALTER TABLE public.producers 
ADD COLUMN IF NOT EXISTS status text DEFAULT 'pending' 
CHECK (status IN ('pending', 'approved', 'rejected'));

-- Crear índice para consultas rápidas
CREATE INDEX IF NOT EXISTS idx_producers_status ON public.producers(status);

-- Actualizar productores existentes como pendientes
UPDATE public.producers 
SET status = 'pending' 
WHERE status IS NULL;
```

## 🔧 Paso 2: Desactivar Confirmación de Email (Desarrollo)

Para desarrollo, desactiva la confirmación de email:

1. Ve a https://supabase.com/dashboard
2. Selecciona tu proyecto
3. **Authentication** → **Providers** → **Email**
4. Desactiva **"Confirm email"**
5. Guarda cambios

O confirma manualmente usuarios existentes:
```sql
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email = 'tu-email@ejemplo.com';
```

## ✅ Archivos Creados

### 1. **Producer.swift**
Modelo de datos para productores con:
- Campos completos del esquema
- Propiedades computadas (`displayName`, `location`)
- CodingKeys para mapeo correcto

### 2. **ProducerApprovalService.swift**
Servicio singleton con:
- `fetchPendingProducers()` - Obtener solicitudes pendientes
- `approveProducer(id, email, password)` - Aprobar y crear cuenta
- `rejectProducer(id)` - Rechazar solicitud
- `getProducerCounts()` - Obtener estadísticas

### 3. **ProducerListView.swift**
Vista con lista de solicitudes pendientes:
- Cards con información clave
- Pull-to-refresh
- Navegación a detalle

### 4. **ProducerApprovalView.swift**
Vista de aprobación actualizada con:
- Información completa del productor
- Formulario de credenciales
- Validación de email y password
- Botones de aprobar/rechazar
- Mensajes de éxito/error

## 📁 Archivos Modificados

### ProducerInsertDTO.swift
- ✅ Agregado campo `status: String?`

### ProducerRegistrationData.swift
- ✅ Configurado `status: "pending"` por defecto en insert

### DashboardView.swift
- ✅ Integrado `ProducerApprovalService`
- ✅ Contadores dinámicos desde DB
- ✅ NavigationLink a lista de solicitudes

## 🚀 Flujo de Trabajo

### Para Productores (Registro):
1. Llenan formulario de registro → `ProducerSurveyView`
2. Se inserta en DB con `status: 'pending'`
3. Aparece en lista de solicitudes pendientes

### Para Admins (Aprobación):
1. Ven contador en `DashboardView`
2. Hacen clic en "Solicitudes pendientes"
3. Ven lista de productores (`ProducerListView`)
4. Seleccionan un productor
5. Revisan información (`ProducerApprovalView`)
6. Crean credenciales y aprueban **O** rechazan

### Proceso de Aprobación:
1. ✅ Actualiza `status: 'approved'` en tabla `producers`
2. ✅ Crea usuario en `auth.users` con email/password
3. ✅ Actualiza `profiles.role` a `'producer'`
4. ✅ Vincula `producers.id` con el `auth.user.id` nuevo
5. ✅ Refresca la lista (productor desaparece de pendientes)

## 🧪 Pruebas

### 1. Registro de Productor:
```swift
// El productor llena formulario en ProducerSurveyView
// Se inserta con status: 'pending'
```

### 2. Ver Solicitudes:
```swift
// Admin ve DashboardView
// Contador muestra: "Solicitudes pendientes: 1"
// Click → ProducerListView
```

### 3. Aprobar:
```swift
// Admin ingresa:
// Email: productor@ejemplo.com
// Password: 123456
// Click "Aprobar y crear cuenta"
// ✅ Cuenta creada, productor puede hacer login
```

## 🔐 Seguridad Recomendada

Para producción, configura:

1. **RLS Policies** para tabla `producers`:
```sql
-- Solo admins pueden ver solicitudes pendientes
CREATE POLICY "Admins can view pending producers"
ON public.producers FOR SELECT
TO authenticated
USING (
  auth.jwt() ->> 'role' = 'admin' 
  OR status = 'approved'
);

-- Solo admins pueden actualizar status
CREATE POLICY "Only admins can update status"
ON public.producers FOR UPDATE
TO authenticated
USING (auth.jwt() ->> 'role' = 'admin');
```

2. **Validación de Email** (producción):
   - Mantén confirmación de email activada
   - Configura SMTP en Supabase
   - Envía emails de bienvenida personalizados

## 📊 Dashboard en Tiempo Real

El `DashboardView` ahora muestra:
- **Solicitudes pendientes**: Count dinámico con link a lista
- **Productores activos**: Count de aprobados
- **Total registrados**: Suma de todos los estados

## ⚠️ Notas Importantes

1. **Supabase Key**: Usar `anon` key en código, NO `service_role`
2. **UUID Linking**: Al aprobar, el `producers.id` se reemplaza con el `auth.user.id` generado
3. **Email único**: Validar que el email no exista antes de crear cuenta
4. **Password**: Mínimo 6 caracteres (validado en UI)
5. **Error Handling**: Todos los servicios manejan errores y muestran mensajes

## 🎨 UI/UX

- ✅ Tema claro/oscuro adaptativo
- ✅ Loading states en todas las operaciones async
- ✅ Pull-to-refresh en listas
- ✅ Validación en tiempo real de formularios
- ✅ Mensajes de éxito/error con iconos
- ✅ Navegación intuitiva con dismiss automático

## 🐛 Troubleshooting

**Error: "Email not confirmed"**
- Solución: Desactiva confirmación en Supabase (desarrollo)

**Error: "User already exists"**
- Solución: Email ya está registrado, usar otro

**No aparecen solicitudes**
- Verificar que hay productores con `status = 'pending'`
- Revisar logs en consola de Xcode

**Error de permisos (RLS)**
- Solución temporal: Desactiva RLS en tabla producers
```sql
ALTER TABLE public.producers DISABLE ROW LEVEL SECURITY;
```

## ✨ Próximos Pasos Opcionales

1. **Notificaciones Push**: Alertar admins de nuevas solicitudes
2. **Chat Interno**: Comunicación admin-productor antes de aprobar
3. **Documentos**: Subir certificados/fotos durante registro
4. **Analytics**: Gráficas de solicitudes por región/fecha
5. **Email Templates**: Emails automáticos de aprobación/rechazo
