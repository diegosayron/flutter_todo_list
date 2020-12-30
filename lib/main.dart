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
    return MaterialApp(
        title: 'Lista de Tarefas',
        home: Scaffold(
            appBar: AppBar(
              title: Text('Lista de Tarefas'),
              backgroundColor: Colors.blueAccent,
              centerTitle: true,
            ),
            body: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(15.0, 2.0, 7.0,
                      2.0), //LEFT TOP RIGHT BOTTOM -> CONSEGUIMOS DEFINIR ESPAÇOS DIFERENTES PARA LTRB
                  child: Row(
                    //Vamos colocar uma linha e nela, colocar dois elementos. Uma linha de texto e outra de botão. Precisamos de um children com um novo Widget!
                    children: <Widget>[
                      //Esse widget vai se chamar expanded, que vai falar para o flutter que queremos colocar os dois elementos na mesma linha. Como se fosse agrupar.
                      Expanded(
                        //primeiro elemento
                        child: TextField(
                          decoration: InputDecoration(
                              labelText: "Nova Tarefa",
                              labelStyle: TextStyle(
                                  color: Colors
                                      .blueAccent)), //vai ter um decoration para fazer um layout estilizado, bonito.
                        ),
                      ),

                      //segundo elemento
                      RaisedButton(
                        onPressed: () {},
                        color: Colors.blueAccent,
                        child: Text('Adicionar'),
                        textColor: Colors.white,
                      )
                    ],
                  ),
                )
              ],
            )));
  }
}
