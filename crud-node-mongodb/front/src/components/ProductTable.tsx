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
