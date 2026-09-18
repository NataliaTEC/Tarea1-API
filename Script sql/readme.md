# Stored Procedures – Sales.Customer / Sales.SalesOrderHeader

**Estudiante:** Natalia Granados Rosales
**Carné:** 2021144286
**Curso:** Bases de Datos II
**Profesor:** Cristian Agüero Campos

---

## Descripción general

Este script contiene los **6 stored procedures** utilizados por la API para realizar las operaciones CRUD sobre la tabla `Sales.Customer`, además de dos procedimientos de consulta: uno que retorna los registros de la tabla y otro que responde a una consulta con `JOIN` entre `Sales.Customer` y `Sales.SalesOrderHeader`.

Todos los procedimientos:
- Están dentro del schema `Sales`.
- Usan `SET NOCOUNT ON` para evitar mensajes de filas afectadas en la salida.
- Están envueltos en `TRY/CATCH`, devolviendo el error real (`ERROR_MESSAGE()`) en una columna `Message` si algo falla.
- Validan la existencia de las llaves foráneas (`PersonID`, `StoreID`, `TerritoryID`, `CustomerID`) antes de ejecutar la operación, devolviendo un mensaje descriptivo en `Message` cuando no existen.
- Muestran información legible (nombre de cliente, nombre de tienda, nombre de territorio) en vez de únicamente los IDs numéricos, mediante `LEFT JOIN`/`JOIN` con `Person.Person`, `Sales.Store` y `Sales.SalesTerritory`.

---

## 1. `Sales.AddCustomerRegister` (INSERT)

Crea un nuevo registro en `Sales.Customer`.

**Parámetros**

| Parámetro | Tipo | Obligatorio |
|---|---|---|
| `@PersonID` | int | No (default `null`) |
| `@StoreID` | int | No (default `null`) |
| `@TerritoryID` | int | No (default `null`) |

**Validaciones**
- Si `@PersonID` no es `null`, debe existir en `Person.Person`.
- Si `@StoreID` no es `null`, debe existir en `Sales.Store`.
- Si `@TerritoryID` no es `null`, debe existir en `Sales.SalesTerritory`.

**Retorna:** `Message`, `NewCustomerID`, `PersonID`, `StoreID`, `TerritoryID`, `AccountNumber`

**Ejemplo de ejecución**
```sql
exec Sales.AddCustomerRegister @StoreID = 1028, @TerritoryID = 5;
go
```

---

## 2. `Sales.UpdateCustomerRegister` (UPDATE)

Actualiza el `TerritoryID` de un cliente existente.

**Parámetros**

| Parámetro | Tipo | Obligatorio |
|---|---|---|
| `@CustomerID` | int | Sí |
| `@TerritoryID` | int | Sí |

**Validaciones**
- `@CustomerID` debe existir en `Sales.Customer`.
- `@TerritoryID` debe existir en `Sales.SalesTerritory`.

**Retorna:** `Message`, `CustomerID`, `Customer`, `Store`, `Territory`, `TerritoryID`, `AccountNumber`, `ModifiedDate`

**Ejemplo de ejecución**
```sql
exec Sales.UpdateCustomerRegister @CustomerID = <CustomerID>, @TerritoryID = <TerritoryID>;
go
```

---

## 3. `Sales.DeleteCustomerRegister` (DELETE)

Elimina un cliente existente y devuelve la información del registro ya eliminado.

**Parámetros**

| Parámetro | Tipo | Obligatorio |
|---|---|---|
| `@CustomerID` | int | Sí |

**Validaciones**
- `@CustomerID` debe existir en `Sales.Customer`.

**Retorna:** `Message`, `CustomerID`, `Store`, `Territory`, `AccountNumber`

> Nota: los datos legibles se capturan en variables **antes** de ejecutar el `DELETE`, ya que después de borrar la fila esa información ya no existe en la tabla.

**Ejemplo de ejecución**
```sql
exec Sales.DeleteCustomerRegister @CustomerID = <CustomerID>;
go
```

---

## 4. `Sales.SelectCustomerRegister` (SELECT puntual)

Consulta la información de un único cliente por su `CustomerID`.

**Parámetros**

| Parámetro | Tipo | Obligatorio |
|---|---|---|
| `@CustomerID` | int | Sí |

**Validaciones**
- `@CustomerID` debe existir en `Sales.Customer`.

**Retorna:** `CustomerID`, `Customer`, `Store`, `Territory`, `AccountNumber`, `ModifiedDate`

**Ejemplo de ejecución**
```sql
exec Sales.SelectCustomerRegister @CustomerID = <CustomerID>;
```

---

## 5. `Sales.GetCustomers` (SELECT de tabla completa)

Retorna todos los clientes, con filtro opcional por territorio.

**Parámetros**

| Parámetro | Tipo | Obligatorio |
|---|---|---|
| `@TerritoryID` | int | No (default `null`) |

**Validaciones**
- Si `@TerritoryID` no es `null`, debe existir en `Sales.SalesTerritory`.

**Retorna:** listado de `CustomerID`, `Customer`, `Store`, `Territory`, `AccountNumber`, `ModifiedDate`

**Ejemplo de ejecución**
```sql
-- Todos los clientes
exec Sales.GetCustomers;
go

-- Filtrado por territorio
exec Sales.GetCustomers @TerritoryID = <TerritoryID>;
go
```

---

## 6. `Sales.GetCustomerOrders` (SELECT con JOIN)

Retorna las órdenes de venta asociadas a uno o todos los clientes, mediante `JOIN` entre `Sales.Customer` y `Sales.SalesOrderHeader`.

**Parámetros**

| Parámetro | Tipo | Obligatorio |
|---|---|---|
| `@CustomerID` | int | No (default `null`) |

**Validaciones**
- Si `@CustomerID` no es `null`, debe existir en `Sales.Customer`.

**Retorna:** listado de `CustomerID`, `Customer`, `Territory`, `SalesOrderID`, `OrderDate`, `Status`, `TotalDue`

> Nota: el `JOIN` con `Sales.SalesOrderHeader` es `INNER JOIN` de forma intencional — solo deben aparecer clientes que sí tienen órdenes registradas.

**Ejemplo de ejecución**
```sql
-- Órdenes de todos los clientes
exec Sales.GetCustomerOrders;
go

-- Órdenes de un cliente específico
exec Sales.GetCustomerOrders @CustomerID = <CustomerID>;
go
```

---

## Tabla resumen

| # | Stored Procedure | Operación | Tabla(s) principal(es) |
|---|---|---|---|
| 1 | `Sales.AddCustomerRegister` | INSERT | `Sales.Customer` |
| 2 | `Sales.UpdateCustomerRegister` | UPDATE | `Sales.Customer` |
| 3 | `Sales.DeleteCustomerRegister` | DELETE | `Sales.Customer` |
| 4 | `Sales.SelectCustomerRegister` | SELECT | `Sales.Customer` |
| 5 | `Sales.GetCustomers` | SELECT (tabla completa) | `Sales.Customer` |
| 6 | `Sales.GetCustomerOrders` | SELECT (JOIN) | `Sales.Customer` + `Sales.SalesOrderHeader` |