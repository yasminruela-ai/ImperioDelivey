import React from "react";

export default function DashButton({ ativo, temaEscuro, onClick, children }) {
  return (
    <button
      onClick={onClick}
      className={`px-4 py-2 rounded-lg font-semibold transition ${
        ativo
          ? "bg-red-600 text-white"
          : temaEscuro
          ? "bg-[#3b240f] text-yellow-200"
          : "bg-white text-red-600 border"
      }`}
    >
      {children}
    </button>
  );
}
