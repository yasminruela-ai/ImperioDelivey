import LinhaPermissao from "./LinhaPermissao";

export default function TabelaPermissoesUsuario({
  user,
  estilos,
  togglePermissao,
  podeCriar,
  podeEditar,
  podeRemover,
}) {
  return (
    <div className={`border rounded-xl p-5 shadow-md ${estilos.card}`}>
      <strong className={`text-lg ${estilos.titulo}`}>
        {user.nome} <span className="opacity-75 text-sm">({user.login})</span>
      </strong>

      {user.permissoes?.length > 0 ? (
        <div className="mt-4 overflow-x-auto">
          <table className="w-full text-center border-collapse">
            <thead>
              <tr className={estilos.tabelaHeader}>
                <th className={`p-2 border ${estilos.tabelaCelula}`}>Tabela</th>
                <th className={`p-2 border ${estilos.tabelaCelula}`}>
                  Visualizar
                </th>
                <th className={`p-2 border ${estilos.tabelaCelula}`}>
                  Cadastrar
                </th>
                <th className={`p-2 border ${estilos.tabelaCelula}`}>
                  Atualizar
                </th>
                <th className={`p-2 border ${estilos.tabelaCelula}`}>
                  Excluir
                </th>
              </tr>
            </thead>
            <tbody>
              {user.permissoes.map((perm) => (
                <LinhaPermissao
                  key={perm.idPermissoes}
                  perm={perm}
                  userId={user.id}
                  estilos={estilos}
                  togglePermissao={togglePermissao}
                  podeCriar={podeCriar}
                  podeEditar={podeEditar}
                  podeRemover={podeRemover}
                />
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <p className="opacity-70 mt-2">Nenhuma permissão cadastrada.</p>
      )}
    </div>
  );
}
