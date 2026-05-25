import { conn, getIdUser } from "../db.js";
import { getUserTables } from "../controllers/PermissoesController.js";

export async function loginController({ usuario, senha }) {
  const result = await conn({ user: usuario, password: senha });

  if (!result.success) {
    return { success: false, error: result.error };
  }

  const permissoes = await getUserTables();

  return {
    success: true,
    idUser: result.idUser,
    permissoes,
  };
}
