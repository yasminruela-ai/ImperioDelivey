import { useState, useEffect } from "react";

export function useTema() {
  const [temaEscuro, setTemaEscuro] = useState(false);

  useEffect(() => {
    document.body.className = temaEscuro
      ? "bg-[#2c1a09] text-yellow-300"
      : "bg-gradient-to-b from-yellow-50 via-orange-100 to-red-100 text-black";
  }, [temaEscuro]);

  const alternarTema = () => setTemaEscuro((prev) => !prev);

  return { temaEscuro, alternarTema };
}
