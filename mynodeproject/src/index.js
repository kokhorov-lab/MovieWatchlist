import express from 'express';
import cors from 'cors';
import {config} from 'dotenv';
import movieRoute from './route/movieRoute.js';
import authRoute from './route/authRoute.js';
import {connectDB, disconnectDB} from './config/db.js';
import watchlistRoute from './route/watchListRoute.js';

config();
connectDB();

const app = express();

//body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors({
origin: 'http://localhost:8080', // Must match your Flutter Web URL/Port
  credentials: true,
}))

const PORT = 3000;

//API Routes

app.use('/movies', movieRoute);
app.use('/auth', authRoute);
app.use('/watchlist', watchlistRoute);

const server = app.listen(PORT,() => console.log(`Server running on http://localhost:${PORT}`));

process.on('unhandledRejection', (err) => {
    console.error('Unhandled Rejection: ', err);
    server.close(async () => {
        await disconnectDB();
        process.exit(1);
    });
});

process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception: ', err);
    server.close( async () => {
        await disconnectDB();
        process.exit(1);
    })
})

process.on('SIGTERM', () => {
    console.error('SIGTERM received, shutting down gracefully');
    server.close(async () => {
        await disconnectDB();
        process.exit(1);
    });
});