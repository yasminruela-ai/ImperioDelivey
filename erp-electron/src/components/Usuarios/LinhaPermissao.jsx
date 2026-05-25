export default function LinhaPermissao({
  perm,
  userId,
  estilos,
  togglePermissao,
  podeCriar,
  podeEditar,
  podeRemover,
}) {
  return (
    <tr key={perm.idPermissoes}>
      <td className={`p-2 border ${estilos.tabelaCelula}`}>{perm.tabela}</td>

      {["select", "insert", "update", "delete"].map((tipo) => (
        <td key={tipo} className={`p-2 border ${estilos.tabelaCelula}`}>
          <input
            type="checkbox"
            disabled={
              (tipo === "insert" && !podeCriar) ||
              (tipo === "update" && !podeEditar) ||
              (tipo === "delete" && !podeRemover)
            }
            className="w-5 h-5 accent-yellow-500"
            checked={perm[tipo] === 1}
            onChange={() => togglePermissao(userId, perm.idPermissoes, tipo)}
          />
        </td>
      ))}
    </tr>
  );
}
