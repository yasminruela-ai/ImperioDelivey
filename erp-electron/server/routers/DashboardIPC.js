import { ipcMain } from "electron";
import {
  obterCategoriaVenda,
  obterQuantidadeVenda,
  obterVendaMes,
  obterVendaUsuario,
  obterVendaUsuarioPorMes,
  obterDashboardCompleto,
} from "../controllers/DashboardController.js";

ipcMain.handle("dashboard:categoriaVenda", async () => {
  return await obterCategoriaVenda();
});

ipcMain.handle("dashboard:quantidadeVenda", async () => {
  return await obterQuantidadeVenda();
});

ipcMain.handle("dashboard:vendaMes", async () => {
  return await obterVendaMes();
});

ipcMain.handle("dashboard:vendaUsuario", async () => {
  return await obterVendaUsuario();
});

ipcMain.handle("dashboard:vendaUsuarioPorMes", async (event, mesAno) => {
  return await obterVendaUsuarioPorMes(mesAno);
});

ipcMain.handle("dashboard:completo", async () => {
  return await obterDashboardCompleto();
});
