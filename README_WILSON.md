# Documentación del Modelo "Interés Wilson"

Este documento detalla el funcionamiento, fórmulas y procedimientos de prueba para el nuevo tipo de préstamo **Interés Wilson**.

## 1. Descripción del Modelo

El modelo "Wilson" es un esquema de financiamiento diseñado para cobros mensuales de interés sobre el capital vigente, con flexibilidad en los pagos de capital.

### Diferencias Clave
| Característica | Préstamo Normal (Simple/Francés) | Préstamo Wilson |
|----------------|----------------------------------|-----------------|
| **Cuotas** | Fijas y pre-generadas (Tabla Amortización) | Dinámicas (No tiene tabla fija inicial) |
| **Interés** | Calculado anual / 12 | **Mensual directo** (Tasa % = cobro mensual) |
| **Base Cálculo** | Saldo pendiente | Saldo pendiente |
| **Mora** | Fija o % sobre cuota | `(Interés Mensual × Días Retraso) / 30` |
| **Vencimiento** | Definido por cada cuota | Mensual (basado en fecha inicio) |

---

## 2. Fórmulas Matemáticas

### A. Interés Mensual
El interés se calcula directamente multiplicando el saldo de capital actual por la tasa mensual.

```
Interés = SaldoCapital × (TasaInteres / 100)
```
*Ejemplo:* 
* Capital: 10,000
* Tasa: 5% mensual
* Interés del mes: 10,000 × 0.05 = **500**

### B. Mora Wilson
La mora se genera si el pago se realiza después de la fecha de corte mensual. Se calcula proporcionalmente a los días de retraso y se redondea siempre hacia arriba (entero superior).

```
MoraCalculada = (InterésMensual × DíasRetraso) / 30
MoraFinal = CEIL(MoraCalculada)
```
*Ejemplo:*
* Interés del mes: 500
* Retraso: 5 días
* Cálculo: (500 × 5) / 30 = 83.33
* **Mora a Cobrar: 84.00**

### C. Distribución del Pago (Cascada)
Todo pago recibido se distribuye en este orden estricto:
1. **Mora** (si existe)
2. **Interés** del mes corriente
3. **Capital** (reducción de deuda)

---

## 3. Flujos de Usuario

### Creación de Préstamo
1. Ir a "Nuevo Préstamo".
2. Seleccionar Cliente y Caja.
3. Ingresar Monto y Plazo.
4. En "Tipo de Amortización", seleccionar **WILSON**.
   * *Nota: La etiqueta de tasa cambiará a "Tasa/Mes (%)".*
5. El sistema mostrará un estimado del interés mensual, pero **no** generará una tabla de cuotas fija.

### Registro de Pago
1. Ir al detalle del préstamo Wilson.
2. Presionar "Registrar Pago".
3. El sistema detecta automáticamente que es Wilson:
   * Calcula el interés exacto hasta la fecha.
   * Verifica si hay retraso y calcula mora automática.
4. Al confirmar, el pago reduce el saldo de capital (después de cubrir mora e interés).

### Visualización (Tabla de Pagos)
En el detalle del préstamo, en lugar de la tabla de amortización tradicional, verá:
1. **Tabla de Pagos (Proyección):**
   * Vista previa mes a mes.
   * Muestra: Fecha, Interés esperado, Cuota estimada, Pago realizado, Mora y Estado.
2. **Historial de Pagos:**
   * Tabla real de lo que ha pagado el cliente.
   * Muestra la reducción real del saldo capital tras cada pago.
   * Opción de exportar a PDF.

---

## 4. Guía de Pruebas (Testing)

Para certificar el funcionamiento, realice los siguientes escenarios:

### Prueba 1: Pago Puntual (Solo Interés)
1. Crear préstamo: 1000 Bs, 10% Tasa Wilson.
2. Registrar Pago: Fecha = 1 mes después exacto.
3. Monto: 100 Bs.
4. **Resultado esperado:** 
   * Mora: 0
   * Interés: 100
   * Capital amortizado: 0
   * Saldo nuevo: 1000

### Prueba 2: Pago con Amortización
1. Usando el mismo préstamo.
2. Registrar Pago: 1 mes después.
3. Monto: 150 Bs.
4. **Resultado esperado:**
   * Interés: 100
   * Capital amortizado: 50
   * Saldo nuevo: 950

### Prueba 3: Pago con Mora
1. Préstamo: 1000 Bs, 10% Tasa (Interés mensual 100).
2. Registrar Pago: 1 mes + 15 días después.
3. Días retraso: 15.
4. Cálculo Mora: (100 × 15) / 30 = 50 Bs.
5. Pago realizado: 200 Bs.
6. **Resultado esperado:**
   * Mora: 50
   * Interés: 100
   * Capital amortizado: 50 (200 - 50 - 100)
   * Saldo nuevo: 950

---

## 5. Notas Técnicas para Soporte

* **Base de Datos:** Los préstamos Wilson tienen `tipoInteres = 'WILSON'`. No tienen registros en la tabla `cuotas` al crearse.
* **Reportes:** Los reportes de cartera y pagos son compatibles. El reporte de mora puede no mostrar préstamos Wilson a menos que se cambie el estado manualmente a MORA, ya que no tienen cuotas vencidas tradicionales.
