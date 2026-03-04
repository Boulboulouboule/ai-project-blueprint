import { z } from 'zod';

export const SignInSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

export type SignIn = z.infer<typeof SignInSchema>;

export const SignUpSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

export type SignUp = z.infer<typeof SignUpSchema>;
