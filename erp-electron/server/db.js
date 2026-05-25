import { supabase } from "./database/dbService.js";
import bcrypt from "bcryptjs";

let loggedUserId = null;

export async function conn({ user, password }) {
  try {
    const { data, error } = await supabase
      .from("usuarios")
      .select("id, senha")
      .eq("login", user)
      .eq("ativo", true)
      .single();

    if (error || !data) {
      return { success: false, error: "Usuario ou senha invalidos." };
    }

    const valid = await bcrypt.compare(password, data.senha);
    if (!valid) {
      return { success: false, error: "Usuario ou senha invalidos." };
    }

    loggedUserId = data.id;
    return { success: true, idUser: data.id };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

export function getIdUser() {
  return loggedUserId;
}

export function getDb() {
  return supabase;
}
