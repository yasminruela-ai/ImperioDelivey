import { useEffect, useState } from "react";

export default function useDashboardData() {
  const [carregando, setCarregando] = useState(true);
  const [dados, setDados] = useState({
    categorias: [],
    vendasMes: [],
    vendasDia: [],
    vendasUsuario: [],
  });

  useEffect(() => {
    async function carregarDados() {
      setCarregando(true);
      const resposta = await window.ipc.dashboard.completo();
      if (resposta.success) {
        setDados(resposta.data);
      }
      setCarregando(false);
    }
    carregarDados();
  }, []);

  return { carregando, dados };
}
