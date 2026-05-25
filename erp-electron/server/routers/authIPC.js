import { ipcMain } from "electron";
import { loginController } from "../controllers/AuthController.js";
import { getUserTables } from "../controllers/PermissoesController.js";

ipcMain.handle("login", async (event, { usuario, senha }) => {
  return await loginController({ usuario, senha });
});

ipcMain.handle("get-permissions", async (event, idUsuario) => {
  return await getUserTables(idUsuario);
});
