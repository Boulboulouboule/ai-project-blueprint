import { z } from 'zod';

export function createApiResponseSchema<T extends z.ZodType>(dataSchema: T) {
  return z.object({
    data: dataSchema,
    meta: z
      .object({
        timestamp: z.string(),
      })
      .optional(),
  });
}

export const ApiErrorSchema = z.object({
  error: z.object({
    code: z.string(),
    message: z.string(),
  }),
});

export type ApiError = z.infer<typeof ApiErrorSchema>;
