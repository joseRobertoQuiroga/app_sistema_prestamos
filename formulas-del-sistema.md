Fórmulas del Sistema de Préstamos
Este documento detalla todas las fórmulas matemáticas y lógica de negocio crítica utilizada en el proyecto.

1. Amortización de Préstamos
Ubicación: 
lib/features/prestamos/domain/usecases/generar_tabla_amortizacion.dart

Esta clase contiene la lógica principal para generar las tablas de pagos bajo dos modalidades: Interés Simple y Compuesto (Sistema Francés).

A. Interés Simple
Se calcula el interés total al inicio y se distribuye equitativamente junto con el capital.

Tasa Mensual ($r$): $$r = \frac{\text{Tasa Anual}}{100 \times 12}$$
Interés Total ($I_{total}$): $$I_{total} = \text{Monto} \times r \times \text{Plazo (meses)}$$
Monto Total ($M_{total}$): $$M_{total} = \text{Monto} + I_{total}$$
Cuota Mensual ($C$): $$C = \frac{M_{total}}{\text{Plazo}}$$
Capital por Cuota: $$\text{Capital} = \frac{\text{Monto}}{\text{Plazo}}$$
Interés por Cuota: $$\text{Interés} = \frac{I_{total}}{\text{Plazo}}$$
B. Interés Compuesto (Sistema Francés)
Se utiliza para calcular una cuota fija donde la proporción de interés disminuye y el capital aumenta con cada pago.

Cuota Fija ($R$): $$R = P \times \frac{r(1+r)^n}{(1+r)^n - 1}$$ Donde:

$P$ = Monto del Préstamo
$r$ = Tasa de interés mensual ($\frac{\text{Tasa Anual}}{100 \times 12}$)
$n$ = Plazo en meses
Desglose de Cuota (mes $i$):

Interés ($I_i$): $\text{Saldo Pendiente}_{i-1} \times r$
Capital ($K_i$): $R - I_i$
Nuevo Saldo: $\text{Saldo Pendiente}_{i-1} - K_i$
2. Cálculo de Mora
Ubicación: 
lib/features/prestamos/domain/usecases/cuota_usecases.dart
 (Clase 
CalcularMoraCuota
)

Calcula la penalización por atraso en el pago de una cuota.

Tasa de Mora Diaria: 0.5% (Valor fijo en código)
Días de Mora: Diferencia de días entre Fecha Actual y Fecha de Vencimiento.
Fórmula: $$\text{Mora} = (\text{Saldo de Cuota} \times \frac{0.5}{100}) \times \text{Días de Atraso}$$
3. Totales y Resúmenes
A. Totales del Préstamo (Pre-cálculo)
Ubicación: 
lib/features/prestamos/domain/usecases/generar_tabla_amortizacion.dart
 (Método 
calcularTotales
)

Se utiliza para mostrar una vista previa rápida antes de generar toda la tabla.

Interés Simple: Suma directa del interés total calculado previamente.
Interés Compuesto: $$M_{total} = \text{Cuota Fija} \times \text{Plazo}$$ $$I_{total} = M_{total} - \text{Monto Original}$$
B. Estadísticas de Cuotas
Ubicación: 
lib/features/prestamos/domain/usecases/cuota_usecases.dart
 (Clase 
GetResumenCuotas
)

Agrega los valores de todas las cuotas asociadas a un préstamo.

Monto Pendiente: Suma de saldoCuota de cuotas no pagadas.
Porcentaje Pagado: $$% \text{Pagado} = (\frac{\text{Monto Pagado}}{\text{Monto Total}}) \times 100$$
C. Estado del Préstamo
Ubicación: 
lib/features/prestamos/domain/entities/prestamo.dart

Propiedades calculadas en la entidad 
Prestamo
.

Porcentaje Pagado: Misma fórmula que en el resumen de cuotas.
Monto Pagado: Monto Total - Saldo Pendiente
4. Validaciones de Datos
Ubicación: 
lib/core/utils/validators.dart

Reglas de negocio para asegurar la integridad de los datos de entrada.

Monto: Debe ser mayor a 0 y estar dentro de los rangos definidos en AppConstants (Min/Max prestamo).
Tasa de Interés:
Mínimo: AppConstants.minTasaInteres
Máximo: AppConstants.maxTasaInteres
Plazo:
Mínimo: AppConstants.minPlazoMeses (1 mes)
Máximo: AppConstants.maxPlazoMeses (360 meses)
Documento de Identidad: Longitud entre 5 y 15 dígitos.
Teléfono: Longitud definida en AppConstants (Min/Max telefono).
5. Resumen de Ubicaciones Clave
Concepto	Archivo	Responsabilidad
Amortización	
generar_tabla_amortizacion.dart
Algoritmos Francés y Simple
Mora	
cuota_usecases.dart
Cálculo de intereses punitorios
Totales	
generar_tabla_amortizacion.dart
Proyecciones generales
Validación	
validators.dart
Reglas de entrada de datos