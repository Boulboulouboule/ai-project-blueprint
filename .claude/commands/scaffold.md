---
description: Bootstrap a new Turborepo project with TanStack Start, Hono, Prisma, and Tailwind CSS v4
---

# Scaffold Project: $ARGUMENTS

You are bootstrapping a complete monorepo project named **$ARGUMENTS**. Follow each phase sequentially. Use the `Write` tool to create files and `Bash` tool for commands.

Set the project root to: `$ARGUMENTS/` (relative to the current working directory).

---

## Phase 1: Root Configuration

### `package.json`
```json
{
  "name": "$ARGUMENTS",
  "private": true,
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "test": "turbo test",
    "lint": "turbo lint",
    "typecheck": "turbo typecheck",
    "db:migrate": "pnpm --filter @repo/db exec prisma migrate dev",
    "db:seed": "pnpm --filter @repo/db exec tsx src/seed.ts",
    "db:studio": "pnpm --filter @repo/db exec prisma studio",
    "db:generate": "pnpm --filter @repo/db exec prisma generate"
  },
  "devDependencies": {
    "turbo": "^2.8.12"
  },
  "packageManager": "pnpm@9.15.4"
}
```

### `pnpm-workspace.yaml`
```yaml
packages:
  - "apps/*"
  - "packages/*"
  - "tooling/*"
```

### `turbo.json`
```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".output/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "test": {
      "dependsOn": ["^build"]
    },
    "lint": {},
    "typecheck": {
      "dependsOn": ["^build"]
    }
  }
}
```

### `docker-compose.yml`
```yaml
services:
  postgres:
    image: postgres:17-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: $ARGUMENTS
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### `.env.example`
```
# Database
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/$ARGUMENTS?schema=public"

# API
API_PORT=3001
API_URL=http://localhost:3001

# Web
WEB_PORT=3000
VITE_API_URL=http://localhost:3001
```

### `.gitignore`
```
node_modules/
dist/
.output/
.turbo/
*.tsbuildinfo
.env
.env.local
.nitro/
```

---

## Phase 2: Tooling Packages

### `tooling/typescript/package.json`
```json
{
  "name": "@repo/typescript-config",
  "private": true,
  "version": "0.0.0"
}
```

### `tooling/typescript/base.json`
```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noUncheckedIndexedAccess": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "composite": true
  },
  "exclude": ["node_modules", "dist"]
}
```

### `tooling/typescript/react.json`
```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "noEmit": true
  }
}
```

### `tooling/typescript/node.json`
```json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "extends": "./base.json",
  "compilerOptions": {
    "lib": ["ES2022"],
    "module": "ESNext",
    "outDir": "./dist",
    "noEmit": false
  }
}
```

### `tooling/eslint/package.json`
```json
{
  "name": "@repo/eslint-config",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "exports": {
    "./base": "./base.js",
    "./react": "./react.js"
  },
  "dependencies": {
    "@eslint/js": "^9.22.0",
    "eslint-plugin-react-hooks": "^5.2.0",
    "eslint-plugin-react-refresh": "^0.4.19",
    "globals": "^16.0.0",
    "typescript-eslint": "^8.28.0"
  },
  "peerDependencies": {
    "eslint": "^9.0.0"
  }
}
```

### `tooling/eslint/base.js`
```javascript
import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['dist/', 'node_modules/', '.output/'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],
    },
  },
);
```

### `tooling/eslint/react.js`
```javascript
import baseConfig from './base.js';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';

export default [
  ...baseConfig,
  {
    plugins: {
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],
    },
  },
];
```

### `tooling/prettier/package.json`
```json
{
  "name": "@repo/prettier-config",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "exports": {
    ".": "./index.js"
  },
  "dependencies": {
    "prettier": "^3.8.1"
  }
}
```

### `tooling/prettier/index.js`
```javascript
/** @type {import("prettier").Config} */
export default {
  semi: true,
  singleQuote: true,
  trailingComma: 'all',
  printWidth: 100,
  tabWidth: 2,
};
```

---

## Phase 3: `packages/shared`

### `packages/shared/package.json`
```json
{
  "name": "@repo/shared",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "exports": {
    ".": {
      "types": "./src/index.ts",
      "default": "./src/index.ts"
    }
  },
  "scripts": {
    "test": "vitest run --passWithNoTests",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src/"
  },
  "dependencies": {
    "zod": "^4.3.6"
  },
  "devDependencies": {
    "@repo/eslint-config": "workspace:*",
    "@repo/typescript-config": "workspace:*",
    "eslint": "^9.22.0",
    "typescript": "^5.9.3",
    "vitest": "^4.0.18"
  }
}
```

### `packages/shared/tsconfig.json`
```json
{
  "extends": "../../tooling/typescript/base.json",
  "compilerOptions": {
    "outDir": "./dist"
  },
  "include": ["src"]
}
```

### `packages/shared/vitest.config.ts`
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
  },
});
```

### `packages/shared/eslint.config.js`
```javascript
import baseConfig from '@repo/eslint-config/base';

export default [...baseConfig];
```

### `packages/shared/src/api-response.schema.ts`
```typescript
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
```

### `packages/shared/src/pagination.schema.ts`
```typescript
import { z } from 'zod';

export const PaginationSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export type Pagination = z.infer<typeof PaginationSchema>;

export const PaginatedResponseSchema = z.object({
  total: z.number(),
  page: z.number(),
  limit: z.number(),
  totalPages: z.number(),
});

export type PaginatedResponse = z.infer<typeof PaginatedResponseSchema>;
```

### `packages/shared/src/index.ts`
```typescript
export { createApiResponseSchema, ApiErrorSchema, type ApiError } from './api-response.schema';
export {
  PaginationSchema,
  PaginatedResponseSchema,
  type Pagination,
  type PaginatedResponse,
} from './pagination.schema';
```

---

## Phase 4: `packages/db`

### `packages/db/package.json`
```json
{
  "name": "@repo/db",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "exports": {
    ".": {
      "types": "./src/index.ts",
      "default": "./src/index.ts"
    }
  },
  "scripts": {
    "db:migrate": "prisma migrate dev",
    "db:generate": "prisma generate",
    "db:seed": "tsx src/seed.ts",
    "db:studio": "prisma studio",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src/"
  },
  "dependencies": {
    "@prisma/client": "^6.19.2"
  },
  "devDependencies": {
    "@repo/eslint-config": "workspace:*",
    "@repo/typescript-config": "workspace:*",
    "@types/node": "^22.5.4",
    "eslint": "^9.22.0",
    "prisma": "^6.19.2",
    "tsx": "^4.19.3",
    "typescript": "^5.9.3"
  }
}
```

### `packages/db/tsconfig.json`
```json
{
  "extends": "../../tooling/typescript/node.json",
  "compilerOptions": {
    "outDir": "./dist"
  },
  "include": ["src"]
}
```

### `packages/db/eslint.config.js`
```javascript
import baseConfig from '@repo/eslint-config/base';

export default [...baseConfig];
```

### `packages/db/prisma/schema.prisma`
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("users")
}
```

### `packages/db/src/index.ts`
```typescript
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient | undefined };

export const db = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = db;

export { PrismaClient };
export type * from '@prisma/client';
```

### `packages/db/src/seed.ts`
```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const user = await prisma.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: {
      email: 'admin@example.com',
      name: 'Admin User',
    },
  });

  console.log('Seeded user:', user);
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
```

---

## Phase 5: `packages/ui`

### `packages/ui/package.json`
```json
{
  "name": "@repo/ui",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "exports": {
    ".": {
      "types": "./src/index.ts",
      "default": "./src/index.ts"
    }
  },
  "scripts": {
    "test": "vitest run",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src/"
  },
  "dependencies": {
    "clsx": "^2.1.1",
    "react": "^19.2.4"
  },
  "devDependencies": {
    "@repo/eslint-config": "workspace:*",
    "@repo/typescript-config": "workspace:*",
    "@testing-library/jest-dom": "^6.6.3",
    "@testing-library/react": "^16.3.0",
    "@types/react": "^19.2.14",
    "eslint": "^9.22.0",
    "jsdom": "^28.1.0",
    "typescript": "^5.9.3",
    "vitest": "^4.0.18"
  },
  "peerDependencies": {
    "react": "^19.0.0"
  }
}
```

### `packages/ui/tsconfig.json`
```json
{
  "extends": "../../tooling/typescript/react.json",
  "include": ["src"]
}
```

### `packages/ui/vitest.config.ts`
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test-setup.ts'],
  },
});
```

### `packages/ui/eslint.config.js`
```javascript
import reactConfig from '@repo/eslint-config/react';

export default [...reactConfig];
```

### `packages/ui/src/test-setup.ts`
```typescript
import '@testing-library/jest-dom/vitest';
```

### `packages/ui/src/button/button.tsx`
```tsx
import { clsx } from 'clsx';

type ButtonProps = {
  label: string;
  onClick?: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
  type?: 'button' | 'submit' | 'reset';
};

export function Button({
  label,
  onClick,
  variant = 'primary',
  disabled = false,
  type = 'button',
}: ButtonProps) {
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={clsx(
        'inline-flex items-center justify-center rounded-md px-4 py-2 text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2',
        variant === 'primary' &&
          'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
        variant === 'secondary' &&
          'bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500',
        disabled && 'cursor-not-allowed opacity-50',
      )}
    >
      {label}
    </button>
  );
}
```

### `packages/ui/src/button/button.test.tsx`
```tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './button';

describe('Button', () => {
  it('renders with label', () => {
    render(<Button label="Click me" />);
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button label="Click me" onClick={handleClick} />);
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledOnce();
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button label="Click me" disabled />);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

### `packages/ui/src/index.ts`
```typescript
export { Button } from './button/button';
```

---

## Phase 6: `apps/api`

### `apps/api/package.json`
```json
{
  "name": "@repo/api",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest run",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src/"
  },
  "dependencies": {
    "@hono/node-server": "^1.19.10",
    "@hono/zod-validator": "^0.7.6",
    "@repo/db": "workspace:*",
    "@repo/shared": "workspace:*",
    "hono": "^4.12.4"
  },
  "devDependencies": {
    "@repo/eslint-config": "workspace:*",
    "@repo/typescript-config": "workspace:*",
    "@types/node": "^22.5.4",
    "eslint": "^9.22.0",
    "tsx": "^4.19.3",
    "typescript": "^5.9.3",
    "vitest": "^4.0.18"
  }
}
```

### `apps/api/tsconfig.json`
```json
{
  "extends": "../../tooling/typescript/node.json",
  "compilerOptions": {
    "outDir": "./dist"
  },
  "include": ["src"]
}
```

### `apps/api/vitest.config.ts`
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
  },
});
```

### `apps/api/eslint.config.js`
```javascript
import baseConfig from '@repo/eslint-config/base';

export default [...baseConfig];
```

### `apps/api/src/middleware/error-handler.ts`
```typescript
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
```

### `apps/api/src/middleware/logger.ts`
```typescript
import { logger } from 'hono/logger';

export const requestLogger = logger();
```

### `apps/api/src/features/health/health.route.ts`
```typescript
import { Hono } from 'hono';

export const healthRoute = new Hono().get('/', (c) => {
  return c.json({ status: 'ok', timestamp: new Date().toISOString() });
});
```

### `apps/api/src/features/health/health.test.ts`
```typescript
import { describe, it, expect } from 'vitest';
import { app } from '../../app';

describe('GET /health', () => {
  it('returns 200 with status ok', async () => {
    const res = await app.request('/health');
    expect(res.status).toBe(200);

    const body = (await res.json()) as { status: string; timestamp: string };
    expect(body.status).toBe('ok');
    expect(body.timestamp).toBeDefined();
  });
});
```

### `apps/api/src/app.ts`
```typescript
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
```

### `apps/api/src/index.ts`
```typescript
import { serve } from '@hono/node-server';
import { app } from './app';

const port = Number(process.env.API_PORT) || 3001;

console.log(`API server starting on port ${port}`);

serve({
  fetch: app.fetch,
  port,
});
```

---

## Phase 7: `apps/web`

### `apps/web/package.json`
```json
{
  "name": "@repo/web",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite dev",
    "build": "vite build",
    "preview": "vite preview",
    "start": "node .output/server/index.mjs",
    "typecheck": "tsc --noEmit",
    "lint": "eslint src/"
  },
  "dependencies": {
    "@repo/shared": "workspace:*",
    "@repo/ui": "workspace:*",
    "@tanstack/react-query": "^5.90.21",
    "@tanstack/react-router": "^1.163.3",
    "@tanstack/react-router-devtools": "^1.163.3",
    "@tanstack/react-start": "^1.166.1",
    "hono": "^4.12.4",
    "react": "^19.2.4",
    "react-dom": "^19.2.4"
  },
  "devDependencies": {
    "@repo/eslint-config": "workspace:*",
    "@repo/typescript-config": "workspace:*",
    "@tailwindcss/vite": "^4.2.1",
    "@types/react": "^19.2.14",
    "@types/react-dom": "^19.2.3",
    "@vitejs/plugin-react": "^4.6.0",
    "eslint": "^9.22.0",
    "nitro": "^3.0.1-alpha.2",
    "tailwindcss": "^4.2.1",
    "typescript": "^5.9.3",
    "vite": "^7.3.1",
    "vite-tsconfig-paths": "^5.1.4"
  }
}
```

### `apps/web/tsconfig.json`
```json
{
  "include": ["**/*.ts", "**/*.tsx"],
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true,
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "lib": ["DOM", "DOM.Iterable", "ES2022"],
    "isolatedModules": true,
    "resolveJsonModule": true,
    "skipLibCheck": true,
    "target": "ES2022",
    "allowJs": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "~/*": ["./src/*"]
    },
    "noEmit": true
  }
}
```

### `apps/web/vite.config.ts`
```typescript
import { tanstackStart } from '@tanstack/react-start/plugin/vite';
import { defineConfig } from 'vite';
import tsConfigPaths from 'vite-tsconfig-paths';
import viteReact from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { nitro } from 'nitro/vite';

export default defineConfig({
  server: {
    port: 3000,
  },
  plugins: [
    tailwindcss(),
    tsConfigPaths({
      projects: ['./tsconfig.json'],
    }),
    tanstackStart({
      srcDirectory: 'src',
    }),
    viteReact(),
    nitro(),
  ],
});
```

### `apps/web/eslint.config.js`
```javascript
import reactConfig from '@repo/eslint-config/react';

export default [...reactConfig];
```

### `apps/web/src/styles/app.css`
```css
@import 'tailwindcss' source('../');

@theme {
  --color-primary: #3b82f6;
  --color-primary-dark: #2563eb;
  --color-secondary: #64748b;
  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --font-sans: 'Inter', sans-serif;
}
```

### `apps/web/src/router.tsx`
```typescript
import { createRouter } from '@tanstack/react-router';
import { routeTree } from './routeTree.gen';

export function getRouter() {
  const router = createRouter({
    routeTree,
    defaultPreload: 'intent',
    scrollRestoration: true,
  });
  return router;
}

declare module '@tanstack/react-router' {
  interface Register {
    router: ReturnType<typeof getRouter>;
  }
}
```

### `apps/web/src/routes/__root.tsx`
```tsx
/// <reference types="vite/client" />
import {
  HeadContent,
  Link,
  Outlet,
  Scripts,
  createRootRoute,
} from '@tanstack/react-router';
import { TanStackRouterDevtools } from '@tanstack/react-router-devtools';
import * as React from 'react';
import appCss from '~/styles/app.css?url';

export const Route = createRootRoute({
  head: () => ({
    meta: [
      { charSet: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
    ],
    links: [
      { rel: 'stylesheet', href: appCss },
    ],
  }),
  component: RootComponent,
  shellComponent: RootDocument,
});

function RootDocument({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <HeadContent />
      </head>
      <body className="min-h-screen bg-gray-50 text-gray-900 antialiased">
        {children}
        <Scripts />
      </body>
    </html>
  );
}

function RootComponent() {
  return (
    <>
      <header className="border-b border-gray-200 bg-white">
        <nav className="mx-auto flex max-w-7xl items-center gap-6 px-4 py-3">
          <Link
            to="/"
            className="text-lg font-bold text-primary"
            activeProps={{ className: 'text-primary-dark' }}
          >
            $ARGUMENTS
          </Link>
          <Link
            to="/"
            activeProps={{ className: 'font-semibold text-primary' }}
            activeOptions={{ exact: true }}
            className="text-sm text-gray-600 hover:text-gray-900"
          >
            Home
          </Link>
        </nav>
      </header>
      <main className="mx-auto max-w-7xl px-4 py-8">
        <Outlet />
      </main>
      <TanStackRouterDevtools position="bottom-right" />
    </>
  );
}
```

### `apps/web/src/routes/index.tsx`
```tsx
import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/')({
  component: Home,
});

function Home() {
  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-bold">Welcome to $ARGUMENTS</h1>
      <p className="text-gray-600">
        Built with TanStack Start, Hono, Prisma, and Tailwind CSS v4.
      </p>
    </div>
  );
}
```

### `apps/web/src/lib/api-client.ts`
```typescript
const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:3001';

export async function apiClient<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${apiUrl}${path}`, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...init?.headers,
    },
  });

  if (!res.ok) {
    throw new Error(`API error: ${res.status} ${res.statusText}`);
  }

  return res.json() as Promise<T>;
}
```

---

## Phase 8: AI Configuration

### Copy all `.claude/commands/` skills from the project-dna repository
Copy these files into `$ARGUMENTS/.claude/commands/`:
- `create-spec.md`
- `create-adr.md`
- `create-feature.md`
- `code-review.md`
- `plan.md`

Read each file from the `project-dna` repository and write it into the new project.

### `.claude/settings.json`
```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm install*)",
      "Bash(pnpm dev*)",
      "Bash(pnpm build*)",
      "Bash(pnpm test*)",
      "Bash(pnpm lint*)",
      "Bash(pnpm typecheck*)",
      "Bash(pnpm db:*)",
      "Bash(pnpm exec prisma*)",
      "Bash(git init*)",
      "Bash(git add*)",
      "Bash(git commit*)",
      "Bash(git status*)",
      "Bash(git log*)",
      "Bash(git diff*)",
      "Bash(mkdir*)",
      "Bash(ls*)",
      "Bash(npx prisma*)"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)"
    ]
  }
}
```

### `.claude.json` (MCP servers)
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

### Copy all `.cursor/rules/` from project-dna
Copy these files into `$ARGUMENTS/.cursor/rules/`:
- `typescript.mdc`
- `react.mdc`
- `hono-api.mdc`
- `prisma.mdc`
- `testing.mdc`
- `tailwind.mdc`
- `zod-schemas.mdc`
- `project-structure.mdc`

Read each file from the `project-dna` repository and write it into the new project.

---

## Phase 9: Documentation

### Copy `AGENTS.md` from project-dna
Read `AGENTS.md` from the project-dna repository and write it into the new project root.

### Copy `CLAUDE.md` from project-dna
Read `CLAUDE.md` from the project-dna repository and write it into the new project root.

### Copy `specs/_template.spec.md` from project-dna
Copy the spec template into the new project.

### Copy `adr/` from project-dna
Copy all ADR files (template, README, and all 7 numbered ADRs) into the new project.

### `README.md`
Create a README with:
- Project name and description
- Tech stack table
- Getting started instructions (prerequisites, install, env setup, docker, dev)
- Available scripts table
- Project structure overview
- Links to AGENTS.md, CLAUDE.md, specs/, adr/

---

## Phase 10: Initialize

Run these commands in sequence:

1. `cp .env.example .env` — Create local env file
2. `pnpm install` — Install all dependencies
3. `pnpm --filter @repo/db exec prisma generate` — Generate Prisma client
4. `pnpm build` — Build all packages to generate routeTree and verify everything works
5. `pnpm test` — Run all tests to verify
6. `pnpm typecheck` — Verify types
7. `git init` — Initialize git repository
8. `git add -A` — Stage all files
9. `git commit -m "Initial scaffold: $ARGUMENTS"` — Create initial commit

After all phases complete, report:
- Total files created
- Test results summary
- Build results summary
- How to start development: `cd $ARGUMENTS && pnpm dev`
- Web app URL: http://localhost:3000
- API URL: http://localhost:3001
- Remind user to start PostgreSQL: `docker compose up -d`
