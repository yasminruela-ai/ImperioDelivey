import { contextBridge, ipcRenderer } from "electron";

contextBridge.exposeInMainWorld("ipc", {
  login: async (usuario, senha) => {
    return await ipcRenderer.invoke("login", { usuario, senha });
  },

  getPermissions: async (idUsuario) => {
    return await ipcRenderer.invoke("get-permissions", idUsuario);
  },

  categorias: {
    listar: async () => {
      return await ipcRenderer.invoke("categorias:listar");
    },
    buscarPorId: async (id) => {
      return await ipcRenderer.invoke("categorias:buscarPorId", id);
    },
    criar: async (nome) => {
      return await ipcRenderer.invoke("categorias:criar", nome);
    },
    editar: async (id, nome) => {
      return await ipcRenderer.invoke("categorias:editar", { id, nome });
    },
    remover: async (id) => {
      return await ipcRenderer.invoke("categorias:remover", id);
    },
  },

  produtos: {
    listar: async () => {
      return await ipcRenderer.invoke("produtos:listar");
    },
    buscarPorId: async (id) => {
      return await ipcRenderer.invoke("produtos:buscarPorId", id);
    },
    criar: async (nome, preco, categoriaId) => {
      return await ipcRenderer.invoke("produtos:criar", {
        nome,
        preco,
        categoriaId,
      });
    },
    editar: async (id, nome, preco, categoriaId) => {
      return await ipcRenderer.invoke("produtos:editar", {
        id,
        nome,
        preco,
        categoriaId,
      });
    },
    remover: async (id) => {
      return await ipcRenderer.invoke("produtos:remover", id);
    },
  },

  vendas: {
    listar: async () => {
      return await ipcRenderer.invoke("vendas:listar");
    },
    buscarPorId: async (id) => {
      return await ipcRenderer.invoke("vendas:buscar", id);
    },
    registrar: async (nome, usuarioId, itens) => {
      return await ipcRenderer.invoke("vendas:registrar", {
        nome,
        itens,
      });
    },
    atualizarStatus: async (id, status) => {
      return await ipcRenderer.invoke("vendas:atualizarStatus", { id, status });
    },
    remover: async (id) => {
      return await ipcRenderer.invoke("vendas:remover", id);
    },
  },
  vendasAdmin: {
    listar: async () => {
      return await ipcRenderer.invoke("vendasAdmin:listar");
    },
    buscarPorId: async (id) => {
      return await ipcRenderer.invoke("vendasAdmin:buscar", id);
    },
    remover: async (id) => {
      return await ipcRenderer.invoke("vendasAdmin:remover", id);
    },
  },

  historico: {
    listar: async (filtros = {}) => {
      return await ipcRenderer.invoke("historico:listar", filtros);
    },
    buscarPorId: async (id) => {
      return await ipcRenderer.invoke("historico:buscarPorId", id);
    },
  },

  usuarios: {
    listar: () => ipcRenderer.invoke("usuarios:listar"),

    alterarPermissoes: ({ idUsuario, permissoes }) =>
      ipcRenderer.invoke("usuarios:alterarPermissoes", {
        idUsuario,
        permissoes,
      }),

    criar: ({ nome, login, senha }) =>
      ipcRenderer.invoke("usuarios:criar", {
        nome,
        login,
        senha,
      }),
  },

  delivery: {
    listar: async () => ipcRenderer.invoke("delivery:listar"),
    buscarPorId: async (id) => ipcRenderer.invoke("delivery:buscar", id),
    atualizarStatus: async (id, status) =>
      ipcRenderer.invoke("delivery:atualizarStatus", { id, status }),
  },

  dashboard: {
    categoriaVenda: async () => {
      return await ipcRenderer.invoke("dashboard:categoriaVenda");
    },
    quantidadeVenda: async () => {
      return await ipcRenderer.invoke("dashboard:quantidadeVenda");
    },
    vendaMes: async () => {
      return await ipcRenderer.invoke("dashboard:vendaMes");
    },
    vendaUsuario: async () => {
      return await ipcRenderer.invoke("dashboard:vendaUsuario");
    },
    vendaUsuarioPorMes: async (mesAno) => {
      return await ipcRenderer.invoke("dashboard:vendaUsuarioPorMes", mesAno);
    },
    completo: async () => {
      return await ipcRenderer.invoke("dashboard:completo");
    },
  },
});
