# Configuración de Pruebas Unitarias con Swift Testing

## 📋 Descripción
Este documento describe cómo configurar y ejecutar pruebas unitarias para KapitosApp usando Swift Testing Framework (disponible desde Xcode 16 / Swift 6).

## 🎯 Cobertura de Pruebas

### 1. **UserRegistrationTests.swift**
Pruebas para el flujo de registro de usuarios:
- ✅ Inicialización del modelo de flujo
- ✅ Detección de selección de preferencias
- ✅ Almacenamiento de credenciales
- ✅ Validación de formato de email
- ✅ Validación de longitud de contraseña
- ✅ Reglas de complejidad de contraseña
- ✅ Estructura de preferencias
- ✅ Validación de formulario completo
- ✅ Coincidencia de contraseña
- ✅ Conversión de datos a arrays

### 2. **AuthenticationTests.swift**
Pruebas para autenticación y login:
- ✅ Validación de credenciales de login
- ✅ Formatos de email válidos/inválidos
- ✅ Normalización de email
- ✅ Sensibilidad a mayúsculas/minúsculas
- ✅ Estado de sesión
- ✅ Limpieza de sesión al logout
- ✅ Mensajes de error descriptivos
- ✅ Estructura de perfil de usuario
- ✅ Validación de roles
- ✅ Seguridad de contraseñas (no almacenamiento)
- ✅ Transiciones de estado de login
- ✅ Formato de token de sesión

### 3. **ProducerRegistrationTests.swift**
Pruebas para registro de productores:
- ✅ Modelo de productor con campos requeridos
- ✅ Nombre de visualización con fallback
- ✅ Formato de ubicación
- ✅ Validación de estado (pending/approved/rejected)
- ✅ Transiciones de estado
- ✅ Validación de tamaño de finca
- ✅ Validación de altitud
- ✅ Formato de número de teléfono
- ✅ Manejo de arrays (variedades, procesos)
- ✅ Parseo de fechas de cosecha

## 🚀 Configuración del Target de Pruebas

### Paso 1: Crear Target de Pruebas en Xcode

1. **Abrir Xcode** → Selecciona tu proyecto `KapitosApp`
2. **File** → **New** → **Target...**
3. Selecciona **Unit Testing Bundle**
4. Nombre: `KapitosAppTests`
5. Click **Finish**

### Paso 2: Configurar Build Settings

1. Selecciona el target `KapitosAppTests`
2. **Build Settings** → busca "Testing"
3. Asegúrate de que **Enable Testing** esté en `YES`

### Paso 3: Agregar Dependencias

En el archivo `KapitosAppTests.swift` (creado automáticamente), reemplaza con:

```swift
import Testing
import Foundation
@testable import KapitosApp

@Suite("Example Tests")
struct ExampleTests {
    @Test("Basic test")
    func exampleTest() async {
        #expect(1 + 1 == 2)
    }
}
```

### Paso 4: Copiar Archivos de Pruebas

Copia los archivos de prueba al folder `KapitosAppTests`:
- `UserRegistrationTests.swift`
- `AuthenticationTests.swift`
- `ProducerRegistrationTests.swift`

## ▶️ Ejecutar las Pruebas

### Desde Xcode:

**Opción 1: Todas las pruebas**
```
⌘ + U (Command + U)
```

**Opción 2: Suite específica**
- Click en el diamante junto al nombre de la suite
- Ejemplo: Click en el diamante junto a `@Suite("User Registration Tests")`

**Opción 3: Test individual**
- Click en el diamante junto a `@Test(...)`

**Opción 4: Test Navigator**
1. **⌘ + 6** para abrir Test Navigator
2. Click en cualquier test para ejecutarlo

### Desde Terminal:

**Todas las pruebas:**
```bash
xcodebuild test \
  -scheme KapitosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

**Suite específica:**
```bash
xcodebuild test \
  -scheme KapitosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:KapitosAppTests/UserRegistrationTests
```

**Test individual:**
```bash
xcodebuild test \
  -scheme KapitosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -only-testing:KapitosAppTests/UserRegistrationTests/testFlowModelInitialization
```

## 📊 Ver Resultados

### En Xcode:
1. **⌘ + 9** para abrir Report Navigator
2. Selecciona el último test run
3. Ver resultados detallados por suite y test

### Indicadores visuales:
- ✅ **Verde**: Test pasó
- ❌ **Rojo**: Test falló
- ⚪ **Gris**: Test no ejecutado

## 🔍 Debugging de Pruebas

### Agregar Breakpoints:
1. Click en el número de línea dentro de un test
2. Ejecuta el test con **⌘ + U**
3. La ejecución se pausará en el breakpoint

### Ver Output de Console:
1. Durante la ejecución de tests, abre **Debug Console** (⇧⌘Y)
2. Usa `print()` dentro de tests para debugging

### Test Parameterizado:
```swift
@Test("Valid emails",
      arguments: [
        "user@example.com",
        "test@domain.co"
      ])
func testEmail(email: String) async {
    #expect(email.contains("@"))
}
```

## 🎨 Sintaxis de Swift Testing

### Basic Assertions:
```swift
#expect(value == expected)              // Equality
#expect(value != unexpected)            // Inequality
#expect(condition)                      // Boolean
#expect(!condition)                     // Negated
#expect(value > 0)                      // Comparison
#expect(array.isEmpty)                  // Collection
#expect(optional != nil)                // Optionals
#expect(string.contains("text"))        // String
```

### Suites y Tests:
```swift
@Suite("Suite Name")
struct MyTests {
    @Test("Test description")
    func myTest() async {
        // Test code
    }
}
```

### Setup/Teardown:
```swift
@Suite("My Suite")
struct MyTests {
    init() async {
        // Setup antes de cada test
    }
    
    deinit {
        // Cleanup después de cada test
    }
}
```

## 📈 Cobertura de Código

### Habilitar Code Coverage:

1. **Product** → **Scheme** → **Edit Scheme...**
2. Selecciona **Test** en sidebar
3. Tab **Options**
4. Check **Code Coverage**
5. Click **Close**

### Ver Reporte de Cobertura:

1. Ejecuta tests con **⌘ + U**
2. **⌘ + 9** (Report Navigator)
3. Click en el test run
4. Tab **Coverage**

### Desde Terminal:
```bash
xcodebuild test \
  -scheme KapitosApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -enableCodeCoverage YES
```

## 🛠️ Troubleshooting

### Error: "No such module 'Testing'"
**Posibles causas y soluciones:**

**1. Verificar versión de Xcode:**
```bash
# En terminal
xcodebuild -version
```
Debe ser Xcode 16.0 o superior. Si no:
- Descarga desde App Store o [developer.apple.com](https://developer.apple.com/download/)
- Cambia a Xcode 16: `sudo xcode-select -s /Applications/Xcode.app`

**2. Deployment Target bajo:**
- Selecciona el target de tests `KapitosAppTests`
- **General** → **Minimum Deployments**
- iOS: Mínimo **iOS 18.0**
- Guarda y limpia: **⇧⌘K**

**3. Swift Language Version:**
- Target `KapitosAppTests` → **Build Settings**
- Busca "Swift Language Version"
- Debe ser **Swift 6** o superior
- Si no aparece, usa **Swift 5** (compatible hacia atrás)

**4. Alternativa: Usar XCTest (compatible con todas las versiones)**

Si Swift Testing no está disponible, usa XCTest en su lugar. Reemplaza los imports:

```swift
// En lugar de:
import Testing
@Suite("My Tests")
struct MyTests {
    @Test("Test name")
    func myTest() async {
        #expect(value == expected)
    }
}

// Usa XCTest:
import XCTest
@testable import KapitosApp

final class MyTests: XCTestCase {
    func testName() async throws {
        XCTAssertEqual(value, expected)
    }
}
```

**5. Clean y Rebuild completo:**
```bash
# En terminal desde la carpeta del proyecto
rm -rf ~/Library/Developer/Xcode/DerivedData/*
xcodebuild clean -scheme KapitosApp
xcodebuild build -scheme KapitosApp
```

**6. Verificar que el test target esté correctamente configurado:**
- **File Inspector** (⌥⌘1) → selecciona el archivo de test
- **Target Membership** → debe tener check en `KapitosAppTests`
- **Build Phases** → `Compile Sources` debe incluir los archivos de test

### Error: "Cannot find 'KapitosApp' in scope"
**Solución:**
1. Verifica que `@testable import KapitosApp` esté presente
2. Build Settings → `Enable Testability` = YES
3. El módulo debe coincidir con el nombre del target (puede ser diferente al nombre del proyecto)

### Error: "Use of unresolved identifier"
**Solución:**
1. Los tipos/funciones deben ser `public` o `internal` (no `private`)
2. O declara como `@testable import`

### Tests no aparecen en Test Navigator:
**Solución:**
1. Clean Build Folder: **⇧⌘K**
2. Rebuild: **⌘ + B**
3. Reinicia Xcode
4. Verifica que los archivos estén en el target de tests

### Tests muy lentos:
**Solución:**
1. Usa `async` solo cuando necesario
2. Mock servicios de red/DB
3. Evita operaciones pesadas en setup

## 📚 Mejores Prácticas

### ✅ DO:
- Nombra tests descriptivamente: `testUserCanLoginWithValidCredentials`
- Usa `@Suite` para organizar tests relacionados
- Tests deben ser independientes (no depender de orden)
- Un test = una cosa a verificar
- Usa parametrized tests para múltiples casos similares

### ❌ DON'T:
- No hagas tests que dependan de red real
- No uses sleep/delays innecesarios
- No testees código de terceros (Supabase SDK)
- No hagas tests que modifican DB de producción

## 🎯 Siguientes Pasos

1. **Mock Supabase Client** para tests de integración:
```swift
protocol SupabaseClientProtocol {
    func signUp(email: String, password: String) async throws -> AuthResponse
}

class MockSupabaseClient: SupabaseClientProtocol {
    func signUp(email: String, password: String) async throws -> AuthResponse {
        // Return mock data
    }
}
```

2. **UI Tests** (opcional):
   - Crear target `KapitosAppUITests`
   - Tests de flujos completos de usuario

3. **Continuous Integration**:
   - GitHub Actions para ejecutar tests automáticamente
   - Reportes de cobertura en PRs

## 🔗 Recursos

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [WWDC 2024: Meet Swift Testing](https://developer.apple.com/videos/play/wwdc2024/10179/)
- [Swift Testing GitHub](https://github.com/apple/swift-testing)

---

**Nota**: Swift Testing requiere Xcode 16+ y Swift 6+. Para versiones anteriores, usa XCTest.
