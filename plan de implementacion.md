# 📘 Plan de Implementación - Aplicación "Steam" (Flutter + Firebase)

> ⚠️ **Nota importante:** Este documento es estrictamente un **plan de arquitectura y procedimiento**. No incluye código fuente. Se estructurará paso a paso para validar el flujo antes de pasar a la fase de implementación técnica.

---

## 🔧 1. Herramientas y Entorno de Desarrollo

| Categoría | Herramienta | Propósito |
|-----------|-------------|-----------|
| **SDK** | Flutter SDK (≥3.22 estable) + Dart SDK | Framework base y lenguaje |
| **IDE** | **VS Code** (recomendado) | Edición, depuración, terminal integrada |
| | *Nota:* "Antigravity" no es un IDE reconocido para Flutter. Se sugiere VS Code o Android Studio. |
| **Extensiones VS Code** | Flutter, Dart, Firebase, Error Lens, Pubspec Assist | Soporte nativo y autocompletado |
| **CLI** | `flutter`, `dart`, `firebase`, `flutterfire` | Configuración, builds, conexión con Firebase |
| **Control de Versiones** | Git + GitHub/GitLab | Historial, ramas, colaboración |
| **Emulación/Pruebas** | Android Emulator, iOS Simulator, Dispositivo físico, Flutter Web/Desktop | Pruebas multiplataforma |
| **Diseño** | Figma / Penpot | Wireframes, prototipos interactivos, handoff a devs |

---

## 🎨 2. Diseño UI/UX (Fase de Concepto)

1. **Investigación y Definición**
   - Usuarios objetivo, casos de uso principales, flujos críticos.
   - Definir pantallas clave: Onboarding, Login/Registro, Home, Detalle, Perfil, Configuración.
2. **Sistema de Diseño**
   - Paleta de colores (modo claro/oscuro accesible).
   - Tipografía escalable y jerarquía visual.
   - Componentes reutilizables: botones, inputs, cards, loaders, toasts, errores.
3. **Principios UX**
   - Navegación predecible (BottomNavigationBar / Drawer según complejidad).
   - Feedback inmediato: estados de carga, validaciones en tiempo real, manejo de errores amigables.
   - Accesibilidad: contraste WCAG, escalado de texto, soporte para lectores de pantalla.
4. **Entregables antes de codificar**
   - Wireframes de baja fidelidad → Prototipo interactivo → Especificación de componentes → Guía de estilos exportada.

---

## 🏗️ 3. Arquitectura y Estructura del Proyecto

```
lib/
├── core/           # Constantes, temas, rutas, utilidades, errores
├── data/           # Repositorios, fuentes remotas (Firebase), modelos/DTOs
├── domain/         # Casos de uso, entidades puras, contratos de repositorio
├── presentation/   # Pantallas, widgets, providers, navegación
└── main.dart       # Punto de entrada, MultiProvider, inicialización
```

- **Patrón recomendado:** MVVM simplificado o Clean Architecture ligera.
- **Rutas:** `go_router` o `auto_route` (decisión a confirmar en fase de dependencias).
- **Configuración de entornos:** `flutter_dotenv` o sabores (`dev`/`prod`) para separar configuraciones.

---

## 📦 4. Dependencias (`pubspec.yaml`)

> 🔍 *Las versiones deben verificarse en pub.dev al momento de la implementación. Se listan los paquetes esenciales.*

| Paquete | Versión sugerida | Función |
|---------|------------------|---------|
| `flutter` | `sdk: flutter` | Framework base |
| `firebase_core` | `^3.x.x` | Inicialización de Firebase |
| `firebase_auth` | `^5.x.x` | Autenticación email/password |
| `cloud_firestore` | `^5.x.x` | Base de datos en tiempo real |
| `provider` | `^6.x.x` | Gestión de estado reactivo |
| `go_router` / `auto_route` | `^14.x.x` / `^26.x.x` | Navegación tipada y segura |
| `flutter_screenutil` o `responsive_framework` | `^9.x.x` | Adaptabilidad multiplataforma |
| `cached_network_image` | `^3.x.x` | Gestión de imágenes remotas |
| `intl` | `^0.19.x` | Formateo de fechas/monedas |
| `shared_preferences` | `^2.x.x` | Persistencia local ligera (opcional) |
| `flutter_lints` | `^4.x.x` | Estándares de calidad de código |

**Secciones adicionales en `pubspec.yaml`:**
- `assets:` (imágenes, fuentes, JSON locales)
- `fonts:` (si se usan tipografías personalizadas)
- `flutter_native_splash:` (pantalla de carga nativa)

---

## 🔐 5. Flujo de Autenticación (Email/Password)

1. **Configuración Firebase Console**
   - Crear proyecto "Steam".
   - Habilitar Authentication → Método: Email/Password.
   - Opcional: verificación de email, reCAPTCHA v2 para registro seguro.
2. **Flujos de Usuario**
   - Registro: validación de campos → creación en Firebase Auth → escritura de perfil en Firestore → redirección a Home.
   - Login: validación → signInWithEmailAndPassword → manejo de errores (usuario no existe, contraseña incorrecta, cuenta deshabilitada).
   - Recuperación: `sendPasswordResetEmail` → pantalla de confirmación.
3. **Gestión de Sesión**
   - Firebase Auth mantiene la sesión automáticamente.
   - `authStateChanges()` para reaccionar a login/logout en tiempo real.
   - Logout limpio: limpieza de estado, redirección a login, invalidación de tokens locales si aplican.

---

## 🗃️ 6. Base de Datos Firestore

1. **Modelado de Datos**
   - `users/{uid}`: perfil, preferencias, fecha de creación, rol.
   - `steam_content/{docId}`: datos principales de la app (estructura a definir según lógica de negocio).
   - `logs/{id}` o `activity/{uid}/history`: seguimiento opcional.
2. **Reglas de Seguridad (Firestore Rules)**
   - Escritura solo por dueño del documento (`request.auth != null && request.auth.uid == resource.data.userId`).
   - Lectura según rol o visibilidad pública/privada.
   - Validación de tipos y rangos con `allow` conditions.
3. **Optimización**
   - Índices compuestos para consultas frecuentes.
   - Uso de `where`, `orderBy`, `limit` para evitar lectura masiva.
   - Habilitar caché offline por defecto (Firestore ya lo incluye).
   - Paginación con `startAfterDocument` para listas largas.

---

## 🔄 7. Gestión de Estado con Provider

1. **Estructura de Providers**
   - `AuthProvider`: maneja estado de login, usuario actual, errores de autenticación.
   - `FirestoreProvider`: expone streams/collections, gestiona caché y errores de BD.
   - `AppProvider` / `ThemeProvider`: configuración global, idioma, modo oscuro.
   - `SteamDataProvider`: lógica de negocio específica de la app.
2. **Patrones de Uso**
   - `ChangeNotifier` para estado mutable.
   - `MultiProvider` en `main.dart` para inyección global.
   - `Consumer` / `context.watch` / `context.read` según necesidad de reconstrucción.
   - Evitar `setState` para datos globales; delegar en providers.
3. **Ciclo de Vida**
   - Inicialización → suscripción a `authStateChanges` → carga de datos de Firestore → renderizado reactivo.
   - Desuscripción automática al destruir widgets.

---

## 📅 8. Cronograma Paso a Paso (Fases de Desarrollo)

| Fase | Actividades Clave | Entregable |
|------|-------------------|------------|
| **1. Configuración** | Instalar Flutter/Dart, VS Code, extensiones, Firebase CLI, `flutter create steam` | Proyecto base funcional, `flutter run` exitoso |
| **2. Firebase Setup** | `flutterfire configure`, selección de plataformas, verificación de `google-services.json` / `GoogleService-Info.plist` | Firebase vinculado, Auth y Firestore habilitados |
| **3. Arquitectura & Rutas** | Crear estructura de carpetas, configurar router, definir temas y constantes | Esqueleto navegacional, `main.dart` preparado |
| **4. Auth UI + Provider** | Diseñar pantallas login/registro, crear `AuthProvider`, conectar flujos | Autenticación funcional, gestión de errores visual |
| **5. Firestore Integration** | Modelar colecciones, crear `FirestoreProvider`, reglas de seguridad, streams | Lectura/escritura segura, datos reactivos |
| **6. Pantallas Principales** | Desarrollar UI final, conectar providers, validaciones, loaders, estados vacíos | App navegable y funcional en emulador/dispositivo |
| **7. Optimización** | Linting, manejo de excepciones, caché, rendimiento de listas, accesibilidad | Código limpio, pruebas unitarias/widget básicas |
| **8. Deploy Prep** | Configurar Firebase Crashlytics/Analytics, builds (`flutter build`), store assets | APK/AAB/IPA listos, documentación técnica |

---

## 🧪 9. Pruebas y Despliegue

- **Pruebas Automatizadas:**
  - Unit tests para repositorios y casos de uso.
  - Widget tests para componentes críticos (login, listas).
  - Integration tests para flujos completos.
- **Monitoreo:**
  - Firebase Crashlytics para reportes de fallos.
  - Analytics para eventos de uso (login, navegación, errores).
- **Compilación Multiplataforma:**
  - Android: `flutter build appbundle` (Play Store)
  - iOS: `flutter build ipa` (App Store, requiere macOS)
  - Web/Desktop: `flutter build web` / `flutter build windows/macos/linux`
- **Distribución Interna:** Firebase App Distribution o TestFlight para beta testers.

---

## ✅ 10. Validación y Siguientes Pasos

Antes de generar cualquier línea de código, se recomienda:

1. Revisar y aprobar este plan con el equipo o stakeholders.
2. Definir el modelo exacto de datos Firestore (campos, tipos, relaciones).
3. Validar wireframes/prototipos UI/UX.
4. Confirmar si se requiere autenticación adicional (Google, Apple, Phone) en futuras iteraciones.
5. Establecer rama Git principal (`main`), rama de desarrollo (`dev`), y convención de commits.

📌 **Cuando el plan sea aprobado, procederé a generar:**
- Estructura detallada de archivos
- Configuración de `pubspec.yaml` con versiones exactas
- Implementación paso a paso con código modular, comentado y listo para producción

¿Deseas ajustar algún flujo, agregar una funcionalidad específica a "Steam", o proceder directamente con la fase 1 de implementación?
