import express from "express";
import cors from "cors";

import { env } from "./config/env";

import productRoutes from "./routes/productRoutes";

import {
  errorHandler,
} from "./middlewares/errorHandler";

export const app =
  express();

app.use(
  cors({
    origin:
      env.corsOrigin,
  })
);

app.use(
  express.json()
);

app.get(
  "/api/health",
  (_req, res) => {

    res.json({
      status: "ok",
    });
  }
);

app.use(
  "/api/products",
  productRoutes
);

app.use(
  errorHandler
);
