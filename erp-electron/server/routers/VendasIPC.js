import { ipcMain } from "electron";
import {
  listarTodasVendas,
  obterVenda,
  deletarVenda,
} from "../controllers/VendasController.js";

ipcMain.handle("vendasAdmin:listar", async () => {
  return await listarTodasVendas();
});

ipcMain.handle("vendasAdmin:buscar", async (event, id) => {
  return await obterVenda(id);
});

ipcMain.handle("vendasAdmin:remover", async (event, id) => {
  return await deletarVenda(id);
});
