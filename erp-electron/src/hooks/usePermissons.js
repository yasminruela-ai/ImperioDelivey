import { useState, useEffect } from "react";

export default function usePermissions(logado) {
  const [tabelasMenu, setTabelasMenu] = useState([]);
  const [carregandoMenu, setCarregandoMenu] = useState(true);
  const [permissoesPorTabela, setPermissoesPorTabela] = useState({});

  useEffect(() => {
    if (!logado) return;

    const mapearTabelas = (permissions) => {
      const mapa = new Set();
      const hasSelect = (nome) =>
        permissions.some(
          (p) =>
            p.nome_tabela.toLowerCase() === nome.toLowerCase() &&
            p.permisaoSelect === 1
        );

      if (hasSelect("Vendas")) mapa.add("Vendas");
      if (hasSelect("Pedidos")) mapa.add("Pedidos");
      if (hasSelect("Funcionarios")) mapa.add("Funcionários");
      if (hasSelect("Produtos")) mapa.add("Produtos");
      if (hasSelect("Historico")) mapa.add("Histórico");

      return Array.from(mapa);
    };

    const fetchPermissions = async () => {
      setCarregandoMenu(true);
      try {
        const resposta = await window.ipc.getPermissions();

        if (resposta.success && Array.isArray(resposta.permissions)) {
          const map = {};
          resposta.permissions.forEach((p) => {
            map[p.nome_tabela.toLowerCase()] = {
              select: p.permisaoSelect === 1,
              insert: p.permisaoInsert === 1,
              update: p.permisaoUpdate === 1,
              delete: p.permisaoDelete === 1,
            };
          });

          setPermissoesPorTabela(map);

          const tabelasFiltradas = mapearTabelas(resposta.permissions);
          setTabelasMenu(tabelasFiltradas);
        } else {
          setTabelasMenu([]);
          setPermissoesPorTabela({});
        }
      } catch (err) {
        console.error("Erro ao buscar permissões:", err);
        setTabelasMenu([]);
        setPermissoesPorTabela({});
      } finally {
        setCarregandoMenu(false);
      }
    };

    fetchPermissions();
  }, [logado]);

  return { tabelasMenu, carregandoMenu, permissoesPorTabela };
}
