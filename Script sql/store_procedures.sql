-- =========================================================
-- Tarea1-API
-- Estudiante: Natalia Granados Rosales - 2021144286
-- Curso: Bases de datos II
-- Profesor: Cristian Agüero Campos
-- =========================================================

-- =========================================================
-- 1. Agregar registro de cliente (INSERT)
-- =========================================================
drop procedure if exists Sales.AddCustomerRegister
go

create procedure Sales.AddCustomerRegister
    @PersonID int = null,
    @StoreID int = null,
    @TerritoryID int = null
as
begin
    set nocount on
    begin try
        if @PersonID is not null and not exists (
            select 1 from Person.Person where BusinessEntityID = @PersonID
        )
        begin
            select 'El PersonID proporcionado no existe' as Message
            return
        end

        if @StoreID is not null and not exists (
            select 1 from Sales.Store where BusinessEntityID = @StoreID
        )
        begin
            select 'El StoreID proporcionado no existe' as Message
            return
        end

        if @TerritoryID is not null and not exists (
            select 1 from Sales.SalesTerritory where TerritoryID = @TerritoryID
        )
        begin
            select 'El TerritoryID proporcionado no existe' as Message
            return
        end

        declare @NewCustomerID int

        insert into Sales.Customer (PersonID, StoreID, TerritoryID, rowguid, ModifiedDate)
        values (@PersonID, @StoreID, @TerritoryID, newid(), getdate())

        set @NewCustomerID = scope_identity()
        select 
            'Cliente creado correctamente' as Message,
            @NewCustomerID as NewCustomerID,
            c.PersonID,
            c.StoreID,
            c.TerritoryID,
            c.AccountNumber
        from Sales.Customer c
        where c.CustomerID = @NewCustomerID
    end try
    begin catch
        select error_message() as Message
    end catch
end
go

-- =========================================================
-- 2. Actualizar registro de cliente (UPDATE)
-- =========================================================
drop procedure if exists Sales.UpdateCustomerRegister
go

create procedure Sales.UpdateCustomerRegister
    @CustomerID int,
    @TerritoryID int
as
begin
    set nocount on
    begin try
        if not exists (
            select 1 from Sales.Customer where CustomerID = @CustomerID
        )
        begin
            select 'No existe un cliente con ese CustomerID' as Message
            return
        end

        if not exists (
            select 1 from Sales.SalesTerritory where TerritoryID = @TerritoryID
        )
        begin
            select 'El TerritoryID proporcionado no existe' as Message
            return
        end

        update Sales.Customer
        set TerritoryID = @TerritoryID,
            ModifiedDate = getdate()
        where CustomerID = @CustomerID

        select
            'Cliente actualizado correctamente' as Message,
            CustomerID,
            isnull(p.FirstName + ' ' + p.LastName, ' ') as Customer,
            isnull(s.Name, ' ') as Store,
            st.Name as Territory,
            st.TerritoryID,
            c.AccountNumber,
            c.ModifiedDate
        from Sales.Customer c
        left join Person.Person p on c.PersonID = p.BusinessEntityID
        left join Sales.Store s on c.StoreID = s.BusinessEntityID
        join Sales.SalesTerritory st on c.TerritoryID = st.TerritoryID
        where CustomerID = @CustomerID
    end try
    begin catch
        select error_message() as Message
    end catch
end
go

-- =========================================================
-- 3. Eliminar registro de cliente (DELETE)
-- =========================================================
drop procedure if exists Sales.DeleteCustomerRegister
go

create procedure Sales.DeleteCustomerRegister
    @CustomerID int
as
begin
    set nocount on
    begin try
        if not exists (
            select 1 from Sales.Customer where CustomerID = @CustomerID
        )
        begin
            select 'No existe un cliente con ese CustomerID' as Message
            return
        end

        -- Guardamos la informacion de borrar
        declare @Store nvarchar(100)
        declare @Territory nvarchar(100)
        declare @AccountNumber nvarchar(20)

        select
            @Store = isnull(s.Name, ' '),
            @Territory = st.Name,
            @AccountNumber = c.AccountNumber
        from Sales.Customer c
        left join Person.Person p on c.PersonID = p.BusinessEntityID
        left join Sales.Store s on c.StoreID = s.BusinessEntityID
        join Sales.SalesTerritory st on c.TerritoryID = st.TerritoryID
        where c.CustomerID = @CustomerID

        delete from Sales.Customer
        where CustomerID = @CustomerID

        select
            'Cliente eliminado correctamente' as Message,
            @CustomerID as CustomerID,
            @Store as Store,
            @Territory as Territory,
            @AccountNumber as AccountNumber
    end try
    begin catch
        select error_message() as Message
    end catch
end
go

-- =========================================================
-- 4. Seleccionar registro de cliente (SELECT)
-- =========================================================
drop procedure if exists Sales.SelectCustomerRegister
go

create procedure Sales.SelectCustomerRegister
    @CustomerID int
as
begin
    set nocount on
    begin try
        if not exists (
            select 1 from Sales.Customer where CustomerID = @CustomerID
        )
        begin
            select 'No existe un cliente con ese CustomerID' as Message
            return
        end

        select
            c.CustomerID,
            isnull(p.FirstName + ' ' + p.LastName, ' ') as Customer,
            isnull(s.Name, ' ') as Store,
            st.Name as Territory,
            c.AccountNumber,
            c.ModifiedDate
        from Sales.Customer c
        left join Person.Person p on c.PersonID = p.BusinessEntityID
        left join Sales.Store s on c.StoreID = s.BusinessEntityID
        join Sales.SalesTerritory st on c.TerritoryID = st.TerritoryID
        where c.CustomerID = @CustomerID
    end try
    begin catch
        select error_message() as Message
    end catch
end
go

-- =========================================================
-- 5. Obtener clientes (SELEC)
-- =========================================================
drop procedure if exists Sales.GetCustomers
go

create procedure Sales.GetCustomers
    @TerritoryID int = null
as
begin
    set nocount on
    begin try
        if @TerritoryID is not null and not exists (
            select 1 from Sales.SalesTerritory where TerritoryID = @TerritoryID
        )
        begin
            select 'El TerritoryID proporcionado no existe' as Message
            return
        end

        select
            c.CustomerID,
            isnull(p.FirstName + ' ' + p.LastName, ' ') as Customer,
            isnull(s.Name, ' ') as Store,
            st.Name as Territory,
            c.AccountNumber,
            c.ModifiedDate
        from Sales.Customer c
        left join Person.Person p on c.PersonID = p.BusinessEntityID
        left join Sales.Store s on c.StoreID = s.BusinessEntityID
        join Sales.SalesTerritory st on c.TerritoryID = st.TerritoryID
        where @TerritoryID is null or c.TerritoryID = @TerritoryID
        order by c.CustomerID
    end try
    begin catch
        select error_message() as Message
    end catch
end
go

-- =========================================================
-- 6. Obtener pedidos de clientes (SELECT con JOIN)
-- =========================================================
drop procedure if exists Sales.GetCustomerOrders
go

create procedure Sales.GetCustomerOrders
    @CustomerID int = null
as
begin
    set nocount on
    begin try
        if @CustomerID is not null and not exists (
            select 1 from Sales.Customer where CustomerID = @CustomerID
        )
        begin
            select 'No existe un cliente con ese CustomerID' as Message
            return
        end

        select
            c.CustomerID,
            isnull(p.FirstName + ' ' + p.LastName, ' ') as Customer,
            st.Name as Territory,
            soh.SalesOrderID,
            soh.OrderDate,
            soh.Status,
            soh.TotalDue
        from Sales.Customer c
        left join Person.Person p on c.PersonID = p.BusinessEntityID
        join Sales.SalesTerritory st on c.TerritoryID = st.TerritoryID
        inner join Sales.SalesOrderHeader soh on c.CustomerID = soh.CustomerID
        where @CustomerID is null or c.CustomerID = @CustomerID
        order by soh.OrderDate desc
    end try
    begin catch
        select error_message() as Message
    end catch
end
go
