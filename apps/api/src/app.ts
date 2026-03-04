import { auth } from '@repo/auth';
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { healthRoute } from './features/health/health.route';
import { errorHandler } from './middleware/error-handler';
import { requestLogger } from './middleware/logger';

function createApp() {
  const app = new Hono();

  // Global middleware
  app.use('*', requestLogger);
  app.use(
    '*',
    cors({
      origin: process.env.WEB_URL ?? 'http://localhost:3000',
      credentials: true,
      allowHeaders: ['Content-Type', 'Authorization'],
      allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    }),
  );

  // Error handler
  app.onError(errorHandler);

  // BetterAuth — handles all /api/auth/* routes
  app.on(['POST', 'GET'], '/api/auth/**', (c) => auth.handler(c.req.raw));

  // Routes
  app.route('/health', healthRoute);

  return app;
}

export const app = createApp();

export type AppType = typeof app;
