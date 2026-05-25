import React, { useEffect, useState } from "react";
import CardVenda from "./CardVenda";

export default function Vendas({ permissoes, temaEscuro }) {
  const podeRemover = permissoes?.delete ?? true;

  const [vendas, setVendas] = useState([]);
  const [carregando, setCarregando] = useState(false);

  useEffect(() => {
    carregarVendas();
  }, []);

  async function carregarVendas() {
    setCarregando(true);
    try {
      const res = await window.ipc.vendasAdmin.listar();
      const data = res?.success ? res.data : Array.isArray(res) ? res : [];
      setVendas(data);
    } catch (err) {
      console.error("Erro ao carregar vendas:", err);
      setVendas([]);
    } finally {
      setCarregando(false);
    }
  }

  async function excluirVenda(id) {
    if (!podeRemover) return alert("Sem permissão!");
    if (!confirm("Excluir venda permanentemente?")) return;

    const res = await window.ipc.vendasAdmin.remover(id);
    if (res?.success) carregarVendas();
  }

  return (
    <div
      className={`min-h-screen p-6 transition-colors duration-300 ${
        temaEscuro
          ? "bg-[#1b1208] text-yellow-200"
          : "bg-gray-100 text-gray-900"
      }`}
    >
      <h2 className="text-3xl font-bold mb-6">Histórico de Vendas</h2>

      <div
        className={`rounded-xl shadow-lg p-4 transition-colors duration-300 ${
          temaEscuro ? "bg-[#2b1a0c]" : "bg-white"
        }`}
      >
        {carregando ? (
          <p className="animate-pulse">Carregando...</p>
        ) : vendas.length === 0 ? (
          <p className="italic opacity-70">Nenhuma venda registrada.</p>
        ) : (
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            {vendas.map((v) => (
              <CardVenda
                key={v.idVendas ?? v.id}
                venda={v}
                temaEscuro={temaEscuro}
                podeRemover={podeRemover}
                excluirVenda={excluirVenda}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
