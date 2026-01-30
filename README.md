# Planificador de Ruta Zigzag (Flutter + Google Maps)

Esta aplicación permite a los usuarios dibujar un polígono en el mapa y generar automáticamente una ruta de navegación en zigzag con puntos de liberación equidistantes.

## 🚀 Configuración de API Keys (¡IMPORTANTE!)

Para que el mapa funcione correctamente y no aparezca una pantalla en blanco, debes configurar tu **Google Maps API Key** en tres lugares diferentes:

### 1. Web
Edita el archivo `web/index.html` y reemplaza `YOUR_WEB_API_KEY_HERE` con tu clave:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=TU_CLAVE_AQUI"></script>
```

### 2. Android
Edita el archivo `android/app/src/main/AndroidManifest.xml` y reemplaza `YOUR_ANDROID_API_KEY_HERE`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="TU_CLAVE_AQUI"/>
```

### 3. iOS
Edita el archivo `ios/Runner/AppDelegate.swift` y reemplaza `YOUR_IOS_API_KEY_HERE`:
```swift
GMSServices.provideAPIKey("TU_CLAVE_AQUI")
```

---

## 🛠️ Desarrollo

### Instalación de dependencias
```bash
flutter pub get
```

### Ejecución en Web
```bash
flutter run -d chrome
```

### Tests
```bash
flutter test
```

## 📄 Lógica de Navegación
La lógica principal para el cálculo del zigzag y los puntos de liberación se encuentra en `lib/path_planner.dart`. Utiliza la librería `maps_toolkit` para asegurar precisión geográfica mediante cálculos de Gran Círculo (Haversine).
