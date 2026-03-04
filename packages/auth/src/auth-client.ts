import { createAuthClient } from 'better-auth/react';

export function createClient(baseURL = 'http://localhost:3001') {
  return createAuthClient({ baseURL });
}

export const authClient = createClient();

export const { signIn, signUp, signOut, useSession } = authClient;
