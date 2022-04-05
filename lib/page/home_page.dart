import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _listaTarefas = [];
  Map<String, dynamic> _ultimoRemovido = Map();
  TextEditingController _controllerTarefa = TextEditingController();
  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();
    String dados = jsonEncode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _salvarTarefa() {
    Map<String, dynamic> tarefa = Map();
    String textoDigitado = _controllerTarefa.text;
    if (textoDigitado.isEmpty) return;
    tarefa["titulo"] = textoDigitado;
    tarefa["status"] = false;
    setState(() {
      _listaTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controllerTarefa.clear();
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = dados;
      });
    });
  }

  Widget criarItemLista(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _ultimoRemovido = _listaTarefas[index];
        _listaTarefas.removeAt(index);
        _salvarTarefa();

        final snackbar = SnackBar(
          content: Text("Teste"),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              setState(() {
                _listaTarefas.insert(index, _ultimoRemovido);
              });
              _salvarArquivo();
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            )
          ],
        ),
      ),
      child: CheckboxListTile(
        title: Text(_listaTarefas[index]["titulo"]),
        value: _listaTarefas[index]["status"],
        onChanged: (value) {
          setState(() {
            _listaTarefas[index]["status"] = value;
          });
          _salvarTarefa();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Lista de tarefas"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _listaTarefas.length,
                itemBuilder: (context, index) {
                  if (_listaTarefas.isNotEmpty) {
                    return criarItemLista(context, index);
                  }
                  return const Text("Nenhuma tarefa encontrada!");
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Adicionar tarefa"),
                content: TextField(
                  controller: _controllerTarefa,
                  decoration:
                      const InputDecoration(labelText: "Digite sua tarefa"),
                  onChanged: (value) {},
                ),
                actions: [
                  ElevatedButton(
                    child: const Text("Cancelar"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    child: const Text("Salvar"),
                    onPressed: () {
                      _salvarTarefa();
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            },
          );
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
