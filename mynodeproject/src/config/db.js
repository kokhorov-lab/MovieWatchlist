import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';

const adapter = new PrismaPg({
    connectionString: process.env.DATABASE_URL,
});

const prisma = new PrismaClient({
    adapter,
    log: process.env.NODE_ENV === 'development'
        ? ['query', 'error', 'warn']
        : ['error'],
});
const connectDB = async () => {
    try {
        await prisma.$connect();
        console.log('DB connected successfully');
    } catch (error) {
        console.error(`Error: ${error.message}`);
        proccess.exit(1);
    }
}

const disconnectDB = async () => {
    await prisma.$disconnect();
    console.log('Disconnecting from DB...');
}

export { prisma, connectDB, disconnectDB};