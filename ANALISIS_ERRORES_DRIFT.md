# Análisis de Desalineación: Drift vs Models vs Entities

Este documento detalla los problemas de sincronización entre la base de datos (Drift), los modelos de datos (Models) y las entidades de dominio (Entities), y proporciona una guía paso a paso para resolverlos y recuperar la compilación del proyecto.

## 🚨 El Problema Raíz
La base de datos (`lib/core/database/database.dart`) ha evolucionado, pero los **Modelos** (`*Model.dart`) y los **DataSources** no se actualizaron para reflejar estos cambios. Esto causa errores de compilación porque el código intenta acceder a columnas que ya no existen o tienen nombres diferentes, e intenta guardar datos que la base de datos no espera.

---

## 📂 Archivos Involucrados y Diagnóstico

### 1. Fuente de la Verdad (Drift)
*   **Archivo:** `lib/core/database/database.dart`
*   **Estado:** Define las tablas `Cajas`, `Movimientos`, `Clientes`, `Prestamos`, `Pagos`, `Cuotas`.
*   **Acción:** **NO MODIFICAR**. Todo el resto del código debe adaptarse a estas definiciones.

### 2. Feature: CAJA (Crítico)
*   **Archivos:**
    *   `lib/features/caja/data/models/caja_model.dart`
    *   `lib/features/caja/domain/entities/caja.dart`
    *   `lib/features/caja/data/datasources/caja_local_data_source.dart`
*   **Problemas:**
    *   `CajaModel`: Mapeaba campos inexistentes en Drift (`banco`, `numeroCuenta`) y usaba `saldo` cuando Drift usa `saldoActual`. *(Ya corregido parcialmente)*.
    *   `MovimientoModel`: La entidad espera `saldoAnterior` y `saldoNuevo`, pero Drift **NO** guarda estos campos en la tabla `Movimientos`.
    *   `MovimientosCompanion`: Requiere obligatoriamente un campo `codigo` (unique), pero el Modelo no lo tiene.
*   **Solución:**
    *   En `MovimientoModel.fromDrift`: Asignar `0.0` a `saldoAnterior` y `saldoNuevo` (o calcularlos si es posible, si no, placeholder).
    *   En `MovimientoModel.toCompanion`: Generar un código único (ej. UUID o Timestamp) si no viene en la entidad.

### 3. Feature: CLIENTES
*   **Archivos:**
    *   `lib/features/clientes/data/models/cliente_model.dart`
    *   `lib/features/clientes/data/datasources/cliente_local_data_source.dart`
*   **Problemas Probables:**
    *   Discrepancia en nombres: Entidad usa `nombre` vs Drift usa `nombres` y `apellidos`.
    *   Campos obligatorios en Drift (`tipoDocumento`, `numeroDocumento`) que quizás sean opcionales o nulos en el Modelo antiguo.
*   **Solución:**
    *   Actualizar `ClienteModel` para concatenar `nombres` + `apellidos` al leer de Drift, y separarlos al escribir (o guardar todo en uno si simplificamos, pero Drift manda).

### 4. Feature: PRÉSTAMOS
*   **Archivos:**
    *   `lib/features/prestamos/data/models/prestamo_model.dart`
    *   `lib/features/prestamos/data/datasources/prestamo_local_data_source.dart`
*   **Problemas Probables:**
    *   Campos calculados: La entidad tiene `cuota`, pero Drift guarda `cuotaMensual`.
    *   Drift tiene `montoTotal` y `saldoPendiente` como columnas reales, el modelo debe asegurarse de leerlas y no recalcularlas erróneamente.
    *   `PrestamosCompanion`: Verificar que todos los `double` (montos) sean pasados correctamente.

### 5. Feature: PAGOS
*   **Archivos:**
    *   `lib/features/pagos/data/models/pago_model.dart`
    *   `lib/features/pagos/data/datasources/pago_local_data_source.dart`
*   **Problemas Probables:**
    *   El desglose (`montoCapital`, `montoInteres`, `montoMora`) es obligatorio en Drift. Si la entidad no lo provee al crear el pago, el datasource fallará.

---

## 🛠️ Guía de Resolución Paso a Paso

Sigue este orden para arreglar el proyecto. **No pases al siguiente paso hasta que el anterior compile.**

### PASO 1: Alinear Models con Entities y Drift
Toma cada archivo `_model.dart` y asegúrate de:
1.  **`fromDrift`**:
    *   Mapea `data.columnaDrift` -> `propiedadEntidad`.
    *   Si Drift no tiene el dato (ej. `banco`), asigna `null` o un valor por defecto. NO inventes getters en el objeto `data`.
2.  **`toCompanion`**:
    *   Usa `NombresTablaCompanion.insert(...)`.
    *   Pasa SOLO las columnas que existen en `database.dart`.
    *   Asegúrate de envolver en `Value(...)` los campos que pueden ser nulos o que son opcionales en el insert.

### PASO 2: Corregir DataSources (Companions)
Ve a los archivos `_local_data_source.dart`.
1.  Busca todas las llamadas a `.insert(...)` o `.write(...)`.
2.  Verifica los argumentos nombrados.
    *   ❌ Incorrecto: `MovimientosCompanion.insert(saldoAnterior: ...)` (Si Drift no tiene esa columna).
    *   ✅ Correcto: `MovimientosCompanion.insert(codigo: ..., monto: ...)` (Solo columnas reales).
3.  Si necesitas un dato obligatorio (como `codigo` único) y no lo tienes, genéralo ahí mismo (ej. `'MOV-${DateTime.now().millisecondsSinceEpoch}'`).

### PASO 3: Limpiar Entities vs Models en Repositories
Ve a los archivos `_repository_impl.dart`.
1.  Asegúrate de que estás devolviendo Entidades, no Modelos.
    *   `return Right(model.toEntity())` es redundante si el Modelo ya extiende de la Entidad (como hicimos en `CajaModel`), así que `return Right(model)` funciona, PERO asegúrate de que el tipo de retorno coincida.
    *   Si usas `fromDrift`, ya tienes un objeto compatible con la Entidad.

### PASO 4: Imports Duplicados
Si ves errores como `'Caja' is defined in both...`:
1.  Ve al archivo del error.
2.  Importa Drift con alias: `import '../../core/database/database.dart' as db;`.
3.  Usa `db.Caja` (la clase de Drift) o `db.CajasCompanion` cuando interactúes con la BD.
4.  Usa `Caja` (tu entidad) para el resto de la app.

---

## ✅ Lista de Objetivos Inmediatos

1.  [x] **Configurar Router**: Navegación básica funcionando (Hecho).
2.  [ ] **Corregir `MovimientoModel`**: Eliminar referencias a `saldoAnterior/Nuevo` en `toCompanion` y manejar su ausencia en `fromDrift`.
3.  [ ] **Corregir `CajaLocalDataSource`**: Asegurar que los inserts de movimientos incluyan el campo `codigo` obligatorio.
4.  [ ] **Revisar `ClienteModel`**: Validar contra `database.dart`.
5.  [ ] **Revisar `PrestamoModel`**: Validar contra `database.dart`.
