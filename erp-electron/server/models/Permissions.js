import { getDb, getIdUser } from "../db.js";

export async function buscarPermissoesDoBanco() {
  const id = getIdUser();

  if (!id) {
    throw new Error("Usuario nao esta logado ou ID nao encontrado.");
  }

  const { data, error } = await getDb()
    .from("usuarios_permissoes")
    .select("permissao_select, permissao_insert, permissao_update, permissao_delete, permissoes(tabela)")
    .eq("usuario_id", id);

  if (error) throw new Error(error.message);

  return data.map((up) => ({
    nome_tabela: up.permissoes?.tabela ?? null,
    permisaoSelect: up.permissao_select,
    permisaoInsert: up.permissao_insert,
    permisaoUpdate: up.permissao_update,
    permisaoDelete: up.permissao_delete,
  }));
}
