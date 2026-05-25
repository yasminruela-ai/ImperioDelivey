import React, { useState } from "react";
import { FaEye, FaEyeSlash } from "react-icons/fa";
import backgroundImg from "../images/back.png";
import logoImg from "../images/logo reansparente.png";

const Login = ({ onLoginSucesso }) => {
  const [usuario, setUsuario] = useState("");
  const [senha, setSenha] = useState("");
  const [mostrarSenha, setMostrarSenha] = useState(false);
  const [mensagem, setMensagem] = useState("");
  const [carregando, setCarregando] = useState(false);

  const handleToggleSenha = () => setMostrarSenha(!mostrarSenha);

  const handleLogin = async () => {
    if (!usuario || !senha) {
      setMensagem("Preencha todos os campos!");
      return;
    }

    setCarregando(true);
    setMensagem("");

    try {
      const resposta = await window.ipc.login(usuario, senha);

      if (resposta.success) {
        setMensagem("Login realizado com sucesso!");
        setTimeout(() => onLoginSucesso(resposta), 800);
      } else {
        setMensagem(resposta.error || "Usuário ou senha incorretos.");
      }
    } catch {
      setMensagem("Erro interno. Tente novamente mais tarde.");
    } finally {
      setCarregando(false);
    }
  };

  return (
    <div
      className="flex justify-center items-center h-screen bg-cover bg-center"
      style={{ backgroundImage: `url(${backgroundImg})` }}
    >
      <div className="bg-white/15 backdrop-blur-lg rounded-2xl p-6 w-80 text-center shadow-xl border border-white/20 animate-fade-in">
        <div className="mb-4 inline-block p-2 rounded-lg transition-transform duration-300 hover:scale-105">
          <img
            src={logoImg}
            alt="Logo da empresa"
            className="max-w-[100px] h-auto mx-auto"
          />
        </div>

        <form
          onSubmit={(e) => e.preventDefault()}
          className="text-left text-white"
        >
          <label htmlFor="usuario" className="block font-bold text-sm mb-1">
            USUÁRIO:
          </label>
          <input
            type="text"
            id="usuario"
            placeholder="Digite seu usuário"
            value={usuario}
            onChange={(e) => setUsuario(e.target.value)}
            className="w-full p-2 mb-3 rounded-lg bg-white/85 text-black placeholder-gray-500 focus:bg-white focus:shadow-md focus:scale-[1.02] outline-none transition-all"
          />

          <label htmlFor="senha" className="block font-bold text-sm mb-1">
            SENHA:
          </label>
          <div className="relative">
            <input
              type={mostrarSenha ? "text" : "password"}
              id="senha"
              placeholder="Digite sua senha"
              value={senha}
              onChange={(e) => setSenha(e.target.value)}
              className="w-full p-2 mb-3 rounded-lg bg-white/85 text-black placeholder-gray-500 focus:bg-white focus:shadow-md focus:scale-[1.02] outline-none transition-all"
            />
            <span
              onClick={handleToggleSenha}
              className="absolute right-2 top-1/2 -translate-y-1/2 cursor-pointer text-gray-700 hover:text-green-500 transition-colors"
            >
              {mostrarSenha ? <FaEyeSlash /> : <FaEye />}
            </span>
          </div>

          <button
            type="button"
            onClick={handleLogin}
            disabled={carregando}
            className="w-full bg-gradient-to-r from-green-400 to-green-600 hover:from-green-600 hover:to-green-800 text-white font-bold py-3 rounded-lg mt-2 transition-all hover:scale-[1.03] hover:shadow-lg disabled:opacity-50"
          >
            {carregando ? "Entrando..." : "Entrar"}
          </button>

          {mensagem && (
            <p
              className={`mt-2 ${
                mensagem.includes("sucesso") ? "text-green-500" : "text-red-500"
              }`}
            >
              {mensagem}
            </p>
          )}
        </form>
      </div>
      <style>
        {`
          @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
          }
          .animate-fade-in {
            animation: fadeIn 1s ease-in-out;
          }
        `}
      </style>
    </div>
  );
};

export default Login;
