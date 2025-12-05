# Sistema de Fotos de Perfil para Usuarios - Implementación Completa

## 📋 Resumen de Cambios

### 1. Base de Datos
**Archivo:** `add_photo_url_to_profiles.sql`
- Agrega el campo `photo_url` (TEXT) a la tabla `profiles`
- Incluye instrucciones para crear el bucket `user-profiles` en Supabase Storage

### 2. Modelo de Datos
**RegistrationFlowModel.swift:**
- ✅ Agregado `@Published var profileImage: UIImage? = nil`

**UserProfile.swift:**
- ✅ Agregado `let photo_url: String?` al struct

### 3. Servicio de Registro
**UserRegistrationService.swift:**
- ✅ Método `uploadProfileImage()` para subir foto a Storage
- ✅ Actualizado `signUpUser()` para incluir `profileImage` y `photo_url`
- ✅ Actualizado `completeRegistration()` para manejar la foto

### 4. Vista de Registro
**RegisterView.swift:**
- ✅ Selector de foto de perfil (cámara o galería)
- ✅ Preview circular de la imagen seleccionada
- ✅ Integrado con `ImageSourceSelector`
- ✅ La foto es **opcional** durante el registro

### 5. Vista de Perfil
**ProfileView.swift:**
- ✅ Muestra foto de perfil circular
- ✅ Botón de edición en la esquina inferior derecha
- ✅ Carga automática de foto desde `photo_url`
- ✅ Método `uploadProfilePhoto()` para actualizar foto
- ✅ Indicador de carga mientras sube
- ✅ Permite tomar foto o elegir de galería

### 6. Componente Reutilizable
**ImageSourcePicker.swift:**
- ✅ Ya existía y está siendo utilizado
- ✅ Muestra diálogo: "Tomar foto" o "Elegir de galería"

## 🗄️ Configuración de Supabase

### Paso 1: Ejecutar SQL
```sql
-- Ejecuta el archivo: add_photo_url_to_profiles.sql
```

### Paso 2: Crear Bucket
1. Ve a **Storage** en Supabase
2. Click **"New bucket"**
3. Nombre: `user-profiles`
4. **Public bucket: ✅ SÍ**
5. Click **"Create bucket"**

### Paso 3: Configurar Políticas (RLS)

#### Política de Lectura Pública:
```sql
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'user-profiles');
```

#### Política de Escritura (Solo tu propio perfil):
```sql
CREATE POLICY "Users can upload their own profile"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'user-profiles' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

#### Política de Actualización:
```sql
CREATE POLICY "Users can update their own profile"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'user-profiles' 
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

## 📱 Flujo de Usuario

### Registro:
1. Usuario abre **RegisterView**
2. Ve círculo con icono de cámara
3. Toca el círculo → Menú: "Tomar foto" / "Elegir de galería"
4. Selecciona imagen (opcional)
5. Continúa con el registro
6. Al completar, la foto se sube a `user-profiles/{uuid}/profile.jpg`

### Perfil:
1. Usuario abre **ProfileView**
2. Ve su foto de perfil (o placeholder si no tiene)
3. Botón de edición en esquina inferior derecha
4. Toca botón → Menú: "Tomar foto" / "Elegir de galería"
5. Selecciona nueva imagen
6. Se sube automáticamente y actualiza en DB

## 🔒 Seguridad

- ✅ Usuarios solo pueden subir/actualizar su propia foto
- ✅ Lectura pública de fotos (para mostrar en la app)
- ✅ Nombres de archivo únicos por usuario: `{uuid}/profile.jpg`
- ✅ Compresión JPEG al 70% para optimizar tamaño

## ✅ Testing

1. **Ejecuta** `add_photo_url_to_profiles.sql` en Supabase SQL Editor
2. **Crea** el bucket `user-profiles` con las políticas
3. **Registra** un nuevo usuario con foto
4. **Verifica** en Storage que la foto se subió
5. **Verifica** en tabla `profiles` que `photo_url` tiene la URL
6. **Abre** ProfileView y confirma que se muestra la foto
7. **Edita** la foto desde ProfileView
8. **Confirma** que se actualiza correctamente

## 📦 Estructura de Storage

```
user-profiles/
├── {uuid-usuario-1}/
│   └── profile.jpg
├── {uuid-usuario-2}/
│   └── profile.jpg
└── {uuid-usuario-3}/
    └── profile.jpg
```

## 🎨 UI/UX

- **Registro:** Foto opcional, círculo con placeholder
- **Perfil:** Foto con botón de edición flotante
- **Ambos:** Selector de fuente (cámara/galería)
- **Feedback:** Indicador de carga durante upload
- **Consistente:** Mismo flujo que `ProducerBusinessView`
