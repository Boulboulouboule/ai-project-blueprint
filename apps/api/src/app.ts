import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { requestLogger } from './middleware/logger';
import { errorHandler } from './middleware/error-handler';
import { healthRoute } from './features/health/health.route';

function createApp() {
  const app = new Hono();

  // Global middleware
  app.use('*', requestLogger);
  app.use(
    '*',
    cors({
      origin: process.env.WEB_URL ?? 'http://localhost:3000',
      credentials: true,
    }),
  );

  // Error handler
  app.onError(errorHandler);

  // Routes
  app.route('/health', healthRoute);

  return app;
}

export const app = createApp();

export type AppType = typeof app;
