import 'package:flutter/material.dart';

void main() => runApp(ListaTarefas());

class ListaTarefas extends StatefulWidget {
  ListaTarefas({Key key}) : super(key: key);

  @override
  _ListaTarefasState createState() => _ListaTarefasState();
}

class _ListaTarefasState extends State<ListaTarefas> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lista de Tarefas'),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
      ),
    );
  }
}
