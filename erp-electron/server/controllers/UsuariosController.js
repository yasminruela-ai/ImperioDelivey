import {
  listarUsuariosComPermissoes,
  atualizarPermissaoUsuario,
  criarUsuarioMySQL,
} from "../models/Usuarios.js";

export async function listar() {
  const usuarios = await listarUsuariosComPermissoes();
  return usuarios;
}

export async function atualizar(idUsuario, permissoes) {
  const result = await atualizarPermissaoUsuario(idUsuario, permissoes);
  return result;
}

export async function criar(dadosUsuario) {
  const result = await criarUsuarioMySQL(dadosUsuario);
  return result;
}
