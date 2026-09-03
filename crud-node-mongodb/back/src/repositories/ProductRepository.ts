import {
  IProduct,
  ProductModel,
} from "../models/Product";

export class ProductRepository {

  async findAll(): Promise<IProduct[]> {
    return ProductModel
      .find()
      .sort({ createdAt: -1 });
  }

  async findById(
    id: string
  ): Promise<IProduct | null> {
    return ProductModel.findById(id);
  }

  async create(
    data: Partial<IProduct>
  ): Promise<IProduct> {
    return ProductModel.create(data);
  }

  async update(
    id: string,
    data: Partial<IProduct>
  ): Promise<IProduct | null> {

    return ProductModel.findByIdAndUpdate(
      id,
      data,
      {
        new: true,
        runValidators: true,
      }
    );
  }

  async delete(
    id: string
  ): Promise<IProduct | null> {

    return ProductModel.findByIdAndDelete(id);
  }
}
