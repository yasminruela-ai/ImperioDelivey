import React from "react";

export default function Card({ titulo, temaEscuro, className = "", children }) {
  return (
    <div
      className={`border rounded-xl p-5 shadow-lg transition duration-500 hover:scale-[1.02] ${className} ${
        temaEscuro
          ? "border-yellow-600 bg-[#3b240f]"
          : "border-yellow-400 bg-white"
      }`}
    >
      <h3
        className={`text-lg font-semibold text-center mb-3 ${
          temaEscuro ? "text-yellow-200" : "text-red-700"
        }`}
      >
        {titulo}
      </h3>
      <div className="h-[300px] flex items-center justify-center">
        {children}
      </div>
    </div>
  );
}
