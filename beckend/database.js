import sqlite3 from 'sqlite3';
import { open } from 'sqlite';

// Função para abrir a conexão com o banco
export async function openDb() {
  return open({
    filename: './database.db',
    driver: sqlite3.Database
  });
}