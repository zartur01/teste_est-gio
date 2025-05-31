 E-commerce Flutter

Este é um projeto de um aplicativo de E-commerce desenvolvido em Flutter, com integração a uma API para listagem de produtos e registro de compras. O app possui funcionalidades de exibição de produtos, carrinho de compras e finalização de pedido.

---

 Funcionalidades

- Listagem de produtos via API  
- Filtro de produtos por busca  
- Adição de produtos ao carrinho  
- Visualização de produtos no carrinho  
- Finalização de compra com envio para API  
- Feedback visual via Snackbars  
- Badge de quantidade de produtos no carrinho  

---

 Tecnologias utilizadas

- Flutter (versão 3.1.1)
- Dart
- HTTP para requisições REST
- Badges para indicador do carrinho (`badges: ^3.1.1`)
- API REST para produtos e compras
- Sqlite para o banco de dados
- NodeJs para a API
---

Tomada de Decisão

Durante o desenvolvimento deste projeto, algumas escolhas tecnológicas foram guiadas pela minha experiência prévia e pelo desejo de adquirir novos conhecimentos:

- Node.js: Optei por utilizar Node.js no backend devido à minha familiaridade com JavaScript e à agilidade no desenvolvimento de APIs REST utilizando este ambiente.
  Estruturei o projeto de forma modular, separando as rotas, controladores e modelos, para facilitar a manutenção e a escalabilidade.
  Utilizei o framework Express.js para agilizar a definição de rotas e middlewares.
  Implementei o tratamento de erros para garantir respostas claras e apropriadas ao cliente.
  Configurei o CORS (Cross-Origin Resource Sharing) para permitir a comunicação segura entre o frontend (Flutter) e o backend.
  Realizei testes locais com ferramentas como Postman para validar o funcionamento da API antes de integrar ao frontend.

- SQLite: Escolhi o SQLite como banco de dados por sua simplicidade de configuração, além de já ter trabalhado com ele anteriormente em atividades acadêmicas, o que facilitou sua implementação no projeto.

- Flutter: Para o frontend, decidi usar Flutter, mesmo sem ter experiência prévia com a tecnologia. Esta foi a parte mais desafiadora e demorada do projeto, pois além de aprender a linguagem Dart, precisei configurar o ambiente de desenvolvimento e entender a estruturação de interfaces com widgets. No entanto, essa escolha proporcionou um grande aprendizado e ampliou minha capacidade de desenvolvimento de aplicações multiplataforma.



Como rodar o projeto

Pré-requisitos

- Flutter instalado (versão compatível: 3.1.1 ou superior)
- Dart SDK
- Emulador ou dispositivo físico configurado
- Servidor backend rodando na porta 3000 (como usado nas requisições)

 Passos

1. Clone o repositório:

git clone https://github.com/zartur01/teste_est-gio.git
cd teste_est-gio

2. Instale as dependências:

flutter pub get

3.Inicie o servidor

node app.js

4.Inicie o Flutter

flutter run -d chrome


