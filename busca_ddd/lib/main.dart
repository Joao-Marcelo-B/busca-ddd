import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  runApp(MaterialApp(
    home: const Home(),
    theme: ThemeData(hintColor: Colors.orange, primaryColor: Colors.white),
  ));
}

Future<Map?> buscarPorDDD(String ddd) async {
  if (ddd.isEmpty) return null;

  var url = Uri.parse('https://brasilapi.com.br/api/ddd/v1/$ddd');
  http.Response response = await http.get(url);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    return null;
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final dddController = TextEditingController();
  String estado = "";
  List<String> cidades = [];
  Future<Map?>? consultaFutura;

  void consultar() {
    setState(() {
      consultaFutura = buscarPorDDD(dddController.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Consulta de DDD"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            const Icon(Icons.phone_android, size: 120.0, color: Colors.orange),
            buildTextField("DDD", "", dddController, (_) {}),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: consultar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                "Buscar",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            consultaFutura == null
                ? const Text(
                    "Digite um DDD e pressione Buscar",
                    style: TextStyle(color: Colors.orange, fontSize: 18),
                  )
                : FutureBuilder<Map?>(
                    future: consultaFutura,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        );
                      } else if (snapshot.hasError || snapshot.data == null) {
                        return const Text(
                          "Erro ao buscar informações. Verifique o DDD.",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        );
                      } else {
                        estado = snapshot.data!["state"];
                        cidades = List<String>.from(snapshot.data!["cities"]);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Estado: $estado",
                                style: const TextStyle(
                                    color: Colors.orange, fontSize: 20)),
                            const SizedBox(height: 10),
                            const Text("Cidades:",
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(
                                      label: Text('Nome da Cidade',
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold))),
                                ],
                                rows: cidades
                                    .map((cidade) => DataRow(cells: [
                                          DataCell(Text(cidade,
                                              style: const TextStyle(
                                                  color: Colors.white))),
                                        ]))
                                    .toList(),
                              ),
                            )
                          ],
                        );
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function(String) onChanged) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.orange),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(color: Colors.orange, fontSize: 25.0),
    onChanged: onChanged,
    keyboardType: TextInputType.number,
  );
}