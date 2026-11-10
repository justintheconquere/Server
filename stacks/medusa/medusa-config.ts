import { loadEnv, defineConfig } from "@medusajs/framework/utils"

loadEnv(process.env.NODE_ENV || "development", process.cwd())

// Store/admin config. Real secrets come from the stack's .env on the
// box (JWT_SECRET, COOKIE_SECRET) — the "supersecret" fallbacks are
// the upstream scaffold's placeholders, never deploy with them.
export default defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    redisUrl: process.env.REDIS_URL,
    http: {
      storeCors: process.env.STORE_CORS || "http://localhost:8000",
      adminCors: process.env.ADMIN_CORS || "http://ufo:9000",
      authCors: process.env.AUTH_CORS || "http://ufo:9000",
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    },
  },
})
