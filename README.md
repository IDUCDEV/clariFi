# Clarifi App - App de Finanzas Personales

Clarifi es una aplicación móvil para la gestión de finanzas personales (PFM) diseñada para iOS y Android. Permite a los usuarios registrar ingresos y gastos, gestionar categorías, crear presupuestos, visualizar gráficos mensuales y recibir alertas.

## Stack Tecnológico

- **Backend**: Supabase (PostgreSQL + Auth + Realtime + Storage)
- **Frontend**: Flutter
- **Arquitectura**: MVVM (Model-View-ViewModel)
- **Gestión de Estado**: Provider
- **Navegación**: go_router

## Características Principales

### Onboarding y Autenticación
- Creación de cuenta con email/contraseña.
- Creación de un perfil de usuario básico al iniciar (nombre, moneda).

### Registro de Transacciones
- Agregar gastos/ingresos con categoría, nota y fecha.
- Editar y eliminar transacciones.
- Marcar transacciones como recurrentes.

### Cuentas y Saldos
- Crear y gestionar múltiples cuentas (efectivo, banco, tarjeta, etc.).
- Visualizar el saldo por cuenta y el saldo total consolidado.

### Presupuestos y Alertas
- Establecer presupuestos mensuales por categoría o globales.
- Recibir alertas cuando un presupuesto supera un umbral (ej. 80%).

### Visualización
- Gráficos mensuales de gastos/ingresos por categoría y cuenta.
- Filtros para transacciones por fecha, categoría y cuenta.

### Exportación
- Exportar transacciones y reportes en formato CSV.

## Arquitectura

### Backend (Supabase)

La base de datos en PostgreSQL se estructura en las siguientes tablas principales:

- `users`: Almacena el perfil público del usuario (nombre, moneda, etc.). Se sincroniza con `auth.users` de Supabase.
- `accounts`: Cuentas o monederos del usuario.
- `categories`: Categorías para ingresos, gastos y transferencias.
- `transactions`: Registros de todos los movimientos financieros.
- `budgets`: Presupuestos definidos por el usuario.
- `notifications`: Notificaciones para alertas de presupuesto, etc.
- `exports`: Registros de los archivos exportados (CSV/PDF).

La seguridad se gestiona a través de **Políticas de Seguridad a Nivel de Fila (RLS)**, asegurando que cada usuario solo pueda acceder a su propia información.

### Frontend (Flutter)

Se sigue una arquitectura MVVM con la siguiente estructura de directorios:

```
lib/
└── src/
    ├── models/         # Modelos de datos (POJOs con fromJson/toJson)
    ├── viewmodels/     # Lógica de negocio y estado (extienden ChangeNotifier)
    ├── views/          # Widgets puros que consumen los ViewModels
    ├── services/       # Servicios para interactuar con APIs (Supabase)
    ├── routes/         # Configuración de navegación (go_router)
    └── widgets/        # Widgets reutilizables
```

- **Models**: Clases simples que representan los datos de la aplicación.
- **ViewModels**: Orquestan la lógica de negocio, gestionan el estado de una vista y se comunican con los servicios.
- **Views**: Widgets que reaccionan a los cambios en los ViewModels y renderizan la UI.
- **Services**: Clases que encapsulan la comunicación con servicios externos, como Supabase.

## Configuración del Proyecto

### 1. Backend (Supabase)

1.  **Crear Proyecto en Supabase**: Ve a [supabase.com](https://supabase.com/) y crea un nuevo proyecto.
2.  **Ejecutar Script SQL**:
    - Ve al `SQL Editor` en el dashboard de tu proyecto.
    - Abre el archivo `supabase_schema.sql` que se encuentra en la raíz de este repositorio.
    - Copia todo el contenido, pégalo en el editor y ejecútalo.
    - Esto creará todas las tablas, relaciones, funciones y políticas de seguridad necesarias.

### 2. Frontend (Flutter)

1.  **Instalar Dependencias**:
    ```sh
    flutter pub get
    ```
2.  **Configurar Variables de Entorno**:
    - Renombra el archivo `.env.example` a `.env`.
    - Abre el archivo `.env` y reemplaza los valores con tu **URL de Supabase** y tu **Clave anónima (anon key)**. Puedes encontrar estos valores en el dashboard de tu proyecto de Supabase, en la sección `Project Settings > API`.
    ```
    SUPABASE_URL=https://tu-id-de-proyecto.supabase.co
    SUPABASE_ANON_KEY=tu-clave-anonima
    ```
3.  **Ejecutar la Aplicación**:
    ```sh
    flutter run
    ```