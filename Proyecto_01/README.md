# Red y Seguridad

Aplicación Flutter para el proyecto de Aplicaciones Móviles.

## Módulos incluidos

- **REST API** con `jsonplaceholder.typicode.com/posts/{id}`
- **Gestión de Secretos y Configuración** con:
  - `SharedPreferences`
  - `DataStore` mediante `SharedPreferencesAsync`
  - `EncryptedSharedPreferences` con `flutter_secure_storage`

## Estructura general

- `lib/models/` → modelo `PostModel`
- `lib/services/` → servicios REST y almacenamiento
- `lib/controllers/` → `ChangeNotifier` para estados reactivos
- `lib/screens/` → pantallas principales
- `lib/widgets/` → componentes reutilizables

## Ejecutar

```bash
flutter pub get
flutter test
flutter run
```

## Demo esperada

1. Consultar un post por ID.
2. Editar `title` y `body`.
3. Actualizar el post con respuesta `200 OK`.
4. Guardar y recuperar secretos por llave en cada mecanismo.

> Este proyecto no incluye SQL/NoSQL local ni listado de secretos.
