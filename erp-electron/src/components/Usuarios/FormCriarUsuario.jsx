export default function FormCriarUsuario({
  temaEscuro,
  estilos,
  novoUsuario,
  setNovoUsuario,
  criarUsuario,
}) {
  const estiloInput = temaEscuro
    ? "bg-[#130a05] text-white border-yellow-600"
    : "bg-white border-gray-400";

  return (
    <div className={`border rounded-xl p-6 shadow-lg ${estilos.card}`}>
      <h3 className={`text-xl font-bold ${estilos.titulo}`}>
        Criar novo usuário
      </h3>

      <form onSubmit={criarUsuario} className="grid gap-4 mt-6">
        <div className="grid sm:grid-cols-2 gap-4">
          <div>
            <label className={estilos.titulo}>Nome</label>
            <input
              type="text"
              className={`w-full mt-1 rounded-lg px-3 py-2 ${estiloInput}`}
              value={novoUsuario.nome}
              onChange={(e) =>
                setNovoUsuario({ ...novoUsuario, nome: e.target.value })
              }
            />
          </div>

          <div>
            <label className={estilos.titulo}>Login</label>
            <input
              type="text"
              className={`w-full mt-1 rounded-lg px-3 py-2 ${estiloInput}`}
              value={novoUsuario.login}
              onChange={(e) =>
                setNovoUsuario({ ...novoUsuario, login: e.target.value })
              }
            />
          </div>
        </div>

        <div>
          <label className={estilos.titulo}>Senha</label>
          <input
            type="password"
            className={`w-full mt-1 rounded-lg px-3 py-2 ${estiloInput}`}
            value={novoUsuario.senha}
            onChange={(e) =>
              setNovoUsuario({ ...novoUsuario, senha: e.target.value })
            }
          />
        </div>

        <button
          type="submit"
          className="bg-gradient-to-r from-yellow-400 to-red-600 text-black font-bold py-2 rounded-lg hover:opacity-90 transition"
        >
          Criar Usuário
        </button>
      </form>
    </div>
  );
}
