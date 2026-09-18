-- =========================================================
-- Tarea1-API
-- Estudiante: Natalia Granados Rosales - 2021144286
-- Curso: Bases de datos II
-- Profesor: Cristian Agüero Campos
-- =========================================================

-- =========================================================
-- Pruebas
-- =========================================================
select top 5 CustomerID from Sales.SalesOrderHeader;
go

-- 1. Probar INSERT
exec Sales.AddCustomerRegister @StoreID =1028, @TerritoryID = 5;
go

-- 2. Probar SELECT
exec Sales.SelectCustomerRegister @CustomerID = 30117;
go

-- 3. Probar UPDATE
exec Sales.UpdateCustomerRegister @CustomerID = 30118, @TerritoryID = 2;
go

-- 4. Probar GET de tabla completa (con y sin filtro)
exec Sales.GetCustomers;
go
exec Sales.GetCustomers @TerritoryID = 3;
go

-- 5. Probar JOIN
exec Sales.GetCustomerOrders @CustomerID = 11000;
go
exec Sales.GetCustomerOrders; -- sin filtro, trae todo
go

-- 6. Probar DELETE
exec Sales.DeleteCustomerRegister @CustomerID = 30117;
go

-- 7. Probar casos de error 
exec Sales.SelectCustomerRegister @CustomerID = -1; -- debe decir "no existe"
exec Sales.AddCustomerRegister @TerritoryID = 999;  -- debe decir "territorio no existe"
go

