#!/bin/bash

set -e

echo "=========================================="
echo "   CRIANDO CRUD NODE + MONGODB + REACT"
echo "=========================================="

PROJECT="crud-node-mongodb"

# =========================================================
# 1. CRIA ESTRUTURA
# =========================================================

mkdir -p "$PROJECT"/back/src/{config,controllers,middlewares,models,repositories,routes,services}
mkdir -p "$PROJECT"/front/src/{components,services,types}

cd "$PROJECT"

echo "✓ Estrutura criada"

# =========================================================
# 2. ARQUIVO RAIZ - package.json
# =========================================================

cat > package.json <<'EOF'
{
  "name": "crud-node-mongodb",
  "private": true,
  "scripts": {
    "install:all": "npm install --prefix back && npm install --prefix front",
    "dev": "concurrently \"npm run dev --prefix back\" \"npm run dev --prefix front\"",
    "build": "npm run build --prefix back && npm run build --prefix front"
  },
  "devDependencies": {
    "concurrently": "^9.2.1"
  }
}
EOF

# =========================================================
# 3. BACKEND package.json
# =========================================================

cat > back/package.json <<'EOF'
{
  "name": "crud-backend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.6.1",
    "express": "^5.1.0",
    "mongoose": "^8.18.0"
  },
  "devDependencies": {
    "@types/cors": "^2.8.19",
    "@types/express": "^5.0.3",
    "@types/node": "^24.3.0",
    "tsx": "^4.20.5",
    "typescript": "^5.9.2"
  }
}
EOF

# =========================================================
# 4. BACKEND tsconfig
# =========================================================

cat > back/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "CommonJS",
    "moduleResolution": "Node",
    "rootDir": "src",
    "outDir": "dist",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
EOF

# =========================================================
# 5. ENV
# =========================================================

cat > back/.env.example <<'EOF'
PORT=3000
MONGODB_URI=mongodb://127.0.0.1:27017/crud_node
CORS_ORIGIN=http://localhost:5173
EOF

cp back/.env.example back/.env

# =========================================================
# 6. CONFIG ENV
# =========================================================

cat > back/src/config/env.ts <<'EOF'
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
EOF

# =========================================================
# 7. DATABASE
# =========================================================

cat > back/src/config/database.ts <<'EOF'
import mongoose from "mongoose";
import { env } from "./env";

export async function connectDatabase(): Promise<void> {
  await mongoose.connect(env.mongoUri);

  console.log("✓ MongoDB conectado");
}
EOF

# =========================================================
# 8. MODEL
# =========================================================

cat > back/src/models/Product.ts <<'EOF'
import { Schema, model, Document } from "mongoose";

export interface IProduct extends Document {
  name: string;
  description: string;
  price: number;
  stock: number;
  createdAt: Date;
  updatedAt: Date;
}

const productSchema = new Schema<IProduct>(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
    },

    description: {
      type: String,
      default: "",
      trim: true,
    },

    price: {
      type: Number,
      required: true,
      min: 0,
    },

    stock: {
      type: Number,
      required: true,
      min: 0,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

export const ProductModel =
  model<IProduct>("Product", productSchema);
EOF

# =========================================================
# 9. REPOSITORY
# =========================================================

cat > back/src/repositories/ProductRepository.ts <<'EOF'
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
EOF

# =========================================================
# 10. SERVICE
# =========================================================

cat > back/src/services/ProductService.ts <<'EOF'
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
EOF

# =========================================================
# 11. CONTROLLER
# =========================================================

cat > back/src/controllers/ProductController.ts <<'EOF'
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
EOF

# =========================================================
# 12. ROTAS
# =========================================================

cat > back/src/routes/productRoutes.ts <<'EOF'
import { Router } from "express";

import {
  ProductController,
} from "../controllers/ProductController";

const router = Router();

const controller =
  new ProductController();

router.get(
  "/",
  controller.getAll
);

router.get(
  "/:id",
  controller.getById
);

router.post(
  "/",
  controller.create
);

router.put(
  "/:id",
  controller.update
);

router.delete(
  "/:id",
  controller.delete
);

export default router;
EOF

# =========================================================
# 13. ERROR HANDLER
# =========================================================

cat > back/src/middlewares/errorHandler.ts <<'EOF'
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
EOF

# =========================================================
# 14. APP
# =========================================================

cat > back/src/app.ts <<'EOF'
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
EOF

# =========================================================
# 15. SERVER
# =========================================================

cat > back/src/server.ts <<'EOF'
import { app } from "./app";

import {
  connectDatabase,
} from "./config/database";

import { env } from "./config/env";

async function bootstrap() {

  try {

    await connectDatabase();

    app.listen(
      env.port,
      () => {

        console.log(
          `✓ API rodando em http://localhost:${env.port}`
        );

      }
    );

  } catch (error) {

    console.error(
      "Erro ao iniciar servidor:",
      error
    );

    process.exit(1);
  }
}

bootstrap();
EOF

# =========================================================
# 16. FRONTEND package.json
# =========================================================

cat > front/package.json <<'EOF'
{
  "name": "crud-frontend",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "@vitejs/plugin-react": "^5.0.2",
    "vite": "^7.2.4",
    "react": "^19.1.1",
    "react-dom": "^19.1.1"
  },
  "devDependencies": {
    "@types/react": "^19.1.10",
    "@types/react-dom": "^19.1.7",
    "typescript": "^5.9.2"
  }
}
EOF

# =========================================================
# 17. FRONTEND tsconfig
# =========================================================

cat > front/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "useDefineForClassFields": true,
    "lib": [
      "ES2022",
      "DOM",
      "DOM.Iterable"
    ],
    "allowJs": false,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": [
    "src"
  ]
}
EOF

# =========================================================
# 18. VITE
# =========================================================

cat > front/vite.config.ts <<'EOF'
import {
  defineConfig
} from "vite";

import react from
  "@vitejs/plugin-react";

export default defineConfig({
  plugins: [
    react()
  ],
});
EOF

# =========================================================
# 19. HTML
# =========================================================

cat > front/index.html <<'EOF'
<!doctype html>

<html lang="pt-BR">

<head>

  <meta charset="UTF-8" />

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  />

  <title>
    CRUD Produtos
  </title>

</head>

<body>

  <div id="root"></div>

  <script
    type="module"
    src="/src/main.tsx">
  </script>

</body>

</html>
EOF

# =========================================================
# 20. TYPE PRODUCT
# =========================================================

cat > front/src/types/Product.ts <<'EOF'
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
EOF

# =========================================================
# 21. API
# =========================================================

cat > front/src/services/api.ts <<'EOF'
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
EOF

# =========================================================
# 22. FORM
# =========================================================

cat > front/src/components/ProductForm.tsx <<'EOF'
import {
  FormEvent,
  useEffect,
  useState,
} from "react";

import {
  Product,
  ProductInput,
} from "../types/Product";

type Props = {

  product?:
    Product | null;

  onSubmit:
    (
      data: ProductInput
    ) => Promise<void>;

  onCancel:
    () => void;
};

const emptyForm:
  ProductInput = {

  name: "",

  description: "",

  price: 0,

  stock: 0,
};

export function ProductForm({
  product,
  onSubmit,
  onCancel,
}: Props) {

  const [
    form,
    setForm
  ] =
    useState<ProductInput>(
      emptyForm
    );

  useEffect(() => {

    if (product) {

      setForm({
        name:
          product.name,

        description:
          product.description,

        price:
          product.price,

        stock:
          product.stock,
      });

    } else {

      setForm(
        emptyForm
      );
    }

  }, [product]);

  const handleSubmit =
    async (
      event: FormEvent
    ) => {

      event.preventDefault();

      await onSubmit(
        form
      );

      setForm(
        emptyForm
      );
    };

  return (

    <form
      className="form"
      onSubmit={
        handleSubmit
      }
    >

      <h2>
        {product
          ? "Editar produto"
          : "Novo produto"}
      </h2>

      <label>

        Nome

        <input
          required
          value={
            form.name
          }
          onChange={
            (e) =>
              setForm({
                ...form,
                name:
                  e.target.value,
              })
          }
        />

      </label>

      <label>

        Descrição

        <textarea
          value={
            form.description
          }
          onChange={
            (e) =>
              setForm({
                ...form,
                description:
                  e.target.value,
              })
          }
        />

      </label>

      <div
        className="form-row"
      >

        <label>

          Preço

          <input
            required
            type="number"
            min="0"
            step="0.01"
            value={
              form.price
            }
            onChange={
              (e) =>
                setForm({
                  ...form,
                  price:
                    Number(
                      e.target.value
                    ),
                })
            }
          />

        </label>

        <label>

          Estoque

          <input
            required
            type="number"
            min="0"
            value={
              form.stock
            }
            onChange={
              (e) =>
                setForm({
                  ...form,
                  stock:
                    Number(
                      e.target.value
                    ),
                })
            }
          />

        </label>

      </div>

      <div
        className="actions"
      >

        <button
          type="submit"
        >
          {product
            ? "Salvar alterações"
            : "Cadastrar"}
        </button>

        {product && (

          <button
            type="button"
            className="secondary"
            onClick={
              onCancel
            }
          >
            Cancelar
          </button>

        )}

      </div>

    </form>
  );
}
EOF

# =========================================================
# 23. TABLE
# =========================================================

cat > front/src/components/ProductTable.tsx <<'EOF'
import {
  Product,
} from "../types/Product";

type Props = {

  products:
    Product[];

  onEdit:
    (
      product: Product
    ) => void;

  onDelete:
    (
      id: string
    ) => void;
};

export function ProductTable({
  products,
  onEdit,
  onDelete,
}: Props) {

  if (
    products.length === 0
  ) {

    return (
      <p className="empty">
        Nenhum produto
        cadastrado.
      </p>
    );
  }

  return (

    <div
      className="table-wrapper"
    >

      <table>

        <thead>

          <tr>

            <th>
              Nome
            </th>

            <th>
              Descrição
            </th>

            <th>
              Preço
            </th>

            <th>
              Estoque
            </th>

            <th>
              Ações
            </th>

          </tr>

        </thead>

        <tbody>

          {products.map(
            (product) => (

              <tr
                key={
                  product._id
                }
              >

                <td>
                  {product.name}
                </td>

                <td>
                  {
                    product.description ||
                    "-"
                  }
                </td>

                <td>

                  {product.price.toLocaleString(
                    "pt-BR",
                    {
                      style:
                        "currency",

                      currency:
                        "BRL",
                    }
                  )}

                </td>

                <td>
                  {product.stock}
                </td>

                <td
                  className="actions"
                >

                  <button
                    onClick={() =>
                      onEdit(
                        product
                      )
                    }
                  >
                    Editar
                  </button>

                  <button
                    className="danger"
                    onClick={() =>
                      onDelete(
                        product._id
                      )
                    }
                  >
                    Excluir
                  </button>

                </td>

              </tr>

            )
          )}

        </tbody>

      </table>

    </div>
  );
}
EOF

# =========================================================
# 24. APP
# =========================================================

cat > front/src/App.tsx <<'EOF'
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

        <p>
          Node.js + Express +
          MongoDB + React
        </p>

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
EOF

# =========================================================
# 25. MAIN
# =========================================================

cat > front/src/main.tsx <<'EOF'
import {
  StrictMode,
} from "react";

import {
  createRoot,
} from "react-dom/client";

import App from "./App";

createRoot(
  document.getElementById(
    "root"
  )!
).render(

  <StrictMode>

    <App />

  </StrictMode>
);
EOF

# =========================================================
# 26. CSS
# =========================================================

cat > front/src/styles.css <<'EOF'
* {
  box-sizing: border-box;
}

body {
  margin: 0;

  font-family:
    Arial,
    sans-serif;

  background: #f4f6f8;

  color: #222;
}

button,
input,
textarea {
  font: inherit;
}

.container {
  width: min(
    1100px,
    92%
  );

  margin:
    40px auto;
}

header {
  margin-bottom:
    24px;
}

header h1 {
  margin-bottom:
    6px;
}

header p {
  color:
    #666;
}

.card {
  background:
    white;

  border-radius:
    12px;

  padding:
    24px;

  margin-bottom:
    24px;

  box-shadow:
    0 4px 18px
    rgba(
      0,
      0,
      0,
      0.07
    );
}

.form {
  display:
    flex;

  flex-direction:
    column;

  gap:
    16px;
}

.form h2,
.section-header h2 {
  margin:
    0 0 4px;
}

label {
  display:
    flex;

  flex-direction:
    column;

  gap:
    7px;

  font-weight:
    600;
}

input,
textarea {
  border:
    1px solid
    #ccd2d8;

  border-radius:
    7px;

  padding:
    10px 12px;

  width:
    100%;
}

textarea {
  min-height:
    90px;

  resize:
    vertical;
}

.form-row {
  display:
    grid;

  grid-template-columns:
    1fr 1fr;

  gap:
    16px;
}

button {
  border:
    0;

  border-radius:
    7px;

  padding:
    10px 15px;

  cursor:
    pointer;

  background:
    #2563eb;

  color:
    white;
}

button:hover {
  opacity:
    0.9;
}

button.secondary {
  background:
    #64748b;
}

button.danger {
  background:
    #dc2626;
}

.actions {
  display:
    flex;

  gap:
    8px;
}

.section-header {
  display:
    flex;

  align-items:
    center;

  justify-content:
    space-between;

  margin-bottom:
    18px;
}

.table-wrapper {
  overflow-x:
    auto;
}

table {
  border-collapse:
    collapse;

  width:
    100%;
}

th,
td {
  padding:
    12px;

  border-bottom:
    1px solid
    #e5e7eb;

  text-align:
    left;
}

th {
  background:
    #f8fafc;
}

.empty {
  color:
    #777;

  text-align:
    center;

  padding:
    30px;
}

.error {
  background:
    #fee2e2;

  color:
    #991b1b;

  border:
    1px solid
    #fecaca;

  border-radius:
    8px;

  padding:
    12px;

  margin-bottom:
    20px;
}

@media (
  max-width: 700px
) {

  .form-row {
    grid-template-columns:
      1fr;
  }

  .container {
    margin:
      20px auto;
  }

  .card {
    padding:
      16px;
  }
}
EOF

# =========================================================
# 27. GITIGNORE
# =========================================================

cat > .gitignore <<'EOF'
node_modules/
back/node_modules/
front/node_modules/

back/dist/
front/dist/

back/.env

*.log
EOF

# =========================================================
# 28. README
# =========================================================

cat > README.md <<'EOF'
# CRUD Node.js + MongoDB + React

CRUD básico de produtos.

## Backend

Node.js + Express + TypeScript + Mongoose.

## Frontend

React + Vite + TypeScript.

## MongoDB

Por padrão:

mongodb://127.0.0.1:27017/crud_node

## Executar

Na raiz:

npm install

npm run install:all

npm run dev

Frontend:

http://localhost:5173

Backend:

http://localhost:3000

Health check:

http://localhost:3000/api/health
EOF

# =========================================================
# 29. INSTALA DEPENDÊNCIAS
# =========================================================

echo ""
echo "=========================================="
echo " INSTALANDO DEPENDÊNCIAS"
echo "=========================================="

npm install

cd back
npm install

cd ../front
npm install

cd ..

# =========================================================
# FINAL
# =========================================================

echo ""
echo "=========================================="
echo "       PROJETO CRIADO COM SUCESSO!"
echo "=========================================="
echo ""
echo "Pasta:"
echo "$(pwd)"
echo ""
echo "Para iniciar:"
echo ""
echo "cd $PROJECT"
echo "npm run dev"
echo ""
echo "Frontend:"
echo "http://localhost:5173"
echo ""
echo "Backend:"
echo "http://localhost:3000"
echo ""
echo "MongoDB:"
echo "mongodb://127.0.0.1:27017/crud_node"
echo ""
