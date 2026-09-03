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
  product?: Product | null;

  onSubmit:
    (
      data: ProductInput
    ) => Promise<void>;

  onCancel:
    () => void;
};

const emptyForm: ProductInput = {
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
  ] = useState<ProductInput>(
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

      <div className="form-header">

        <div className="form-icon">
          ✦
        </div>

        <div>

          <h2>
            {product
              ? "Editar produto"
              : "Novo produto"}
          </h2>

          <p>
            {product
              ? "Atualize as informações do produto."
              : "Cadastre um novo produto no sistema."}
          </p>

        </div>

      </div>


      <div className="form-content">

        <label className="field">

          <span>
            Nome do produto
          </span>

          <input
            required
            value={
              form.name
            }
            placeholder="Digite o nome do produto"
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


        <label className="field">

          <span>
            Descrição
          </span>

          <textarea
            value={
              form.description
            }
            placeholder="Conte um pouco sobre o produto..."
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


        <div className="form-section-title">

          Informações do produto

        </div>


        <div className="form-row">

          <label className="field">

            <span>
              Preço
            </span>

            <div className="input-prefix">

              <span>
                R$
              </span>

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

            </div>

          </label>


          <label className="field">

            <span>
              Estoque
            </span>

            <input
              required
              type="number"
              min="0"
              value={
                form.stock
              }
              placeholder="0"
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


        <div className="form-actions">

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

          <button
            type="submit"
            className="submit-button"
          >
            {product
              ? "Salvar alterações"
              : "Cadastrar produto"}
          </button>

        </div>

      </div>

    </form>

  );
}