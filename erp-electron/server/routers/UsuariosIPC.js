import { ipcMain } from "electron";
import { listar, atualizar, criar } from "../controllers/UsuariosController.js";

ipcMain.handle("usuarios:listar", async () => {
  return await listar();
});

ipcMain.handle(
  "usuarios:alterarPermissoes",
  async (event, { idUsuario, permissoes }) => {
    return await atualizar(idUsuario, permissoes);
  }
);

ipcMain.handle("usuarios:criar", async (event, dadosUsuario) => {
  return await criar(dadosUsuario);
});
