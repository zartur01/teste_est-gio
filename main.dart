// Importações essenciais para a aplicação Flutter.
import 'package:flutter/material.dart'; // Widgets e ferramentas de UI do Flutter.
import 'package:http/http.dart' as http; // Para fazer requisições HTTP (comunicação com a API).
import 'dart:convert'; // Para codificar/decodificar dados JSON.
import 'package:badges/badges.dart' as badges; // Para exibir contadores (ex: no carrinho).

// Ponto de entrada da aplicação Flutter.
void main() {
  runApp(EcommerceApp());
}

/// Widget principal da aplicação E-commerce.
/// Define a estrutura básica e o tema visual da loja.
class EcommerceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce Teste',
      // Define o tema visual global da aplicação.
      theme: ThemeData(
        primarySwatch: Colors.red, // Cor primária (ex: AppBar).
        scaffoldBackgroundColor: Colors.grey[100], // Cor de fundo das telas.
        appBarTheme: AppBarTheme( // Tema para as barras de aplicativo.
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData( // Tema para botões elevados.
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontSize: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme( // Tema para campos de texto (InputDecoration).
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: ProductListPage(), // Define a tela inicial da aplicação.
    );
  }
}

/// Modelo de dados para um Produto.
class Product {
  final String id;
  final String name;
  final String image;
  final String price;

  // Construtor para criar uma instância de Produto.
  Product({required this.id, required this.name, required this.image, required this.price});

  /// Factory constructor para criar um objeto Product a partir de um mapa JSON.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '', 
      name: json['nome'] ?? json['name'] ?? '',
      image: json['imagem'] ?? json['image'] ?? '',
      price: json['preco'] ?? json['price'] ?? '',
    );
  }
}

/// Widget de estado para a página de listagem de produtos.
/// Gerencia o estado dos produtos, pesquisa e carrinho de compras.
class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> products = []; 
  List<Product> cart = []; 
  bool isLoading = true;
  String error = ''; 
  TextEditingController searchController = TextEditingController(); // Controlador para o campo de pesquisa.
  String searchQuery = ''; // Termo de pesquisa atual.

  final String myBackendProductsUrl = 'http://192.168.56.1:3000/produtos';
  final String myBackendPurchaseUrl = 'http://192.168.56.1:3000/compras';

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Inicia o carregamento dos produtos ao inicializar a tela.
  }

  @override
  void dispose() {
    searchController.dispose(); // Libera o controlador de texto quando o widget é descartado.
    super.dispose();
  }

  /// Função para buscar produtos da API de backend.
  /// Atualiza o estado da tela com os produtos carregados ou mensagens de erro.
  Future<void> _fetchProducts() async {
    setState(() {
      isLoading = true; // Define o estado de carregamento.
      error = ''; // Limpa qualquer erro anterior.
    });

    try {
      // Faz uma requisição GET para API de backend.
      final response = await http.get(Uri.parse(myBackendProductsUrl));

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        setState(() {
          products = productsJson.map((json) => Product.fromJson(json)).toList();
          isLoading = false; // Finaliza o carregamento.
        });
      } else {
        // Define a mensagem de erro caso a requisição não seja bem-sucedida.
        setState(() {
          error = 'Falha ao carregar produtos da sua API: Status ${response.statusCode}.';
          isLoading = false;
        });
      }
    } catch (e) {
      // Captura erros de conexão ou outros e define a mensagem de erro.
      setState(() {
        error = 'Erro de conexão com sua API: $e';
        isLoading = false;
      });
    }
  }

  /// Adiciona um produto ao carrinho de compras e mostra uma notificação.
  void addToCart(Product product) {
    setState(() {
      cart.add(product); // Adiciona o produto à lista do carrinho.
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado ao carrinho'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Exibe uma tela com os produtos atualmente no carrinho.
  void viewCart() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Carrinho (${cart.length})'), 
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: cart.length,
            separatorBuilder: (_, __) => Divider(), 
            itemBuilder: (context, index) {
              final item = cart[index];
              return ListTile( 
                leading: Icon(Icons.shopping_bag),
                title: Text(item.name),
                subtitle: Text('Preço: ${item.price}'),
              );
            },
          ),
        ),
        actions: [
          TextButton( // Botão para fechar a tela.
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Envia os dados da compra para a API de backend.
  /// Limpa o carrinho em caso de sucesso.
  Future<void> enviarCompra(String cliente, List<Product> cart) async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O carrinho está vazio!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Cria o corpo da requisição POST, contendo o nome do cliente e os detalhes dos produtos.
    final body = {
      'cliente': cliente,
      'produtos': cart.map((p) => {
            'id': p.id,
            'nome': p.name,
            'imagem': p.image,
            'preco': p.price,
          }).toList()
    };

    try {
      // Faz a requisição POST para a API de compras.
      final response = await http.post(
        Uri.parse(myBackendPurchaseUrl),
        headers: {'Content-Type': 'application/json'}, // Define o tipo de conteúdo como JSON.
        body: jsonEncode(body), // Converte o corpo para uma string JSON.
      );

      if (response.statusCode == 201) { // Verifica se a compra foi registrada com sucesso (status 201 Created).
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compra registrada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          cart.clear(); // Limpa o carrinho após a compra.
        });
      } else { // Caso haja erro no registro da compra.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar compra: ${response.body}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) { // Captura erros de conexão ou outros durante o envio da compra.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão ao registrar compra: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// Exibe uma tela para o usuário inserir seu nome e finalizar a compra.
  void finalizarCompraDialog() {
    TextEditingController clienteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Finalizar Compra'),
        content: TextField( // Campo para inserir o nome do cliente.
          controller: clienteController,
          decoration: InputDecoration(
            labelText: 'Nome do Cliente',
          ),
        ),
        actions: [
          TextButton( 
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton( 
            onPressed: () {
              String cliente = clienteController.text.trim();
              if (cliente.isEmpty) { // Valida se o nome do cliente foi inserido.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Informe o nome do cliente.'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              Navigator.pop(context); // Fecha a tela.
              enviarCompra(cliente, cart); // Chama a função para enviar a compra.
            },
            child: Text('Enviar'),
          ),
        ],
      ),
    );
  }

  /// Constrói a interface do usuário da página de listagem de produtos.
  @override
  Widget build(BuildContext setContext) { 
    List<Product> filteredProducts = products.where((product) {
      return product.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                badges.Badge( // Ícone do carrinho com contador de itens.
                  badgeContent: Text('${cart.length}', style: const TextStyle(color: Colors.white)),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: viewCart, 
                  ),
                ),
                IconButton( // Ícone para finalizar a compra.
                  icon: const Icon(Icons.payment),
                  tooltip: 'Finalizar Compra',
                  onPressed: finalizarCompraDialog, 
                ),
              ],
            ),
          ),
        ],
        backgroundColor: Colors.red,
      ),
      body: isLoading // Exibe um indicador de progresso enquanto os produtos estão carregando.
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty // Exibe mensagem de erro se houver problemas no carregamento.
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton( // Botão para tentar recarregar os produtos.
                        onPressed: _fetchProducts,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : products.isEmpty // Exibe mensagem se nenhum produto for encontrado (após carregamento sem erro).
                  ? const Center(child: Text('Nenhum produto encontrado.'))
                  : Padding( // Exibe a grade de produtos se houver produtos.
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text( 
                            'Produtos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField( // Campo de pesquisa de produtos.
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: 'Buscar produto...',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) { // Atualiza o termo de pesquisa ao digitar.
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: GridView.builder( // Grade de exibição dos produtos.
                              itemCount: filteredProducts.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 1.3,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                              ),
                              itemBuilder: (context, index) {
                                var product = filteredProducts[index];
                                return Card( // Cartão individual para cada produto.
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.redAccent.withOpacity(0.3),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: ClipRRect( // Imagem do produto.
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              product.image,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, progress) {
                                                if (progress == null) return child;
                                                return Center(child: CircularProgressIndicator());
                                              },
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.error, size: 50, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          product.price,
                                          style: TextStyle(color: Colors.green[700]),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon( // Botão "Comprar".
                                          icon: const Icon(Icons.shopping_cart, size: 16),
                                          label: const Text('Comprar', style: TextStyle(fontSize: 12)),
                                          onPressed: () => addToCart(product), // Adiciona ao carrinho.
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}