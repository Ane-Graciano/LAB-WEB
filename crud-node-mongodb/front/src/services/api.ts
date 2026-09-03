import {
  Product,
  ProductInput,
} from "../types/Product";

const API_URL =
  "http://localhost:3000/api/products";

async function request<T>(
  url: string,
  options?: RequestInit
): Promise<T> {

  const response =
    await fetch(
      url,
      {
        headers: {
          "Content-Type":
            "application/json",

          ...(options?.headers ?? {}),
        },

        ...options,
      }
    );

  if (!response.ok) {

    const body =
      await response
        .json()
        .catch(() => null);

    throw new Error(
      body?.message ??
      "Erro na requisição."
    );
  }

  if (
    response.status === 204
  ) {
    return undefined as T;
  }

  return response.json();
}

export const productApi = {

  list: () =>
    request<Product[]>(
      API_URL
    ),

  getById: (
    id: string
  ) =>
    request<Product>(
      `${API_URL}/${id}`
    ),

  create: (
    data: ProductInput
  ) =>
    request<Product>(
      API_URL,
      {
        method: "POST",

        body:
          JSON.stringify(data),
      }
    ),

  update: (
    id: string,
    data: Partial<ProductInput>
  ) =>
    request<Product>(
      `${API_URL}/${id}`,
      {
        method: "PUT",

        body:
          JSON.stringify(data),
      }
    ),

  remove: (
    id: string
  ) =>
    request<void>(
      `${API_URL}/${id}`,
      {
        method: "DELETE",
      }
    ),
};
