export type Product = {

  _id: string;

  name: string;

  description: string;

  price: number;

  stock: number;

  createdAt: string;

  updatedAt: string;
};

export type ProductInput = {

  name: string;

  description: string;

  price: number;

  stock: number;
};
