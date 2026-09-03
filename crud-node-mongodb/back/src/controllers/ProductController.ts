import {
  Request,
  Response,
} from "express";

import mongoose from "mongoose";

import { ProductService } from "../services/ProductService";

export class ProductController {

  constructor(
    private readonly service =
      new ProductService()
  ) {}

  getAll = async (
    _req: Request,
    res: Response
  ): Promise<void> => {

    const products =
      await this.service.findAll();

    res.json(products);
  };

  getById = async (
    req: Request,
    res: Response
  ): Promise<void> => {

    if (
      !mongoose.isValidObjectId(
        req.params.id
      )
    ) {
      res.status(400).json({
        message: "ID inválido.",
      });

      return;
    }

    const product =
      await this.service.findById(
        req.params.id
      );

    res.json(product);
  };

  create = async (
    req: Request,
    res: Response
  ): Promise<void> => {

    const product =
      await this.service.create(
        req.body
      );

    res.status(201).json(product);
  };

  update = async (
    req: Request,
    res: Response
  ): Promise<void> => {

    if (
      !mongoose.isValidObjectId(
        req.params.id
      )
    ) {
      res.status(400).json({
        message: "ID inválido.",
      });

      return;
    }

    const product =
      await this.service.update(
        req.params.id,
        req.body
      );

    res.json(product);
  };

  delete = async (
    req: Request,
    res: Response
  ): Promise<void> => {

    if (
      !mongoose.isValidObjectId(
        req.params.id
      )
    ) {
      res.status(400).json({
        message: "ID inválido.",
      });

      return;
    }

    await this.service.delete(
      req.params.id
    );

    res.status(204).send();
  };
}
