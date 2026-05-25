export default function temaEstilos(temaEscuro) {
  return {
    fundo: temaEscuro ? "bg-[#0d0703] text-yellow-200" : "bg-white text-black",
    card: temaEscuro
      ? "bg-[#1a0f06] border border-yellow-700"
      : "bg-white border border-gray-300",
    botaoAtivo: temaEscuro
      ? "bg-yellow-600 text-black"
      : "bg-blue-600 text-white",
    botaoInativo: temaEscuro
      ? "bg-[#2b1a0b] text-yellow-300"
      : "bg-gray-200 text-black",
    tabelaHeader: temaEscuro ? "bg-[#2c1808] text-yellow-300" : "bg-gray-100",
    tabelaBorda: temaEscuro ? "border-yellow-600" : "border-gray-300",
    input: temaEscuro
      ? "bg-[#130a05] text-white border-yellow-700"
      : "bg-white border-gray-400",
    titulo: temaEscuro ? "text-yellow-300" : "text-black",
  };
}
