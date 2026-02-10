# Sistema de Gestión de Préstamos

> Sistema integral de gestión financiera para administración de préstamos, clientes, pagos, cajas y reportes con interfaz moderna y modo oscuro.

---

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Características Principales](#-características-principales)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Módulos y Funcionalidades](#-módulos-y-funcionalidades)
- [Componentes Visuales](#-componentes-visuales)
- [Tecnologías Utilizadas](#-tecnologías-utilizadas)
- [Instalación y Configuración](#-instalación-y-configuración)
- [Guía de Uso](#-guía-de-uso)

---

## 🎯 Descripción General

El **Sistema de Gestión de Préstamos** es una aplicación de escritorio desarrollada en Flutter que permite la administración completa del ciclo de vida de préstamos financieros, desde la gestión de clientes hasta el control de cajas y  generación de reportes.

### Características Únicas
- ✨ **Interfaz moderna** con diseño glassmorphism y gradientes
- 🌓 **Modo oscuro completo** con cambio dinámico
- 📊 **Dashboard optimizado** sin scroll innecesario
- 🎨 **Animaciones suaves** para mejor experiencia de usuario
- 💾 **Persistencia local** con SQLite
- �� **Arquitectura limpia** siguiendo principios SOLID

---

## ⚡ Características Principales

### 1. Gestión Financiera Integral
- Control total de cartera de préstamos
- Seguimiento de pagos y cuotas
- Gestión de múltiples cajas
- Transferencias entre cajas
- Cálculo automático de intereses y mora

### 2. UI/UX Optimizada
- **Dashboard compacto**: Layout 65/35 con KPIs visibles sin scroll
- **Tabs inteligentes**: Alertas, vencimientos y accesos rápidos
- **Tema dinámico**: Cambio instantáneo entre modo claro y oscuro
- **Animaciones fluidas**: Efectos de fade-in y slide con delays escalonados

### 3. Reportería Avanzada
- Generación de reportes en PDF y Excel
- Múltiples tipos: Cartera, Mora, Cajas, Pagos
- Filtros por período
- Importación de datos desde Excel
- Plantilla de Excel para importación

### 4. Control de Mora
- Alertas automáticas de vencimientos
- Clasificación por días de atraso
- Cálculo de intereses moratorios
- Vista detallada de préstamos en mora

---

## 🏗 Arquitectura del Sistema

El sistema está construido con **Clean Architecture** y **Domain-Driven Design (DDD)**, organizándose en capas claramente definidas:

```
lib/
├── core/                          # Núcleo del sistema
│   ├── theme/                     # Sistema de temas
│   │   └── app_theme.dart        # Definición de temas claro/oscuro
│   ├── providers/                 # Providers globales
│   │   └── theme_provider.dart   # Gestión de estado del tema
│   ├── utils/                     # Utilidades
│   │   ├── formatters.dart       # Formato de moneda, fechas
│   │   └── validators.dart       # Validaciones de formularios
│   └── database/                  # Base de datos
│       └── database_helper.dart  # SQLite helper
│
├── features/                     # Módulos por funcionalidad
│   ├── dashboard/               # Dashboard principal
│   │   ├── domain/              # Lógica de negocio
│   │   ├── data/                # Acceso a datos
│   │   └── presentation/        # UI
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   │
│   ├── clientes/                # Gestión de clientes
│   ├── prestamos/               # Gestión de préstamos
│   ├── pagos/                   # Registro de pagos
│   ├── caja/                    # Gestión de cajas
│   └── reportes/                # Generación de reportes
│
├── presentation/                # Componentes compartidos
│   ├── widgets/                # Widgets reutilizables
│   │   ├── app_drawer.dart    # Menú lateral
│   │   ├── custom_button.dart # Botones personalizados
│   │   └── custom_text_field.dart
│   └── navigation/            # Navegación
│       └── app_router.dart
│
└── config/                    # Configuración
    ├── theme/                # Tema legacy
    └── router/               # Router legacy
```

### Capas de Clean Architecture

**1. Domain (Dominio)**
- `entities/`: Modelos de negocio puros
- `usecases/`: Casos de uso / lógica de negocio
- `repositories/`: Interfaces de repositorios

**2. Data (Datos)**
- `datasources/`: Fuentes de datos (local/remoto)
- `repositories/`: Implementaciones de repositorios
- `models/`: Modelos de datos con serialización

**3. Presentation (Presentación)**
- `screens/`: Pantallas de la app
- `widgets/`: Componentes UI
- `providers/`: Estado con Riverpod

---

## 📱 Módulos y Funcionalidades

### 1. Dashboard

**Pantalla principal del sistema con vista general de las métricas clave.**

#### Funcionalidades
- **KPIs Compactos** (Grid 2x3):
  - Cartera Total
  - Capital por Cobrar
  - Intereses Ganados
  - Saldo en Cajas
  - Préstamos Activos
  - Préstamos en Mora

- **Indicador de Salud**: Barra de progreso con porcentaje de salud de cartera

- **Sistema de Tabs**:
  - **Alertas**: Notificaciones de préstamos vencidos o por vencer
  - **Vencimientos**: Próximos 30 días de vencimientos de cuotas
  - **Accesos Rápidos**: Grid 2x2 con navegación a secciones principales

#### Elementos Visuales
- Gradientes en iconos de KPI
- Animaciones de fade-in escalonadas
- Badges con contadores en tabs
- Colores codificados por tipo de métrica
- Pull-to-refresh para actualizar datos

---

### 2. Clientes

**Módulo de gestión completo de la cartera de clientes.**

#### Funcionalidades
- **Listado de Clientes**:
  - Vista en tarjetas con información resumida
  - Búsqueda por nombre, CI o dirección
  - Filtros por estado
  - Ordenamiento múltiple

- **Formulario de Cliente**:
  - Datos personales completos
  - Validación de CI (Cédula de Identidad)
  - Información de contacto
  - Dirección detallada
  - Notas adicionales

- **Perfil de Cliente**:
  - Historial de préstamos
  - Estado de cuenta
  - Información de contacto
  - Opciones de edición/eliminación

#### Campos de Datos
| Campo | Tipo | Requerido |
|-------|------|-----------|
| Nombre Completo | Texto | Sí |
| CI | Número | Sí (único) |
| Teléfono | Número | Sí |
| Email | Email | No |
| Dirección | Texto | Sí |
| Fecha de Nacimiento | Fecha | No |
| Notas | Texto | No |

---

### 3. Préstamos

**Núcleo del sistema para gestión del ciclo de vida de préstamos.**

#### Funcionalidades
- **Listado de Préstamos**:
  - Vista por estado (Pendiente, Activo, Completado, Cancelado)
  - Filtros avanzados
  - Indicadores visuales de mora
  - Búsqueda rápida

- **Creación de Préstamo**:
  - Selección de cliente
  - Configuración de monto y plazo
  - Cálculo automático de cuotas
  - Elección de frecuencia de pago
  - Tasas de interés configurables
  - Selección de garante (opcional)

- **Detalles de Préstamo**:
  - Plan de pagos completo
  - Estado de cada cuota
  - Historial de pagos realizados
  - Saldo pendiente
  - Opciones de refinanciamiento

#### Tipos de Interés
- **Interés Simple**: Calculado sobre el capital inicial
- **Interés Compuesto**: Calculado sobre saldo pendiente

#### Frecuencias de Pago
- Diario
- Semanal
- Quincenal
- Mensual
- Anual

#### Estados del Préstamo
| Estado | Descripción | Color |
|--------|-------------|-------|
| Pendiente | Creado pero no desembolsado | Naranja |
| Activo | En curso de pago | Azul |
| Completado | Totalmente pagado | Verde |
| Cancelado | Cancelado antes de completar | Rojo |
| En Mora | Con pagos vencidos | Rojo |

---

### 4. Pagos

**Registro y seguimiento de todos los pagos realizados.**

#### Funcionalidades
- **Registro de Pago**:
  - Selección de préstamo y cuota
  - Monto a pagar (permite pagos parciales/adelantados)
  - Selección de caja destino
  - Fecha del pago
  - Método de pago
  - Comprobante/referencia

- **Listado de Pagos**:
  - Filtros por fecha, cliente, préstamo
  - Búsqueda por referencia
  - Exportación a Excel/PDF
  - Vista resumida y detallada

- **Detalles del Pago**:
  - Información completa
  - Préstamo asociado
  - Comprobante
  - Opciones de anulación (con permisos)

#### Métodos de Pago
- Efectivo
- Transferencia Bancaria
- Cheque
- Depósito
- Otros

---

### 5. Cajas

**Control de múltiples cajas y movimientos de efectivo.**

#### Funcionalidades
- **Gestión de Cajas**:
  - Crear/editar cajas
  - Activar/desactivar
  - Saldos en tiempo real
  - Límites configurables

- **Movimientos de Caja**:
  - Ingresos y egresos
  - Transferencias entre cajas
  - Concepto detallado
  - Comprobantes

- **Transferencias**:
  - Selector de caja origen/destino
  - Validación de saldo disponible
  - Vista previa de saldos resultantes
  - Registro automático de movimientos

- **Cierre de Caja**:
  - Cuadre automático
  - Resumen del día
  - Diferencias detectadas
  - Generación de reporte

#### Tipos de Movimiento
| Tipo | Categoría | Afecta Saldo |
|------|-----------|--------------|
| Desembolso Préstamo | Egreso | - |
| Pago de Cuota | Ingreso | + |
| Transferencia Salida | Egreso | - |
| Transferencia Entrada | Ingreso | + |
| Retiro | Egreso | - |
| Depósito | Ingreso | + |

---

### 6. Reportes

**Sistema avanzado de generación de reportes e importación de datos.**

#### Tipos de Reportes

**1. Cartera Completa**
- Resumen de todos los préstamos activos
- Desglose por cliente
- Totales de capital e intereses
- Estado de cada préstamo

**2. Mora Detallada**
- Préstamos con cuotas vencidas
- Clasificación por días de atraso
- Montos en mora
- Intereses moratorios calculados
- Datos de contacto de clientes

**3. Movimientos de Caja**
- Ingresos y egresos del período
- Saldos por caja
- Transferencias realizadas
- Balance general

**4. Resumen de Pagos**
- Todos los pagos del período
- Agrupación por método de pago
- Totales por cliente
- Cuotas cubiertas

#### Configuración de Reportes
- **Períodos**: Hoy, Semana, Mes, Trimestre, Año, Todo
- **Formatos**: PDF, Excel (.xlsx)
- **Filtros personalizados** por cada tipo

#### Importación de Datos
- Importación masiva de clientes desde Excel
- Plantilla descargable
- Validación de datos
- Reporte de errores y advertencias
- Vista previa antes de importar

---

## 🎨 Componentes Visuales

### Sistema de Temas

#### Tema Claro
```dart
Colores Primarios:
- Primary: #6366F1 (Indigo)
- Secondary: #8B5CF6 (Violet)
- Accent: #F59E0B (Amber)

Gradientes:
- Primario: #6366F1 → #8B5CF6
- Secundario: #F59E0B → #EF4444

Fondos:
- Background: #F8FAFC
- Surface: #FFFFFF
- Cards: #FFFFFF con sombra suave
```

#### Tema Oscuro
```dart
Colores Primarios:
- Primary: #818CF8 (Indigo claro)
- Secondary: #A78BFA (Violet claro)
- Accent: #FBBF24 (Amber claro)

Gradientes:
- Primario: #4F46E5 → #7C3AED
- Secundario: #F59E0B → #DC2626

Fondos:
- Background: #0F172A (Slate-900)
- Surface: #1E293B (Slate-800)
- Cards: #334155 (Slate-700) con elevación
```

### Componentes Reutilizables

#### 1. KPI Card
```dart
Características:
- Gradiente en ícono
- Título descriptivo
- Valor principal grande
- Subtítulo opcional
- Color temático
- Tap para detalles
```

#### 2. Custom Button
**Tipos disponibles:**
- **Primary**: Botón principal con gradiente
- **Secondary**: Botón secundario outlined
- **Text**: Botón de texto simple
- **Danger**: Botón de acción peligrosa (rojo)

**Estados:**
- Normal
- Pressed
- Disabled
- Loading (con spinner)

#### 3. Custom TextField
```dart
Características:
- Validación integrada
- Prefix/suffix icons
- Helper text
- Error states
- Contador de caracteres
- Formateo automático
- Compatibilidad tema oscuro
```

#### 4. App Drawer
```dart
Estructura:
- Header con gradiente
- Avatar/Icono del sistema
- Toggle de tema integrado
- Menú de navegación
- Items con indicador de selección
- Separadores visuales
```

### Animaciones

#### Dashboard
- **Fade-in escalonado**: KPIs aparecen con delays de 50ms
- **Slide-in**: Desde izquierda con efecto de rebote suave
- **Tab transitions**: Fade entre contenido de tabs

#### Listas
- **Staggered list**: Items aparecen progresivamente
- **Pull-to-refresh**: Indicador animado

#### Formularios
- **Error shake**: Campos con error vibran
- **Success bounce**: Confirmación con efecto de rebote

---

## 💻 Tecnologías Utilizadas

### Framework y Lenguaje
- **Flutter** 3.x - Framework multiplataforma
- **Dart** 3.x - Lenguaje de programación

### Estado y Arquitectura
- **Riverpod** 2.x - Gestión de estado reactivo
- **Go Router** - Navegación declarativa
- **Freezed** - Code generation para models inmutables
- **Dartz** - Programación funcional (Either)

### Base de Datos
- **SQLite** (via `sqflite`) - Base de datos local
- **Path Provider** - Rutas del sistema

### UI/UX
- **Google Fonts** - Tipografías (Poppins, Inter)
- **Flutter Animate** - Librería de animaciones
- **Shared Preferences** - Persistencia de configuración

### Reportes y Archivos
- **PDF** - Generación de PDFs
- **Excel** - Lectura/escritura de archivos Excel
- **File Picker** - Selector de archivos del sistema
- **Path Provider** - Gestión de rutas

### Utilidades
- **Intl** - Internacionalización y formatos
- **UUID** - Generación de IDs únicos

---

## 🚀 Instalación y Configuración

### Requisitos Previos
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Windows 10/11 (para compilación Windows)
- Visual Studio 2022 con C++ Desktop Development

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd prestamos_app
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar base de datos**
La base de datos SQLite se crea  automáticamente en el primer arranque.

4. **Ejecutar la aplicación**
```bash
# Modo debug
flutter run -d windows

# Modo release
flutter build windows
flutter run -d windows --release
```

### Configuración Inicial

**Primera ejecución:**
1. La app creará automáticamente la base de datos local
2. Se inicializará con una caja principal
3. El tema se establecerá en modo claro por defecto

---

## 📖 Guía de Uso

### Inicio Rápido

**1. Crear un Cliente**
```
1. Abrir drawer → Clientes
2. Click en botón flotante "+" 
3. Llenar formulario completo
4. Guardar
```

**2. Registrar un Préstamo**
```
1. Desde Dashboard → Préstamos
2. Botón "Nuevo Préstamo"
3. Seleccionar cliente
4. Configurar monto, plazo, interés
5. Revisar plan de pagos
6. Confirmar y desembolsar
```

**3. Registrar un Pago**
```
1. Desde Dashboard → Registrar Pago
2. Seleccionar préstamo
3. Elegir cuota a pagar
4. Ingresar monto
5. Seleccionar caja y método
6. Confirmar pago
```

**4. Cambiar Tema**
```
1. Abrir drawer lateral
2. Toggle "Modo Oscuro/Claro" en header
3. El cambio es instantáneo y persistente
```

**5. Generar Reporte**
```
1. Dashboard → Reportes
2. Seleccionar período y formato
3. Click en tipo de reporte deseado
4. El archivo se genera automáticamente
5. Opción de abrir directamente
```

### Casos de Uso Comunes

#### Transferencia entre Cajas
```
Escenario: Mover fondos de Caja Principal a Caja Sucursal

1. Ir a Cajas → Transferencias
2. Origen: Caja Principal
3. Destino: Caja Sucursal
4. Monto: Bs. 5,000
5. Descripción: "Fondos para operación sucursal"
6. Verificar vista previa
7. Confirmar transferencia
```

#### Importar Clientes desde Excel
```
1. Reportes → Tab "Maestros"
2. Click "Descargar Plantilla"
3. Llenar plantilla Excel con datos
4. "Seleccionar Archivo" → elegir Excel
5. Revisar vista previa
6. Confirmar importación
7. Ver resultado con errores/advertencias
```

---

## 📊 Modelos de Datos Principales

### Cliente
```dart
class Cliente {
  final int? id;
  final String nombre;
  final String ci;
  final String telefono;
  final String? email;
  final String direccion;
  final DateTime? fechaNacimiento;
  final String? notas;
  final bool activo;
  final DateTime fechaCreacion;
}
```

### Préstamo
```dart
class Prestamo {
  final int? id;
  final int clienteId;
  final double monto;
  final double tasaInteres;
  final int plazo;
  final TipoInteres tipoInteres;
  final FrecuenciaPago frecuencia;
  final DateTime fechaDesembolso;
  final DateTime fechaPrimeraCuota;
  final EstadoPrestamo estado;
  final double saldoPendiente;
  final int? garanteId;
  final String? notas;
}
```

### Pago
```dart
class Pago {
  final int? id;
  final int prestamoId;
  final int cuotaId;
  final double monto;
  final DateTime fecha;
  final MetodoPago metodoPago;
  final int cajaId;
  final String? referencia;
  final String? notas;
  final DateTime fechaRegistro;
}
```

### Caja
```dart
class Caja {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double saldo;
  final bool activa;
  final DateTime fechaCreacion;
  final double? limiteMaximo;
}
```

---

## 🔐 Seguridad y Validaciones

### Validaciones de Formularios
- **CI**: Formato y unicidad
- **Email**: Formato válido
- **Teléfono**: Solo números, longitud mínima
- **Montos**: Números positivos, decimales válidos
- **Fechas**: Rangos lógicos
- **Transferencias**: Saldo suficiente en origen

### Integridad de Datos
- **Foreign Keys** en base de datos
- **Transacciones atómicas** para operaciones financieras
- **Validación de saldos** antes de registrar movimientos
- **Prevención de duplicados** en clientes (CI único)

---

## 🎯 Próximas Mejoras

- [ ] **Optimización de Formularios** - Sistema de tabs para Préstamo y Cliente
- [ ] **Notificaciones** - Alertas push para vencimientos
- [ ] **Backup automático** - Respaldo periódico de base de datos
- [ ] **Multi-usuario** - Sistema de autenticación y permisos
- [ ] **Dashboard analytics** - Gráficos y tendencias
- [ ] **Impresión directa** - Imprimir comprobantes y reportes
- [ ] **Exportación masiva** - Backup completo en formato portable

---

## 📄 Licencia

Este proyecto es propiedad privada y está protegido  por derechos de autor. Todos los derechos reservados.

---

## 👥 Soporte

Para consultas o soporte técnico, contactar al equipo de desarrollo.

---

**Versión**: 1.0.0  
**Última actualización**: Febrero 2026  
**Plataforma**: Windows Desktop  
**Framework**: Flutter 3.x
