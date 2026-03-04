import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    env: {
      BETTER_AUTH_SECRET: 'test-secret-for-vitest',
    },
  },
});
