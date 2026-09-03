import {
  ErrorRequestHandler,
} from "express";

import mongoose from "mongoose";

export const errorHandler:
  ErrorRequestHandler =
  (
    error,
    _req,
    res,
    _next
  ) => {

    console.error(error);

    if (
      error instanceof
      mongoose.Error.ValidationError
    ) {

      res.status(400).json({
        message:
          "Dados inválidos.",

        errors:
          Object.values(
            error.errors
          ).map(
            (item) =>
              item.message
          ),
      });

      return;
    }

    res.status(500).json({
      message:
        error instanceof Error
          ? error.message
          : "Erro interno do servidor.",
    });
  };
