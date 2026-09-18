import express from 'express';
import cors from 'cors';
import customersRouter from './routes/customers.js';

const app = express();
app.use(cors(), express.json());

app.use('/api/customers', customersRouter);

app.listen(3000, () => { console.log('Servidor corriendo en puerto 3000') });