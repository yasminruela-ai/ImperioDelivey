import { app, BrowserWindow } from "electron";
import path from "path";
import { fileURLToPath } from "url";
import { iniciarApiIntegracao } from "./server/apiIntegracao.js";

// IPC handlers
import "./server/routers/authIPC.js";
import "./server/routers/CategoriasIPC.js";
import "./server/routers/ProdutosIPC.js";
import "./server/routers/PedidosIPC.js";
import "./server/routers/VendasIPC.js";
import "./server/routers/HistoricoIPC.js";
import "./server/routers/UsuariosIPC.js";
import "./server/routers/DashboardIPC.js";
import "./server/routers/DeliveryIPC.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function createWindow() {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false,
    },
  });

  const isDev = !app.isPackaged;

  if (isDev) {
    // Ambiente de desenvolvimento (Vite)
    win.loadURL("http://localhost:5173");
  } else {
    // Ambiente de produção (Electron-builder)
    win.loadFile(path.join(__dirname, "dist/index.html"));
  }
}

app.disableHardwareAcceleration();

app.whenReady().then(async () => {
  await iniciarApiIntegracao();
  createWindow();
});
