import React from "react";
import LinhaHistorico from "./LinhaHistorico";

export default function TabelaHistorico({ logs, temaEscuro }) {
  return (
    <div
      className={`mt-6 rounded-2xl shadow-xl p-4 transition-colors duration-300 ${
        temaEscuro ? "bg-[#2b1a0c]" : "bg-white"
      } h-[65vh]`}
    >
      <div className="overflow-x-auto overflow-y-auto h-full">
        <table className="w-full table-fixed min-w-[900px]">
          <thead>
            <tr
              className={`text-left border-b ${
                temaEscuro ? "border-yellow-800" : "bg-gray-200"
              }`}
            >
              <th className="p-3 w-16">ID</th>
              <th className="p-3 w-32">Tabela</th>
              <th className="p-3 w-32">Operação</th>
              <th className="p-3 w-24">ID Registro</th>
              <th className="p-3 w-64">Valores Antigos</th>
              <th className="p-3 w-64">Valores Novos</th>
              <th className="p-3 w-32">Usuário</th>
              <th className="p-3 w-40">Data</th>
            </tr>
          </thead>

          <tbody>
            {logs.length > 0 ? (
              logs.map((log) => (
                <LinhaHistorico
                  temaEscuro={temaEscuro}
                  key={log.idLog}
                  log={log}
                />
              ))
            ) : (
              <tr>
                <td
                  colSpan={8}
                  className={`text-center p-4 italic ${
                    temaEscuro ? "opacity-60" : "text-gray-500"
                  }`}
                >
                  Nenhum registro encontrado.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
