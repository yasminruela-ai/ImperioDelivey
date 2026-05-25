import { getDb } from "../db.js";
import bcrypt from "bcryptjs";

export async function listarUsuariosComPermissoes() {
  const { data, error } = await getDb()
    .from("usuarios")
    .select(`
      id, nome, login, ativo,
      usuarios_permissoes (
        permissao_id,
        permissao_select,
        permissao_insert,
        permissao_update,
        permissao_delete,
        permissoes ( id, tabela )
      )
    `)
    .eq("ativo", true);

  if (error) throw new Error(error.message);

  return data.map((u) => ({
    id: u.id,
    nome: u.nome,
    login: u.login,
    ativo: u.ativo,
    permissoes: (u.usuarios_permissoes || []).map((up) => ({
      idPermissoes: up.permissao_id,
      tabela: up.permissoes?.tabela ?? null,
      select: up.permissao_select,
      insert: up.permissao_insert,
      update: up.permissao_update,
      delete: up.permissao_delete,
    })),
  }));
}

export async function atualizarPermissaoUsuario(idUsuario, permissoes) {
  const db = getDb();
  for (const perm of permissoes) {
    const { error } = await db
      .from("usuarios_permissoes")
      .update({
        permissao_select: perm.select,
        permissao_insert: perm.insert,
        permissao_update: perm.update,
        permissao_delete: perm.delete,
      })
      .eq("usuario_id", idUsuario)
      .eq("permissao_id", perm.idPermissoes);

    if (error) throw new Error(error.message);
  }
  return true;
}

export async function criarUsuarioMySQL({ nome, login, senha }) {
  const db = getDb();

  const senhaCriptografada = await bcrypt.hash(senha, 10);

  const { data: usuario, error: errU } = await db
    .from("usuarios")
    .insert({ nome, login, senha: senhaCriptografada, ativo: true })
    .select("id")
    .single();

  if (errU) return { sucesso: false, erro: errU.message };

  const { data: todasPermissoes, error: errP } = await db
    .from("permissoes")
    .select("id");

  if (errP) return { sucesso: false, erro: errP.message };

  const linhasPermissoes = todasPermissoes.map((p) => ({
    usuario_id: usuario.id,
    permissao_id: p.id,
    permissao_select: false,
    permissao_insert: false,
    permissao_update: false,
    permissao_delete: false,
  }));

  const { error: errI } = await db
    .from("usuarios_permissoes")
    .insert(linhasPermissoes);

  if (errI) return { sucesso: false, erro: errI.message };

  return { sucesso: true, idUsuario: usuario.id };
}
