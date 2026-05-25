import { ipcMain } from "electron";
import {
  listarTodosProdutos,
  obterProdutoPorId,
  criarProduto,
  editarProduto,
  removerProduto,
} from "../controllers/ProdutosController.js";

ipcMain.handle("produtos:listar", async () => {
  return await listarTodosProdutos();
});

ipcMain.handle("produtos:buscarPorId", async (event, id) => {
  return await obterProdutoPorId(id);
});

ipcMain.handle(
  "produtos:criar",
  async (event, { nome, preco, categoriaId }) => {
    return await criarProduto(nome, preco, categoriaId);
  }
);

ipcMain.handle(
  "produtos:editar",
  async (event, { id, nome, preco, categoriaId }) => {
    return await editarProduto(id, nome, preco, categoriaId);
  }
);

ipcMain.handle("produtos:remover", async (event, id) => {
  return await removerProduto(id);
});
