# Rediseño Visual: Generación de Movimientos (Parte 1)

Este documento detalla los cambios visuales realizados y los requerimientos funcionales pendientes para completar la integración de la nueva interfaz.

## Cambios Realizados (Visual)
- **Layout Split-View**: Se implementó una estructura de dos columnas (70/30) para aprovechar pantallas grandes.
- **Segmented Control**: Nuevo selector de tipo de operación con estética moderna.
- **Cards de Sección**: Organización de campos en "Tipo de Operación" y "Detalles Financieros".
- **Sidebar de Impacto**: Panel derecho para visualización en tiempo real del impacto en caja.
- **Paleta de Colores**: Integración de tonos pizarra (`1E293B`), gris suave (`F1F5F9`) y violeta (`8B5CF6`) para una apariencia premium.

## Funcionalidades Pendientes (Parte 2)

Para que la vista sea 100% funcional con la nueva lógica visual, se debe integrar lo siguiente en `generar_movimiento_screen.dart`:

### 1. Cálculo de Impacto en Tiempo Real
- **Saldo Actual**: Debe conectarse al `cajaProvider` para mostrar el balance real de la caja seleccionada.
- **Delta (1.250,00)**: Debe actualizarse dinámicamente según el valor ingresado en el campo "Monto".
- **Nuevo Saldo**: Suma/Resta automática (`Saldo Actual` +/- `Monto`) dependiendo de si es Ingreso o Egreso.

### 2. Validaciones Visuales
- Cambiar el color del "Delta" y el icono a Verde (`10B981`) si la operación es un **Ingreso**.
- Mostrar advertencia en el Sidebar si el "Monto" supera el "Saldo Actual" (en caso de Egresos).

### 3. Integración de Selectores Reales
- **Caja de Origen/Destino**: Actualmente los dropdowns están integrados pero requieren refinamiento en el manejo de selección dual para Transferencias.
- **Categorías**: Sincronizar la lista de categorías con el backend o constantes globales.

### 4. Estado de Préstamo
- El panel de "Configuración del Préstamo" (cuando es Egreso -> Préstamo) debe mostrarse como un paso adicional debajo de los detalles financieros, manteniendo la coherencia visual.

## Consideraciones Técnicas
- **Responsive**: El layout de `Row` debe envolverse en un `MediaQuery` para colapsar en una sola columna en pantallas móviles.
- **Sync**: Asegurar que `_calcularPrestamo()` siga funcionando correctamente con el nuevo campo de Monto.

---
*Este rediseño prioriza la estética y la experiencia de usuario sin alterar la lógica de negocio subyacente.*
