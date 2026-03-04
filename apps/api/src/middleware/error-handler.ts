import type { ErrorHandler } from 'hono';
import { HTTPException } from 'hono/http-exception';

export const errorHandler: ErrorHandler = (err, c) => {
  if (err instanceof HTTPException) {
    return c.json(
      {
        error: {
          code: err.status.toString(),
          message: err.message,
        },
      },
      err.status,
    );
  }

  console.error('Unhandled error:', err);

  return c.json(
    {
      error: {
        code: '500',
        message: process.env.NODE_ENV === 'production' ? 'Internal Server Error' : err.message,
      },
    },
    500,
  );
};
