import React from "react";

export default function LinhaHistorico({ log, temaEscuro }) {
  return (
    <tr
      className={`border-b ${
        temaEscuro ? "border-yellow-900" : "border-gray-300"
      }`}
    >
      <td className="p-3 break-words">{log.idLog}</td>
      <td className="p-3 break-words">{log.tabela}</td>
      <td className="p-3 break-words">{log.operacao}</td>
      <td className="p-3 break-words">{log.registroId}</td>
      <td className="p-3 break-words">
        <pre className="whitespace-pre-wrap text-sm opacity-90">
          {log.valoresAntigos}
        </pre>
      </td>
      <td className="p-3 break-words">
        <pre className="whitespace-pre-wrap text-sm opacity-90">
          {log.valoresNovos}
        </pre>
      </td>
      <td className="p-3 break-words">{log.usuarioSistema}</td>
      <td className="p-3 break-words">
        {new Date(log.dataOperacao).toLocaleString("pt-BR")}
      </td>
    </tr>
  );
}
