# 🧮 Guía de Cálculos y Fórmulas del Sistema

Este documento detalla la implementación técnica y validación de las fórmulas matemáticas utilizadas para el cálculo de intereses, amortizaciones y mora en el sistema.

---

## 1. Amortización de Préstamos

El sistema soporta dos modalidades fundamentales de cálculo de intereses, implementadas en `lib/features/prestamos/domain/usecases/generar_tabla_amortizacion.dart`.

### A. Interés Simple
En esta modalidad, el interés total se calcula al inicio sobre el monto original y se distribuye equitativamente entre todas las cuotas.

**Fórmula de Interés Total:**
$$I_{total} = P \times r \times n$$

**Donde:**
- $P$ = Monto del Préstamo (Principal).
- $r$ = Tasa de interés mensual ($\frac{\text{Tasa Anual}}{100 \times 12}$).
- $n$ = Plazo en meses.

**Distribución por Cuota:**
- **Capital:** $P / n$
- **Interés:** $I_{total} / n$
- **Cuota Mensual:** $(\text{Capital} + \text{Interés})$

---

### B. Interés Compuesto (Sistema Francés)
Es el sistema más común para préstamos bancarios, donde las cuotas son fijas. El interés se calcula sobre el **saldo pendiente**, por lo que al principio se paga más interés y menos capital, invirtiéndose esta relación al final del préstamo.

**Fórmula de Cuota Fija (R):**
$$R = P \times \frac{r(1+r)^n}{(1+r)^n - 1}$$

**Desglose Mensual (Mes $i$):**
1. **Interés del mes ($I_i$):** $\text{Saldo Pendiente}_{i-1} \times r$
2. **Capital del mes ($K_i$):** $R - I_i$
3. **Nuevo Saldo:** $\text{Saldo Pendiente}_{i-1} - K_i$

> [!NOTE]
> Esta lógica garantiza que el saldo llegue exactamente a cero al finalizar el plazo estipulado.

---

## 2. Cálculo de Mora (Intereses Punitorios)

La mora se aplica automáticamente a las cuotas vencidas y se calcula en base al saldo pendiente de la cuota y los días de atraso. Implementado en `lib/features/prestamos/domain/usecases/cuota_usecases.dart`.

**Configuración:**
- **Tasa de Mora Diaria:** 0.5% (fija en el sistema).

**Fórmula:**
$$\text{Mora} = (\text{Saldo de Cuota} \times \frac{0.5}{100}) \times \text{Días de Atraso}$$

**Reglas de Aplicación:**
- Solo aplica si `fecha_actual > fecha_vencimiento`.
- Solo aplica sobre el capital/interés pendiente de la cuota (no sobre cuotas ya pagadas).

---

## 3. Resumen de Totales

Para la vista previa del préstamo, el sistema proyecta los totales finales:

| Concepto | Interés Simple | Interés Compuesto |
| :--- | :--- | :--- |
| **Monto Total** | $P + I_{total}$ | $\text{Cuota Fija} \times n$ |
| **Interés Total** | $P \times r \times n$ | $\text{Monto Total} - P$ |
| **Cuota Mensual** | $\text{Monto Total} / n$ | $\text{Cuota Fija}$ |

---

## 🛠 Verificación Técnica

- **Precisión Decimal:** Se utiliza el tipo `double` para cálculos intermedios y se manejan truncamientos controlados para evitar errores de redondeo acumulado.
- **Validación de Datos:** Los casos de uso incluyen guardas para evitar montos negativos, plazos de 0 meses o tasas de interés fuera de rango (0-100%).
- **Persistencia:** Todos los valores calculados se almacenan en la tabla `cuotas` para asegurar que el historial no dependa de re-cálculos dinámicos que podrían variar por cambios de tasa futura.
