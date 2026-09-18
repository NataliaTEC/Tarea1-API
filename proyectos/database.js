import sql from 'mssql';
import dotenv from 'dotenv';

dotenv.config({ path: '.env' });

const config = {
    production: {
        user: process.env.db_user,
        database: process.env.db_name,
        password: process.env.db_password,
        server: process.env.db_host,  
        port: Number(process.env.db_port),
        options: {
            encrypt: true,
            trustServerCertificate: true
        }
    }
}

let connection;

async function connect() {
    try {
        connection = await new sql.ConnectionPool(config.production).connect();
        console.log('Conexión a SQL Server exitosa');
        return connection;
    } catch (err) {
        console.error('Error al conectar a SQL Server:', err.message);
        throw err;
    }
}

const connectionPromise = connect();

export async function getConnection() {
    return connectionPromise;
}