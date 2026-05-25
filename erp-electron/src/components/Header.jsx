import React from "react";
import logo from "../images/logo reansparente.png";

const Header = ({ temaEscuro, alternarTema, logout }) => {
  return (
    <header
      className={`flex flex-col md:flex-row items-center justify-between p-4 transition-colors duration-300 ${
        temaEscuro
          ? "bg-[#2c1a09] text-yellow-300"
          : "bg-gradient-to-r from-yellow-400 to-red-500 text-white"
      }`}
    >
      <div className="flex items-center gap-3 mb-2 md:mb-0">
        <img
          src={logo}
          alt="Império's Burger Logo"
          className="h-14 w-auto drop-shadow-lg"
        />
        <span className="text-2xl font-bold tracking-wide">
          Império's Burger
        </span>
      </div>

      <div className="flex gap-3 items-center">
        <button
          onClick={alternarTema}
          className={`px-3 py-1 rounded font-semibold transition-colors duration-200 ${
            temaEscuro
              ? "bg-yellow-500 hover:bg-yellow-400 text-black"
              : "bg-red-600 hover:bg-red-700 text-white"
          }`}
        >
          {temaEscuro ? "Modo Claro" : "Modo Escuro"}
        </button>

        <button
          onClick={logout}
          className={`px-3 py-1 rounded font-semibold transition-colors duration-200 ${
            temaEscuro
              ? "bg-red-700 hover:bg-red-600 text-white"
              : "bg-yellow-600 hover:bg-yellow-500 text-black"
          }`}
        >
          Encerrar Sessão
        </button>
      </div>
    </header>
  );
};

export default Header;
