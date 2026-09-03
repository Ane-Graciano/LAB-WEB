import "dotenv/config";

export const env = {
  port: Number(process.env.PORT ?? 3000),

  mongoUri:
    process.env.MONGODB_URI ??
    "mongodb://127.0.0.1:27017/crud_node",

  corsOrigin:
    process.env.CORS_ORIGIN ??
    "http://localhost:5173",
};
