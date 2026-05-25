import { useState, useEffect } from "react";

export function useVendas() {
  const [vendas, setVendas] = useState([]);
  const [carregandoVendas, setCarregandoVendas] = useState(false);

  useEffect(() => {
    const buscarVendas = async () => {
      setCarregandoVendas(true);
      try {
        const resposta = await window.ipc.getMaioresVendas();
        if (resposta?.success) {
          setVendas(Array.isArray(resposta.vendas) ? resposta.vendas : []);
        }
      } catch {
        setVendas([]);
      } finally {
        setCarregandoVendas(false);
      }
    };
    buscarVendas();
  }, []);

  return { vendas, carregandoVendas };
}
