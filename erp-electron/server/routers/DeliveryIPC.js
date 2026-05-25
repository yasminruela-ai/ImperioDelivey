import { ipcMain } from "electron";
import {
  listarDelivery,
  obterDelivery,
  alterarStatusDelivery,
} from "../controllers/DeliveryController.js";

ipcMain.handle("delivery:listar", async () => {
  return await listarDelivery();
});

ipcMain.handle("delivery:buscar", async (event, id) => {
  return await obterDelivery(id);
});

ipcMain.handle("delivery:atualizarStatus", async (event, { id, status }) => {
  return await alterarStatusDelivery(id, status);
});
