# miCunda — Manual de usuario
**Versión 2.0 · micunda.es**

---

## ¿Qué es miCunda?

miCunda es una app para grupos de personas que comparten coche para ir al trabajo. Registra quién conduce cada día, lleva la cuenta automáticamente y te dice a quién le toca conducir para que el reparto sea siempre justo.

Cada grupo es una **cunda**. Dentro de cada cunda hay un **administrador** (quien la crea y gestiona) y uno o varios **editores** (el resto de miembros).

---

## GUÍA RÁPIDA — TODOS LOS USUARIOS

### Acceder a la app
1. Abre **micunda.es** en el navegador del móvil
2. Escribe tu **email** y **contraseña** (te los facilita el administrador)
3. Pulsa **Entrar**

> 💡 Consejo: en Android, abre Chrome → menú → "Añadir a pantalla de inicio" para tenerla como si fuera una app instalada.

---

### Las 3 pestañas principales

#### 📋 Registro
Aquí se registra el viaje del día.

1. **Marca quién viene hoy** — desmarca a las personas que no vienen
2. La app muestra una **sugerencia** (el nombre en grande, fondo azul): es quien menos veces ha conducido en ese grupo concreto
3. Pulsa el botón del **conductor** para registrar el viaje
4. Confirma en el mensaje que aparece

> El contador de viajes debajo de cada nombre se actualiza en tiempo real según quién hayas marcado como presente.

> ⚠️ Solo puedes registrar un viaje en el que vayas tú — como conductor o como pasajero. Si no estás marcado como presente, la app no permitirá el registro.

---

#### 📊 Cuadrante
Tabla visual con todos los viajes registrados.

- Cada **bloque** representa una combinación de personas que van juntas
- Las **filas** son los miembros, las **columnas** son los viajes (con fecha)
- El número entre paréntesis junto a cada nombre es cuántas veces ha conducido en ese bloque
- Los miembros que ya no están en la cunda aparecen con el nombre **tachado**

Al final del cuadrante puedes ver los **cuadrantes eliminados** (bloques que el administrador ha ocultado pero que siguen guardados).

---

#### 🕐 Historial
Lista de los últimos 20 viajes registrados, con fecha, conductor, pasajeros y quién lo registró o modificó.

**Permisos de edición y borrado:**

| Acción | Conductor | Pasajero | No participó | Administrador |
|--------|-----------|----------|--------------|---------------|
| ✏️ Editar | ✅ | ✅ | ❌ | ✅ |
| 🗑️ Eliminar | ✅ | ❌ | ❌ | ✅ |

- Solo los participantes del viaje (conductor y pasajeros) pueden editarlo
- Solo el conductor o el administrador pueden eliminarlo
- Los viajes eliminados quedan registrados con quién los eliminó y cuándo — no se borran definitivamente

---

### Aviso de novedades
Cuando abres la app o vuelves de tenerla en segundo plano, aparece automáticamente un aviso si desde tu última visita alguien ha **registrado**, **editado** o **eliminado** un viaje en el que ibas.

Ejemplos:
- *▶ Juan registró el 12/05 (eras el **conductor**)*
- *▶ María editó el viaje del 10/05 (ibas de pasajero)*
- *▶ Pedro eliminó el viaje del 08/05 (eras el **conductor**)*

Pulsa **Entendido** para cerrar el aviso.

---

### Email semanal
**Un día a la semana a las 17:00** recibirás un email con:
- Resumen de los viajes de esa semana
- Tu cuadrante de viajes (solo los bloques en los que participas)
- Listado de modificaciones realizadas esa semana sobre viajes ya registrados — si no hay ninguna, indica *"No hay modificaciones de registro esta semana"*

Sirve también como copia de seguridad por si la app no estuviera disponible.

---

---

## GUÍA DEL ADMINISTRADOR

El administrador tiene acceso a todo lo anterior más la pestaña **⚙️ Admin**, y recibe el cuadrante completo (todos los bloques) en el email semanal.

---

### Crear una cunda (primera vez)
1. Entra en **micunda.es**
2. Pestaña **"Crear mi cunda"**
3. Rellena:
   - **Nombre de la cunda** (ej: "Cunda del trabajo")
   - **Tu nombre** — como aparecerá en el cuadrante (ej: "Francis")
   - **Tu email**
   - **Contraseña**
4. Pulsa **Crear cunda**

La app entra automáticamente y ya eres el administrador.

---

### Añadir miembros
1. Ve a **Admin** → pulsa **Añadir miembro**
2. Rellena:
   - **Nombre** — como aparecerá en el cuadrante (tiene que ser único, no puede repetirse aunque haya dado de baja a alguien con ese nombre)
   - **Email** — dirección de correo del miembro
   - **Contraseña** — la que le asignes (puede cambiarla después)
   - **Rol** — Editor (lo normal) o Administrador
   - **Fecha de incorporación** — importante: los viajes anteriores a esta fecha no se contarán para este miembro
3. Pulsa **Añadir**
4. Comparte con el nuevo miembro su email y contraseña para que pueda entrar

> ⚠️ Si pones un nombre que ya existe en la cunda (activo o eliminado) la app te avisará para evitar confusiones en el cuadrante.

---

### Importar viajes anteriores
Si tu cunda ya llevaba tiempo funcionando antes de usar miCunda, puedes introducir los viajes antiguos para que los contadores sean correctos desde el principio.

1. Ve a **Admin** → pulsa **Importar viajes anteriores**
2. Para cada viaje:
   - Selecciona la **fecha**
   - Selecciona el **conductor**
   - Marca quién **vino ese día**
   - Pulsa **Guardar y añadir otro**
3. La fecha retrocede un día automáticamente para facilitar la entrada
4. Cuando termines pulsa **Cerrar**

> 💡 Empieza por el viaje más reciente e ir hacia atrás — así la fecha va bajando sola.

---

### Eliminar un miembro
Cuando alguien deja la cunda:

1. Ve a **Admin** → pulsa el icono 🗑️ junto a su nombre
2. Confirma la eliminación

El miembro ya no podrá entrar a la app, pero sus viajes históricos se conservan en el historial y en el cuadrante (aparecerá con el nombre tachado).

---

### Gestionar bloques del cuadrante
Con el tiempo pueden aparecer bloques que ya no tienen sentido (ej: una combinación de personas que ya no se va a repetir).

**Ocultar un bloque:**
1. En el **Cuadrante**, pulsa el icono 🗑️ en la esquina del bloque
2. Confirma → el bloque desaparece para todos los miembros

**Ver bloques de otros miembros:**
Como administrador, al final del cuadrante aparece **"Ver cuadrantes de otros miembros"** — muestra los bloques de viajes en los que tú no participaste, con opción de ocultarlos también.

**Restaurar un bloque oculto:**
Al final del cuadrante → **"Ver cuadrantes eliminados"** → pulsa **Restaurar** junto al bloque que quieras recuperar.

---

### Editar o borrar un viaje
En el **Historial**, el administrador puede editar o borrar cualquier viaje independientemente de quién lo registró:
- ✏️ **Editar** — cambia la fecha, el conductor o los asistentes
- 🗑️ **Eliminar** — borra el viaje (queda registrado quién lo eliminó y cuándo)

---

---

## Preguntas frecuentes

**¿Qué pasa si me equivoco al registrar un viaje?**
Ve al Historial, pulsa el lápiz ✏️ y corrígelo. Puedes editarlo si eras conductor o pasajero en ese viaje.

**¿Y si alguien se une a la cunda más tarde?**
El administrador le añade con la fecha de incorporación correcta. Los viajes anteriores a esa fecha no le afectan.

**¿Los datos se borran si la app falla?**
No. Todo está guardado en la nube. Además recibes el cuadrante completo una vez a la semana por email como copia de seguridad.

**¿Puedo usar miCunda desde el ordenador?**
Sí, funciona en cualquier navegador: móvil, tablet u ordenador.

**¿Cómo cambio mi contraseña?**
De momento el administrador debe hacerlo manualmente. Próximamente se añadirá la opción de cambiarla desde la propia app.

**¿Por qué no me aparecen los botones de editar o eliminar en el historial?**
Solo aparecen si participaste en ese viaje. El botón de eliminar además solo lo ve el conductor del viaje y el administrador.

---

*miCunda · micunda.es · Contacto: hola@micunda.es*
