import { createFileRoute } from '@tanstack/react-router';

export const Route = createFileRoute('/')({
  component: Home,
});

function Home() {
  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-bold">Welcome to Project DNA</h1>
      <p className="text-gray-600">
        Built with TanStack Start, Hono, Prisma, and Tailwind CSS v4.
      </p>
    </div>
  );
}
