import sql from 'mssql';
import { getConnection } from './database.js';

// 1. INSERT -> Sales.AddCustomerRegister
export async function addCustomer({ PersonID, StoreID, TerritoryID }) {
    const pool = await getConnection();
    const result = await pool.request()
        .input('PersonID', sql.Int, PersonID ?? null)
        .input('StoreID', sql.Int, StoreID ?? null)
        .input('TerritoryID', sql.Int, TerritoryID ?? null)
        .execute('Sales.AddCustomerRegister');

    return result.recordset[0];
}

// 2. UPDATE -> Sales.UpdateCustomerRegister
export async function updateCustomer(CustomerID, TerritoryID) {
    const pool = await getConnection();
    const result = await pool.request()
        .input('CustomerID', sql.Int, CustomerID)
        .input('TerritoryID', sql.Int, TerritoryID)
        .execute('Sales.UpdateCustomerRegister');

    return result.recordset[0];
}

// 3. DELETE -> Sales.DeleteCustomerRegister
export async function deleteCustomer(CustomerID) {
    const pool = await getConnection();
    const result = await pool.request()
        .input('CustomerID', sql.Int, CustomerID)
        .execute('Sales.DeleteCustomerRegister');

    return result.recordset[0];
}

// 4. SELECT puntual -> Sales.SelectCustomerRegister
export async function getCustomerById(CustomerID) {
    const pool = await getConnection();
    const result = await pool.request()
        .input('CustomerID', sql.Int, CustomerID)
        .execute('Sales.SelectCustomerRegister');

    return result.recordset[0];
}

// 5. SELECT de tabla completa (con filtro opcional) -> Sales.GetCustomers
export async function getCustomers(TerritoryID) {
    const pool = await getConnection();
    const result = await pool.request()
        .input('TerritoryID', sql.Int, TerritoryID ?? null)
        .execute('Sales.GetCustomers');

    return result.recordset;
}

// 6. SELECT con JOIN -> Sales.GetCustomerOrders 
export async function getCustomerOrders(CustomerID) {
    const pool = await getConnection();
    const result = await pool.request()
        .input('CustomerID', sql.Int, CustomerID ?? null)
        .execute('Sales.GetCustomerOrders');

    return result.recordset;
}