import type { Context, Next } from 'hono';
import { auth } from './auth';

export type AuthVariables = {
  user: typeof auth.$Infer.Session.user | null;
  session: typeof auth.$Infer.Session.session | null;
};

/**
 * Hono middleware that resolves the BetterAuth session and injects
 * `user` and `session` into the Hono context variables.
 */
export async function sessionMiddleware(c: Context, next: Next): Promise<void> {
  const session = await auth.api.getSession({ headers: c.req.raw.headers });

  if (session) {
    c.set('user', session.user);
    c.set('session', session.session);
  } else {
    c.set('user', null);
    c.set('session', null);
  }

  await next();
}
