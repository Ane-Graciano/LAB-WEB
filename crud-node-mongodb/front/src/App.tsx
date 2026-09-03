import {
  useEffect,
  useState,
} from "react";

import {
  Product,
  ProductInput,
} from "./types/Product";

import {
  productApi,
} from "./services/api";

import {
  ProductForm,
} from "./components/ProductForm";

import {
  ProductTable,
} from "./components/ProductTable";

import "./styles.css";

export default function App() {

  const [
    products,
    setProducts
  ] =
    useState<Product[]>(
      []
    );

  const [
    editingProduct,
    setEditingProduct
  ] =
    useState<Product | null>(
      null
    );

  const [
    error,
    setError
  ] =
    useState("");

  async function loadProducts() {

    try {

      setError("");

      setProducts(
        await productApi.list()
      );

    } catch (err) {

      setError(
        err instanceof Error
          ? err.message
          : "Erro ao carregar."
      );
    }
  }

  useEffect(() => {

    loadProducts();

  }, []);

  async function handleSubmit(
    data: ProductInput
  ) {

    try {

      setError("");

      if (
        editingProduct
      ) {

        await productApi.update(
          editingProduct._id,
          data
        );

        setEditingProduct(
          null
        );

      } else {

        await productApi.create(
          data
        );
      }

      await loadProducts();

    } catch (err) {

      setError(
        err instanceof Error
          ? err.message
          : "Erro ao salvar."
      );
    }
  }

  async function handleDelete(
    id: string
  ) {

    if (
      !window.confirm(
        "Deseja realmente excluir este produto?"
      )
    ) {
      return;
    }

    try {

      setError("");

      await productApi.remove(
        id
      );

      await loadProducts();

    } catch (err) {

      setError(
        err instanceof Error
          ? err.message
          : "Erro ao excluir."
      );
    }
  }

  return (

    <main
      className="container"
    >

      <header>

        <h1>
          CRUD de Produtos
        </h1>

      </header>

      {error && (

        <div
          className="error"
        >
          {error}
        </div>

      )}

      <section
        className="card"
      >

        <ProductForm
          product={
            editingProduct
          }
          onSubmit={
            handleSubmit
          }
          onCancel={() =>
            setEditingProduct(
              null
            )
          }
        />

      </section>

      <section
        className="card"
      >

        <div
          className="section-header"
        >

          <h2>
            Produtos cadastrados
          </h2>

          <button
            onClick={
              loadProducts
            }
          >
            Atualizar
          </button>

        </div>

        <ProductTable
          products={
            products
          }
          onEdit={
            setEditingProduct
          }
          onDelete={
            handleDelete
          }
        />

      </section>

    </main>
  );
}
