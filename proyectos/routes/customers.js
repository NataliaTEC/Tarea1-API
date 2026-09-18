import { Router } from 'express';
import {
    addCustomer,
    updateCustomer,
    deleteCustomer,
    getCustomerById,
    getCustomers,
    getCustomerOrders
} from '../llamadas.js';

const router = Router();

function esMensajeDeError(row) {
    return row && row.Message && /no existe/i.test(row.Message);
}

// GET /api/customers/orders?CustomerID=123
router.get('/orders', async (req, res) => {
    try {
        const { CustomerID } = req.query;
        const id = CustomerID ? Number(CustomerID) : null;

        if (CustomerID && Number.isNaN(id)) {
            return res.status(400).json({ Message: 'CustomerID debe ser numérico' });
        }

        const orders = await getCustomerOrders(id);
        res.status(200).json(orders);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/customers?TerritoryID=5
router.get('/', async (req, res) => {
    try {
        const { TerritoryID } = req.query;
        const id = TerritoryID ? Number(TerritoryID) : null;

        if (TerritoryID && Number.isNaN(id)) {
            return res.status(400).json({ Message: 'TerritoryID debe ser numérico' });
        }

        const customers = await getCustomers(id);
        res.status(200).json(customers);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/customers/:id
router.get('/:id', async (req, res) => {
    try {
        const id = Number(req.params.id);
        if (Number.isNaN(id)) {
            return res.status(400).json({ Message: 'El id debe ser numérico' });
        }

        const row = await getCustomerById(id);
        if (esMensajeDeError(row)) {
            return res.status(404).json(row);
        }
        res.status(200).json(row);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /api/customers
router.post('/', async (req, res) => {
    try {
        const { PersonID, StoreID, TerritoryID } = req.body;
        const row = await addCustomer({ PersonID, StoreID, TerritoryID });

        if (esMensajeDeError(row)) {
            return res.status(400).json(row);
        }
        res.status(201).json(row);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /api/customers/:id
router.put('/:id', async (req, res) => {
    try {
        const id = Number(req.params.id);
        const { TerritoryID } = req.body;

        if (Number.isNaN(id)) {
            return res.status(400).json({ Message: 'El id debe ser numérico' });
        }
        if (TerritoryID === undefined) {
            return res.status(400).json({ Message: 'Falta el campo TerritoryID en el body' });
        }

        const row = await updateCustomer(id, Number(TerritoryID));
        if (esMensajeDeError(row)) {
            return res.status(404).json(row);
        }
        res.status(200).json(row);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE /api/customers/:id
router.delete('/:id', async (req, res) => {
    try {
        const id = Number(req.params.id);
        if (Number.isNaN(id)) {
            return res.status(400).json({ Message: 'El id debe ser numérico' });
        }

        const row = await deleteCustomer(id);
        if (esMensajeDeError(row)) {
            return res.status(404).json(row);
        }
        res.status(200).json(row);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

export default router;