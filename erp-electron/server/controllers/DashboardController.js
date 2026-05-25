import {
  listarCategoriaVenda,
  listarQuantidadeVenda,
  listarVendaMes,
  listarVendaUsuario,
  listarVendaUsuarioPorMes,
} from "../models/Dashboard.js";

export async function obterCategoriaVenda() {
  try {
    const dados = await listarCategoriaVenda();
    return { success: true, data: dados };
  } catch (err) {
    console.error("Erro ao consultar vwCategoriaVenda:", err);
    return {
      success: false,
      message: "Erro ao consultar categoria de vendas.",
    };
  }
}

export async function obterQuantidadeVenda() {
  try {
    const dados = await listarQuantidadeVenda();
    return { success: true, data: dados };
  } catch (err) {
    console.error("Erro ao consultar vwQuantidadeVenda:", err);
    return { success: false, message: "Erro ao consultar vendas por dia." };
  }
}

export async function obterVendaMes() {
  try {
    const dados = await listarVendaMes();
    return { success: true, data: dados };
  } catch (err) {
    console.error("Erro ao consultar vwVendaMes:", err);
    return { success: false, message: "Erro ao consultar vendas por mês." };
  }
}

export async function obterVendaUsuario() {
  try {
    const dados = await listarVendaUsuario();
    return { success: true, data: dados };
  } catch (err) {
    console.error("Erro ao consultar vwVendaUsuario:", err);
    return { success: false, message: "Erro ao consultar vendas por usuário." };
  }
}

export async function obterVendaUsuarioPorMes(mesAno) {
  try {
    const dados = await listarVendaUsuarioPorMes(mesAno);

    if (!dados || dados.length === 0) {
      return {
        success: false,
        message: "Nenhum dado encontrado para o mês informado.",
      };
    }

    return { success: true, data: dados };
  } catch (err) {
    console.error("Erro ao consultar vwVendaUsuario por mês:", err);
    return { success: false, message: "Erro ao consultar vendas por usuário." };
  }
}

export async function obterDashboardCompleto() {
  try {
    const categorias = await listarCategoriaVenda();
    const vendasMes = await listarVendaMes();
    const vendasDia = await listarQuantidadeVenda();
    const vendasUsuario = await listarVendaUsuario();

    return {
      success: true,
      data: {
        categorias,
        vendasMes,
        vendasDia,
        vendasUsuario,
      },
    };
  } catch (err) {
    console.error("Erro ao consultar dashboard completo:", err);
    return { success: false, message: "Erro ao consultar dashboard completo." };
  }
}
