export function mapearTabelas(permissions) {
  const mapa = new Set();

  const hasSelect = (nome) =>
    permissions.some(
      (p) =>
        p.nome_tabela.toLowerCase() === nome.toLowerCase() &&
        p.permisaoSelect === 1
    );

  if (hasSelect("Vendas")) {
    mapa.add("Pedidos");
    mapa.add("Vendas");
  }
  if (hasSelect("Funcionarios")) mapa.add("Funcionários");
  if (hasSelect("Produtos")) mapa.add("Produtos");
  if (hasSelect("Historico")) mapa.add("Histórico");

  return Array.from(mapa);
}
