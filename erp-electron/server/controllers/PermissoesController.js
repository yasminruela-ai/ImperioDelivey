import { buscarPermissoesDoBanco } from "../models/Permissions.js";

let userPermissions = null;

export async function getUserTables() {
  try {
    const rows = await buscarPermissoesDoBanco();
    userPermissions = rows;

    const tables = rows.map((row) => row.nome_tabela);

    return { success: true, tables, permissions: rows };
  } catch (err) {
    console.error("Erro ao buscar tabelas:", err.message);
    return { success: false, message: "Erro ao buscar tabelas." };
  }
}

export function getUserPermissions() {
  return userPermissions;
}

export function canUser(tableName, action) {
  if (!userPermissions) return false;

  const permission = userPermissions.find(
    (p) => p.nome_tabela.toLowerCase() === tableName.toLowerCase()
  );

  if (!permission) return false;

  switch (action.toLowerCase()) {
    case "select":
      return !!permission.permisaoSelect;
    case "insert":
      return !!permission.permisaoInsert;
    case "update":
      return !!permission.permisaoUpdate;
    case "delete":
      return !!permission.permisaoDelete;
    default:
      return false;
  }
}
