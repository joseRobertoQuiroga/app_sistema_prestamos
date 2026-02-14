# Documentación de Fórmulas Matemáticas - Sistema de Préstamos

Este documento detalla las fórmulas matemáticas utilizadas en el módulo de préstamos, explicando su contexto y funcionamiento. Se ha elaborado tras revisar el código fuente para esclarecer las incongruencias observadas en la tabla de amortización y para validar su correcto comportamiento.

## 1. Tipos de Amortización

El sistema implementa dos métodos de cálculo de intereses. Es crucial notar que el concepto de **"Saldo"** se interpreta de manera distinta en cada uno, lo que puede causar confusión si se comparan directamente.

### A. Interés Simple (Método de Tasa Plana / "Flat Rate")

En esta implementación, el interés total se calcula al inicio sobre el monto original y se suma al capital prestado. Este método es común en préstamos de consumo rápido, informales o microcréditos.

**Fórmulas:**
1.  **Interés Total ($I$):**
    $$I = P \times r \times n$$
    *   $P$: Monto del préstamo (Principal).
    *   $r$: Tasa de interés simple mensual ($\text{Tasa Anual} / 12 / 100$).
    *   $n$: Plazo en meses.
2.  **Monto Total Adeudado ($MT$):**
    $$MT = P + I$$
3.  **Cuota Mensual ($C$):**
    $$C = MT / n$$

**Distribución de la Cuota:**
*   **Capital:** $P / n$ (Constante durante todo el plazo).
*   **Interés:** $I / n$ (Constante durante todo el plazo).

**Interpretación del "Saldo":**
*   En este método, la columna **Saldo** representa el **Total Adeudado (Capital + Interés Futuro)**.
*   El Saldo inicial es $MT = P + I$. Disminuye en $C$ cada mes hasta llegar a 0.

---

### B. Interés Compuesto (Sistema Francés)

Este es el método estándar utilizado por bancos y entidades financieras formales. La cuota es fija, pero la composición de capital e interés varía cada mes. El interés se calcula sobre el saldo pendiente del capital, no sobre el monto original.

**Fórmulas:**
1.  **Cuota Mensual ($C$):**
    $$C = P \times \frac{r(1+r)^n}{(1+r)^n - 1}$$
    *   $P$: Monto del préstamo.
    *   $r$: Tasa de interés mensual.
2.  **Interés del Periodo ($I_i$):**
    $$I_i = \text{SaldoAnterior} \times r$$
3.  **Amortización de Capital ($K_i$):**
    $$K_i = C - I_i$$

**Interpretación del "Saldo":**
*   En este método, la columna **Saldo** representa únicamente el **Capital Pendiente (Principal)**.
*   El Saldo inicial es $P$. Disminuye en $K_i$ (parte de capital de la cuota) cada mes.

> **Nota sobre Incongruencias:**
> La diferencia observada en las tablas de amortización se debe a la naturaleza de los métodos:
> *   En **Interés Simple**, el cliente ve una deuda total fija desde el inicio (que incluye todos los intereses).
> *   En **Interés Compuesto**, el cliente ve solo el capital restante, y los intereses se generan mes a mes.
> **Importante:** Ambos cálculos son matemáticamente correctos para su respectivo modelo.

---

## 2. Cálculo de Mora (Penalización por Atraso)

La mora se calcula como una penalización diaria sobre el monto de la cuota vencida.

**Fórmula:**
$$Mora = \text{SaldoCuota} \times \frac{\% \text{TasaDiaria}}{100} \times \text{DíasDeAtraso}$$

*   **SaldoCuota:** Lo que falta pagar de esa cuota específica ($Cuota - Pagado$).
*   **TasaDiaria:** Configurada en el sistema (por defecto suele ser 0.5% o similar).
*   **DíasDeAtraso:** Diferencia en días entre la Fecha Actual y la Fecha de Vencimiento.

---

## 3. Jerarquía de Aplicación de Pagos

Al registrar un pago, el sistema aplica el monto abonado en un orden estricto ("Cascada") para asegurar el cobro de penalidades e intereses antes que el capital.

**Orden de Prelación:**
1.  **Mora:** Primero se cubren las multas generadas por atrasos.
2.  **Interés:** Luego se cubren los intereses devengados de la cuota.
3.  **Capital:** Finalmente, el remanente reduce el saldo de capital de la cuota.

Este mecanismo incentiva el pago puntual, ya que los abonos parciales en mora apenas reducen la deuda real si no cubren primero las penalidades.
