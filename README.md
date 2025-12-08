# KapitosApp - La Ruta del Café ☕

Plataforma móvil iOS que conecta directamente a productores de café mexicanos con consumidores finales, utilizando Machine Learning para recomendaciones personalizadas.

## 🎯 Descripción

KapitosApp empodera a pequeños productores de café mexicanos para alcanzar mercados directos, mientras garantiza a los consumidores café de calidad con trazabilidad real. La app incluye:

- ✅ Registro y validación de productores con certificaciones
- ✅ Sistema de recomendaciones personalizadas con IA
- ✅ Clasificación de tipos de café usando visión por computadora (CoreML)
- ✅ Mensajería directa cliente-productor
- ✅ Mapa interactivo para descubrir productores

## 🛠 Stack Tecnológico

### Frontend (iOS App)
- **Lenguaje**: Swift 5.9
- **UI Framework**: SwiftUI
- **Mínimo iOS**: 17.0
- **IDE**: Xcode 15.0+

### Backend (Supabase BaaS)
- **Base de datos**: PostgreSQL
- **Autenticación**: Supabase Auth (JWT)
- **Storage**: Supabase Storage
- **Realtime**: Supabase Realtime (WebSockets)

### Machine Learning
- **Framework**: CoreML
- **Modelo**: CoffeeType.mlmodel (clasificación de café)
- **NLP**: NaturalLanguage framework (embeddings semánticos)

### Frameworks de Apple
- MapKit - Mapas interactivos
- CoreLocation - Ubicación del usuario
- UserNotifications - Notificaciones push
- NaturalLanguage - Análisis semántico

## 📁 Estructura del Proyecto

```
KapitosApp/
├── KapitosApp/
│   ├── AppConfig.swift              # Configuración global (URLs, keys)
│   ├── AppDelegate.swift            # Delegate para notificaciones
│   ├── KapitosAppApp.swift          # Entry point de la app
│   ├── Info.plist                   # Configuración iOS
│   │
│   ├── Assets.xcassets/             # Recursos gráficos
│   │   ├── AppIcon.appiconset/      # Iconos de la app
│   │   └── *.imageset/              # Imágenes
│   │
│   ├── ClientViews/                 # Vistas para clientes
│   │   ├── HomeView.swift           # Vista principal del cliente
│   │   ├── MapView.swift            # Mapa de productores
│   │   ├── ProfileView.swift        # Perfil del usuario
│   │   ├── RecommendationEngine.swift
│   │   ├── SmartNotificationService.swift
│   │   └── ...
│   │
│   ├── ViewProductor/               # Vistas para productores
│   │   ├── ProducerDashboardView.swift
│   │   ├── ProducerShopView.swift
│   │   ├── AddProductAIView.swift
│   │   ├── CoffeeType.mlmodel       # Modelo CoreML
│   │   └── ...
│   │
│   ├── ViewKape/                    # Vistas de administración
│   │   ├── KapeAdminView.swift
│   │   ├── ProducerApprovalView.swift
│   │   ├── DashboardView.swift
│   │   └── ...
│   │
│   ├── LogInView/                   # Autenticación y registro
│   │   ├── LoginView.swift
│   │   ├── RegisterView.swift
│   │   ├── AuthenticationService.swift
│   │   ├── ProducerSurveyView.swift
│   │   └── ...
│   │
│   ├── DM/                          # Mensajería directa
│   │   ├── Message.swift
│   │   ├── MessagingService.swift
│   │   ├── Client/
│   │   └── Producer/
│   │
│   └── Theme/                       # Sistema de temas
│       ├── AppColors.swift
│       ├── AppThemeManager.swift
│       └── UnifiedTextFieldStyle.swift
│
├── KapitosApp.xcodeproj/            # Proyecto Xcode
│
├── KapitosAppTests/                 # Pruebas unitarias
│   ├── UserRegistrationTests.swift
│   ├── AuthenticationTests.swift
│   └── ProducerRegistrationTests.swift
│
└── Documentation/                   # Documentación
    ├── TESTING_SETUP.md
    ├── AI_RECOMMENDATION_SYSTEM.md
    └── ...
```

## 🚀 Pasos para Ejecutar la App

### Prerrequisitos
1. macOS Sonoma 14.0 o superior
2. Xcode 15.0 o superior
3. Cuenta de Apple Developer (para device testing)
4. Dispositivo iOS 17.0+ o Simulator

### Configuración

1. **Clonar repositorio**:
   ```bash
   git clone https://github.com/A01635458/KapitosApp.git
   cd KapitosApp
   ```

2. **Abrir proyecto en Xcode**:
   ```bash
   open KapitosApp/KapitosApp.xcodeproj
   ```

3. **Configurar Signing**:
   - Seleccionar target "KapitosApp"
   - Tab "Signing & Capabilities"
   - Seleccionar tu Team de desarrollo

4. **Verificar configuración de Supabase**:
   El archivo `AppConfig.swift` contiene:
   ```swift
   static let supabaseURL = URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!
   static let supabaseAnonKey = "your-anon-key"
   ```

5. **Ejecutar**:
   - Seleccionar simulador o dispositivo
   - Presionar ⌘+R o botón "Play"

### Ejecutar Pruebas
```bash
# Desde Xcode
⌘+U (Command + U)

# O desde terminal
xcodebuild test -project KapitosApp.xcodeproj -scheme KapitosApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 🧪 Testing

| Módulo | Tests | Cobertura |
|--------|-------|-----------|
| User Registration | 19 | 95% |
| Authentication | 15 | 92% |
| Producer Registration | 13 | 88% |
| **Total** | **47** | **92%** |

## 🔗 API

**URL Base**: https://vhjxtygfviesnyepsujw.supabase.co

La API está implementada usando Supabase como Backend as a Service.

## 👥 Equipo

| Rol | Persona |
|-----|---------|
| Tech Lead / Backend | Leobardo Navarro |
| Frontend Lead / UI/UX | Luisa Cardona |

## 📚 Documentación Adicional

- [TESTING_SETUP.md](KapitosApp/TESTING_SETUP.md) - Configuración de pruebas
- [AI_RECOMMENDATION_SYSTEM.md](AI_RECOMMENDATION_SYSTEM.md) - Sistema de recomendaciones ML
- [MESSAGING_SETUP.md](MESSAGING_SETUP.md) - Configuración de mensajería
- [DATABASE_MIGRATION_GUIDE.md](DATABASE_MIGRATION_GUIDE.md) - Guía de base de datos

---

**Proyecto desarrollado para TC2007B - Desarrollo de Software**  
**Tecnológico de Monterrey - Diciembre 2025**
