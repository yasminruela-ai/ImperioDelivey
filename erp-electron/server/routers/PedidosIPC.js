import { ipcMain } from "electron";
import {
  registrarVenda,
  listarTodasVendas,
  obterVenda,
  alterarStatus,
} from "../controllers/PedidosController.js";

ipcMain.handle("vendas:listar", async () => {
  return await listarTodasVendas();
});

ipcMain.handle("vendas:registrar", async (event, { nome, itens }) => {
  return await registrarVenda(nome, itens);
});

ipcMain.handle("vendas:buscar", async (event, id) => {
  return await obterVenda(id);
});

ipcMain.handle("vendas:atualizarStatus", async (event, { id, status }) => {
  return await alterarStatus(id, status);
});

ipcMain.handle("vendas:remover", async (event, id) => {
  return await alterarStatus(id, "cancelado");
});
