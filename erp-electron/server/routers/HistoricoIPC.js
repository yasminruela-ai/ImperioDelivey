import { ipcMain } from "electron";
import {
  listarHistorico,
  obterLogPorId,
} from "../controllers/HistoricoController.js";

ipcMain.handle("historico:listar", async (event, filtros) => {
  return await listarHistorico(filtros);
});

ipcMain.handle("historico:buscarPorId", async (event, id) => {
  return await obterLogPorId(id);
});
