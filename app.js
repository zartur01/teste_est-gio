import express from "express";
import axios from "axios";
import { openDb } from './database.js';

// Importa o módulo 'cors', que é um middleware do Express para a api se comunicar com o flutter
import cors from 'cors';


const app = express()
app.use(cors());
app.use(express.json());

/**
 * Função para criar a tabela 'compras' no banco de dados SQLite, se ela ainda não existir.
 * Esta tabela armazenará os registros de todas as compras realizadas na loja.
 */
async function criarTabela() {
    const db = await openDb();
    await db.exec(`
        CREATE TABLE IF NOT EXISTS compras (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente TEXT,
            produtos TEXT
        )
    `);
    console.log("Tabela 'compras' criada ou já existe.");
}

criarTabela();

/**
 * Função para buscar e agregar produtos de ambos os fornecedores externos.
 * Esta função opera como um intermediário, consolidando os dados antes de enviá-los ao frontend.
 */
async function getProdutos() {
    const [brResponse, euResponse] = await Promise.all([
        axios.get("http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/brazilian_provider"),
        axios.get("http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/european_provider")
    ]);
    // Combina os dados (arrays de produtos) de ambas as respostas em um único array
    // usando o operador spread
    return [...brResponse.data, ...euResponse.data];
}

/**
 * Rota GET para '/produtos'.
 * Esta rota é responsável por fornecer a lista consolidada de produtos ao frontend.
 */
app.get('/produtos', async (requisicao, resposta) => {
    try {
        // Chama a função 'getProdutos' para obter a lista agregada de produtos.
        const produtos = await getProdutos();
        // Envia a lista de produtos como resposta com status HTTP 200 (OK).
        resposta.status(200).send(produtos);
    } catch (error) {
        // Em caso de erro ao buscar os produtos (ex: problema de conexão com as APIs dos fornecedores),
        // loga o erro no console do servidor e envia uma resposta de erro com status HTTP 500 (Internal Server Error).
        console.error("Erro ao buscar produtos:", error.message || error); // Adiciona mais detalhes ao log
        resposta.status(500).send({ error: "Erro ao buscar produtos" });
    }
});

/**
 * Rota POST para '/compras'.
 * Esta rota é responsável por receber os dados de uma compra do frontend e registrá-la no banco de dados.
 */
app.post('/compras', async (req, res) => {
    const { cliente, produtos } = req.body;
    if (!cliente || !produtos) {
        return res.status(400).send({ error: "Dados incompletos. Informe cliente e produtos." });
    }

    try {
        const db = await openDb();
        await db.run('INSERT INTO compras (cliente, produtos) VALUES (?, ?)',
            cliente,
            JSON.stringify(produtos)
        );

        // Envia uma resposta de sucesso com status HTTP 201 (Created), indicando que o recurso foi criado com sucesso.
        res.status(201).send({ message: "Compra registrada com sucesso!" });
    } catch (error) {
        // Em caso de erro ao registrar a compra no banco de dados,
        // loga o erro no console do servidor e envia uma resposta de erro com status HTTP 500.
        console.error("Erro ao registrar compra:", error.message || error); // Adiciona mais detalhes ao log
        res.status(500).send({ error: "Erro ao registrar compra" });
    }
});

/**
 * Inicia o servidor Express.
 * Ele escuta por requisições na porta 3000.
 * O segundo argumento '0.0.0.0' faz com que o servidor escute em todas as interfaces de rede disponíveis,
 * permitindo que ele seja acessado de outras máquinas na rede (como um emulador ou dispositivo físico).
 */
app.listen(3000, '0.0.0.0', () => {
    console.log("Servidor rodando na porta 3000");
});