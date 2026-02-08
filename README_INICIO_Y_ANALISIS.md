# Guía de Inicio y Análisis del Sistema - Préstamos App

Este documento proporciona una guía paso a paso para arrancar el proyecto `prestamos_app` para propósitos de depuración y desarrollo, así como un análisis del sistema actual basado en su código fuente y documentación.

## ⚠️ Corrección Crítica Inicial

Antes de intentar ejecutar el proyecto, se ha detectado un error tipográfico en la estructura de carpetas que **impedirá la compilación**:

1.  Navega a la carpeta `lib/`.
2.  Busca la carpeta llamada `congif`.
3.  **Renómbrala** a `config`.
    *   El archivo `main.dart` intenta importar desde `config/theme/...` y `config/router/...`, por lo que este cambio es obligatorio.

---

## 🚀 Guía de Inicio Rápido (Startup Guide)

Sigue estos pasos para poner en marcha el entorno de desarrollo y la aplicación.

### 1. Requisitos Previos
Asegúrate de tener instalado:
*   **Flutter SDK** (versión estable reciente).
*   **Dart SDK** (incluido en Flutter).
*   **VS Code** o Android Studio con las extensiones de Flutter/Dart.

### 2. Instalación de Dependencias
Abre una terminal en la raíz del proyecto (`prestamos_app`) y ejecuta:

```bash
flutter pub get
```

### 3. Generación de Código (Drift y Riverpod)
Este proyecto utiliza `drift` (base de datos) y `flutter_riverpod` (estado) con generadores de código. Es necesario ejecutar el `build_runner` para crear los archivos `.g.dart`:

```bash
dart run build_runner build -d
```
*Si encuentras errores de conflictos, usa `dart run build_runner build --delete-conflicting-outputs`.*

### 4. Ejecución en Windows
Para iniciar la aplicación en modo debug para escritorio Windows:

```bash
flutter run -d windows
```

---

## 🔍 Análisis del Sistema

### Arquitectura
El proyecto sigue una **Clean Architecture** estructurada por *features* (características), facilitando la escalabilidad y el mantenimiento.

*   **`lib/features/`**: Contiene la lógica de negocio dividida por dominios:
    *   `caja`: Gestión de cuentas, ingresos y egresos.
    *   `clientes`: Registro y administración de prestatarios.
    *   `dashboard`: Pantalla principal con KPIs y métricas.
    *   `pagos`: Registro de cobros y aplicación a préstamos.
    *   `prestamos`: Creación de créditos y tablas de amortización.
    *   `reportes`: Generación de informes (PDF/Excel).
*   **`lib/core/`**: Módulos transversales como la base de datos (`database/`), errores y utilidades.
*   **`lib/shared/`**: Widgets y componentes reutilizables en toda la app.
*   **`lib/config/`** (antes `congif`): Configuración de rutas (`go_router`) y tema (`app_theme`).

### Base de Datos (Drift/SQLite)
*   **Ubicación**: `lib/core/database/database.dart`.
*   **Motor**: SQLite (local).
*   **Archivo DB**: Se crea automáticamente en la carpeta de documentos del usuario como `prestamos_db.sqlite`.
*   **Tablas Principales**:
    *   `Clientes`: Información personal.
    *   `Prestamos`: Cabecera del crédito (monto, tasa, plazo).
    *   `Cuotas`: Tabla de amortización generada.
    *   `Pagos`: Historial de pagos recibidos.
    *   `Cajas` y `Movimientos`: Control de flujo de dinero.

### Gestión de Estado
*   Se utiliza **Riverpod 2.x** con generadores de código.
*   Los *Providers* deben estar definidos en las carpetas `presentation/providers` dentro de cada feature.

---

## 🧪 Funcionalidades a Probar (Testing Guide)

Para validar el correcto funcionamiento del sistema ("Happy Path"), se recomienda realizar las siguientes pruebas en orden:

### 1. Inicialización y Configuración
*   Al abrir la app por primera vez, verificar que se cree la base de datos localmente.
*   Verificar que exista al menos una "Caja Principal" (creada por la migración automática).

### 2. Gestión de Clientes (Feature: Clientes)
*   **Crear**: Ir a la sección de Clientes y registrar uno nuevo.
*   **Validar**: Que no permita guardar con campos vacíos obligatorios (Nombre, DNI).
*   **Listar**: Verificar que el cliente aparezca en la lista principal.

### 3. Otorgamiento de Préstamo (Feature: Prestamos)
*   **Crear**: Iniciar un nuevo préstamo para el cliente creado.
*   **Cálculo**: Ingresar monto, tasa y plazo. Verificar si el sistema, calcula la cuota automáticamente.
*   **Amortización**: Confirmar que se genera la tabla de cuotas (fechas y montos correctos).
*   **Desembolso**: Al guardar, verificar que se descuenta el dinero de la Caja seleccionada.

### 4. Registro de Pagos (Feature: Pagos)
*   Seleccionar el préstamo activo.
*   Registrar un pago (parcial o total de una cuota).
*   **Cascada**: Verificar que el pago cubra primero Mora (si hay), luego Interés, y finalmente Capital.
*   **Estado**: Si se paga toda la cuota, su estado debe cambiar a "PAGADA".
*   **Caja**: Verificar que el dinero ingrese a la Caja seleccionada.

### 5. Reportes y Dashboard
*   Volver al Dashboard.
*   Verificar que los KPIs (Total Prestado, Interés Ganado) se hayan actualizado acorde a las operaciones realizadas.

---

## 📝 Notas Adicionales
*   Se ha ignorado el archivo `lib/app.dart` ya que `lib/main.dart` contiene la clase `MyApp` y la lógica de inicialización.
*   Consultar `sistema prestamos\documentacion\app-dart` para detalles profundos sobre la lógica de negocio esperada (Fase 2 y posteriores).
