import { ipcMain } from "electron";
import {
  listarTodasCategorias,
  obterCategoriaPorId,
  criarCategoria,
  editarCategoria,
  removerCategoria,
} from "../controllers/CategoriasControllers.js";

ipcMain.handle("categorias:listar", async () => {
  return await listarTodasCategorias();
});

ipcMain.handle("categorias:buscarPorId", async (event, id) => {
  return await obterCategoriaPorId(id);
});

ipcMain.handle("categorias:criar", async (event, nome) => {
  return await criarCategoria(nome);
});

ipcMain.handle("categorias:editar", async (event, { id, nome }) => {
  return await editarCategoria(id, nome);
});

ipcMain.handle("categorias:remover", async (event, id) => {
  return await removerCategoria(id);
});
