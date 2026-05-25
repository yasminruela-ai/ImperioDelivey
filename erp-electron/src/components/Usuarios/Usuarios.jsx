import React, { useEffect, useState } from "react";
import FormCriarUsuario from "./FormCriarUsuario";
import TabelaPermissoesUsuario from "./TabelaPermissoesUsuario";

export default function Usuarios({ permissoes, temaEscuro }) {
  const [usuarios, setUsuarios] = useState([]);
  const [novoUsuario, setNovoUsuario] = useState({ nome: "", login: "", senha: "" });

  const podeCriar = permissoes?.insert || false;
  const podeEditar = permissoes?.update || false;
  const podeRemover = permissoes?.delete || false;

  const estilos = {
    fundoPagina: temaEscuro
      ? "bg-[#0d0703] text-yellow-200"
      : "bg-white text-black",

    card: temaEscuro
      ? "bg-[#1a0f06] border-yellow-600"
      : "bg-gray-100 border-gray-300",

    titulo: temaEscuro ? "text-yellow-300" : "text-black",
  };

  async function carregarUsuarios() {
    try {
      const retorno = await window.ipc.usuarios.listar();
      setUsuarios(Array.isArray(retorno) ? retorno : []);
    } catch {
      setUsuarios([]);
    }
  }

  async function criarUsuario(e) {
    e.preventDefault();

    if (!novoUsuario.nome || !novoUsuario.login || !novoUsuario.senha) {
      alert("Preencha todos os campos!");
      return;
    }

    try {
      const resultado = await window.ipc.usuarios.criar(novoUsuario);

      if (resultado?.sucesso) {
        alert("Usuário criado com sucesso!");
        setNovoUsuario({ nome: "", login: "", senha: "" });
        carregarUsuarios();
      }
    } catch {
      alert("Erro ao criar usuário.");
    }
  }

  const togglePermissao = async (idUsuario, idPermissao, campo) => {
    const novos = usuarios.map((u) => {
      if (u.id !== idUsuario) return u;

      return {
        ...u,
        permissoes: u.permissoes.map((p) =>
          p.idPermissoes === idPermissao
            ? { ...p, [campo]: p[campo] ? 0 : 1 }
            : p
        ),
      };
    });

    setUsuarios(novos);

    const usuario = novos.find((u) => u.id === idUsuario);

    try {
      await window.ipc.usuarios.alterarPermissoes({
        idUsuario,
        permissoes: usuario.permissoes,
      });
    } catch {}
  };

  useEffect(() => {
    carregarUsuarios();
  }, []);

  return (
    <div className={`p-6 space-y-6 min-h-screen transition ${estilos.fundoPagina}`}>
      <h2 className={`text-3xl font-black drop-shadow-md ${estilos.titulo}`}>
        Usuários & Permissões
      </h2>

      {podeCriar && (
        <FormCriarUsuario
          temaEscuro={temaEscuro}
          estilos={estilos}
          novoUsuario={novoUsuario}
          setNovoUsuario={setNovoUsuario}
          criarUsuario={criarUsuario}
        />
      )}

      {usuarios.length === 0 ? (
        <p className="opacity-70 text-center">Nenhum usuário cadastrado.</p>
      ) : (
        usuarios.map((user) => (
          <TabelaPermissoesUsuario
            key={user.id}
            user={user}
            temaEscuro={temaEscuro}
            estilos={estilos}
            togglePermissao={togglePermissao}
            podeCriar={podeCriar}
            podeEditar={podeEditar}
            podeRemover={podeRemover}
          />
        ))
      )}
    </div>
  );
}
