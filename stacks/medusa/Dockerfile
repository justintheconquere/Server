# Medusa v2 — self-hosted commerce backend + admin.
# Medusa ships no prebuilt server image: a deployment IS a project,
# so this stack commits the minimal project (package.json,
# medusa-config.ts, tsconfig.json — versions pinned to the 2.22.6
# release line, checked 2026-11-09) and builds it here.
# VERIFY at first build: the medusa build output layout and the
# db:migrate / user CLI subcommands for this release line.
FROM node:22-bookworm-slim AS build
WORKDIR /app
COPY package.json medusa-config.ts tsconfig.json ./
COPY src ./src
RUN npm install --no-audit --no-fund
RUN npx medusa build

FROM node:22-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app /app
EXPOSE 9000
CMD ["sh", "-c", "npx medusa db:migrate && npx medusa start"]
