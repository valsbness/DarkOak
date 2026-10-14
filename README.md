# Dark Oak — Registro interno

Panel responsive en español para administrar miembros, ausencias, notas y cuotas semanales de 300 bolsitas, con base de datos compartida y autenticación de Supabase.

## Funciones
- Inicio de sesión por correo y contraseña; no hay formulario público de registro.
- Fichas de miembros: nombre IC, edad, Discord, ID de Discord, fecha de ingreso y estado.
- Marcar ausencias en ámbar; reactivar miembros; dar de baja sin borrar su historial.
- Notas internas/disciplinarias con fecha y categoría.
- Cuotas de 300 bolsitas por miembro y semana, registro de entregas y consulta histórica.
- Diseño adaptable a celular y computadora, negro/marrón/bronce.

## Configuración de base de datos y acceso
1. Crea un proyecto en https://supabase.com/ y guarda su Project URL y Publishable/anon key.
2. En Supabase → SQL Editor, ejecuta el archivo `schema.sql` completo.
3. En Authentication → Providers, deja habilitado Email. En Authentication → Settings, desactiva los registros públicos (Allow new users to sign up), si la opción aparece en tu versión.
4. En Authentication → Users, crea manualmente las cuentas de cada jefe/subjefe autorizado. No compartas contraseñas por Discord.
5. Edita `app.js` y reemplaza `PEGA_AQUI_TU_PROJECT_URL` y `PEGA_AQUI_TU_PUBLISHABLE_O_ANON_KEY` por los datos de Project Settings → API. Usa únicamente la publishable/anon key en el navegador; nunca uses `service_role`/secret key.
6. Publica los tres archivos (`index.html`, `app.js`, `schema.sql` puede quedarse en el repositorio) en un hosting HTTPS estático como GitHub Pages. `schema.sql` no necesita publicarse para que funcione; puedes excluirlo del sitio si prefieres.
7. En Supabase Authentication → URL Configuration, añade la URL del sitio a Site URL y Redirect URLs.

## Importante sobre permisos
La configuración inicial permite acceso a cualquier usuario autenticado en ese proyecto. Por eso, crea solo cuentas de jefes/subjefes y desactiva el registro público. Para roles diferenciados (por ejemplo, jefe puede borrar notas y subjefe solo editar), conviene añadir una tabla de roles y políticas RLS más específicas antes de abrir el acceso.

## Cuotas y semanas
La aplicación usa semanas de lunes a sábado para mostrar el periodo y guarda cada periodo bajo su fecha de inicio (lunes). El domingo inicia la semana siguiente. Las cuotas de semanas anteriores se mantienen. La cuota se genera automáticamente al abrir el control semanal para cada miembro no retirado.
