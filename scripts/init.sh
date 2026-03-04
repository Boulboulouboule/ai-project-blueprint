#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: ./scripts/init.sh <project-name>"
  echo "Example: ./scripts/init.sh my-app"
  exit 1
fi

PROJECT_NAME="$1"
# Convert to a display name: my-app -> My App
DISPLAY_NAME=$(echo "$PROJECT_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

echo "Initializing project: $PROJECT_NAME ($DISPLAY_NAME)"

# 1. Update package.json name
sed -i '' "s/\"project-dna\"/\"$PROJECT_NAME\"/" package.json
echo "  Updated package.json"

# 2. Update database name in docker-compose.yml
sed -i '' "s/POSTGRES_DB: project-dna/POSTGRES_DB: $PROJECT_NAME/" docker-compose.yml
echo "  Updated docker-compose.yml"

# 3. Update database name in .env.example
sed -i '' "s|localhost:5432/project-dna|localhost:5432/$PROJECT_NAME|" .env.example
echo "  Updated .env.example"

# 4. Copy .env.example to .env
cp .env.example .env
echo "  Created .env from .env.example"

# 5. Update display name in web app
sed -i '' "s/Project DNA/$DISPLAY_NAME/g" apps/web/src/routes/__root.tsx
sed -i '' "s/Welcome to Project DNA/Welcome to $DISPLAY_NAME/" apps/web/src/routes/index.tsx
echo "  Updated web app display name"

# 6. Reset git
rm -rf .git
git init
git add -A
git commit -m "Initial commit: $PROJECT_NAME"
echo "  Initialized git repository"

# 7. Install dependencies
pnpm install
echo "  Installed dependencies"

echo ""
echo "Project '$PROJECT_NAME' is ready!"
echo ""
echo "Next steps:"
echo "  docker compose up -d    # Start PostgreSQL"
echo "  pnpm db:migrate         # Run database migrations"
echo "  pnpm dev                # Start development servers"
echo ""
echo "  Web:  http://localhost:3000"
echo "  API:  http://localhost:3001"
