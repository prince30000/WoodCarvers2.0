import app from './app.js';
import { connectDB } from './config/db.js';
import { ENV } from './config/env.js';
import { logger } from './utils/logger.js';

const startServer = async () => {
  // Connect to MongoDB
  await connectDB();

  const server = app.listen(ENV.PORT, () => {
    logger.info(`=======================================================`);
    logger.info(`🪵 WOOD CARVERS REST API SERVER RUNNING 🪵`);
    logger.info(`Mode:        ${ENV.NODE_ENV}`);
    logger.info(`Port:        ${ENV.PORT}`);
    logger.info(`Health API:  http://localhost:${ENV.PORT}/api/health`);
    logger.info(`Products:    http://localhost:${ENV.PORT}/api/products`);
    logger.info(`=======================================================`);
  });

  // Graceful shutdown handling
  const gracefulShutdown = (signal) => {
    logger.info(`${signal} received. Closing HTTP server gracefully...`);
    server.close(() => {
      logger.info('HTTP server closed.');
      process.exit(0);
    });
  };

  process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
  process.on('SIGINT', () => gracefulShutdown('SIGINT'));
};

startServer();
