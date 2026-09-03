import { IProduct } from "../models/Product";
import { ProductRepository } from "../repositories/ProductRepository";

export type ProductInput = {
  name: string;
  description?: string;
  price: number;
  stock: number;
};

export class ProductService {

  constructor(
    private readonly repository =
      new ProductRepository()
  ) {}

  async findAll(): Promise<IProduct[]> {
    return this.repository.findAll();
  }

  async findById(id: string): Promise<IProduct> {

    const product =
      await this.repository.findById(id);

    if (!product) {
      throw new Error(
        "Produto não encontrado."
      );
    }

    return product;
  }

  async create(
    data: ProductInput
  ): Promise<IProduct> {

    if (!data.name?.trim()) {
      throw new Error(
        "Nome é obrigatório."
      );
    }

    if (
      Number(data.price) < 0 ||
      Number(data.stock) < 0
    ) {
      throw new Error(
        "Preço e estoque não podem ser negativos."
      );
    }

    return this.repository.create({
      ...data,

      name: data.name.trim(),

      price: Number(data.price),

      stock: Number(data.stock),
    });
  }

  async update(
    id: string,
    data: Partial<ProductInput>
  ): Promise<IProduct> {

    const product =
      await this.repository.update(
        id,
        data
      );

    if (!product) {
      throw new Error(
        "Produto não encontrado."
      );
    }

    return product;
  }

  async delete(id: string): Promise<void> {

    const product =
      await this.repository.delete(id);

    if (!product) {
      throw new Error(
        "Produto não encontrado."
      );
    }
  }
}
