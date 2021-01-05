import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

void main() => runApp(ListaTarefas());

class ListaTarefas extends StatefulWidget {
  ListaTarefas({Key key}) : super(key: key);

  @override
  _ListaTarefasState createState() => _ListaTarefasState();
}

class _ListaTarefasState extends State<ListaTarefas> {
  final _textToDoController = TextEditingController();
  List _todoList =
      []; //criado para ser usado no método saveData(). Vai receber, em princípio, nada.

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPosition;

  void _addToDo() {
    setState(() {
      //para atualizar na tela, usar setstate. Acho que é isso. sem ele, tem que reiniciar a aplicação para atualizar.
      Map<String, dynamic> newToDo =
          Map(); //fazer um mapa do tipo string e dynamic
      newToDo["tarefa"] = _textToDoController
          .text; //adicionar os valores no mapa, que será o json
      newToDo["status"] = false;

      _textToDoController.text = ""; //só para limpar
      _todoList.add(newToDo);

      _saveData();
    });
  }

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
                      controller: _textToDoController,
                      decoration: InputDecoration(
                          labelText: "Nova Tarefa",
                          labelStyle: TextStyle(
                              color: Colors
                                  .blueAccent)), //vai ter um decoration para fazer um layout estilizado, bonito.
                    ),
                  ),

                  //segundo elemento
                  RaisedButton(
                    onPressed: _addToDo,
                    color: Colors.blueAccent,
                    child: Text('Adicionar'),
                    textColor: Colors.white,
                  )
                ],
              ),
            ),

            /* EXPANDED MODIFICADO NA AULA UN 4, AULA 9, PARA REORGANIZAR A LISTA.
            Expanded(
              //vai receber um listview que é uma lista que vai mostrar os itens um sobre o outro. E o builder oculta os itens não carregados.
              child: ListView.builder(
                  //o builder vai carregando dados à medida que a tela vai sendo rolada.
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _todoList.length, //quantidade de itens da lista
                  /*
              ISSO SERÁ TROCADO PELO itemBuilder mais abaixo
                  itemBuilder: (context, index) {
                    //aguarda uma função
                    return CheckboxListTile(
                      title: Text(
                          _todoList[index]["tarefa"]), //o elemento da lista
                      value: _todoList[index]["status"],
                      secondary: CircleAvatar(
                        child: Icon(_todoList[index]["status"]
                            ? Icons.check
                            : Icons.error),
                      ),
                      onChanged: (status) {
                        setState(() {
                          _todoList[index]["status"] = status;

                          _saveData(); //Adicionar isto!!!
                        });
                      },
                    );
                  }),
            */
                  itemBuilder: buildItem),
            ),
          */

            //Novo Expanded, feito na unidade 4, aula 9, para reorganizar os itens:
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh, //essa função será criada.
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _todoList.length,
                  itemBuilder: buildItem,
                ),
            )),
          ],
        ),
      ),
    );
  }

  //VARIÁVEL QUE SERÁ INSERIDA NO ITEMBUILDER DO LISTVIEW.BUILDER, PARA DESLIZAR PARA O LADO E EXCLUIR:
  Widget buildItem(BuildContext context, int index) {
    //vai retornar um widget chamado Dismissible, que via criar o elemento por trás, com efeito de quando desliza, cria um efeito vermelho por trás.
    //O dismissible aguarda uma chave. Cada elemento é único, precisamos saber a chave desse elemento, que será único, como sendo o datetime.now().milisecondssinceepoch
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
          color: Colors.red,
          //child: Icon(Icons.delete), //vai ser o ícone. Mas se fizer assim, o ícone vai ficar no meio da tela. Portanto, fazer dessa outra forma, passando um alinhamento, antes.:
          child: Align(
            alignment: Alignment(-0.9,
                0.0), //Este Alignment vai de 0 a 1, sendo 1 as bordas da view.
            child: Icon(Icons.delete, color: Colors.white),
          )),

      // qual a orientação/direção que desejamos que faça o efeito:
      direction: DismissDirection.startToEnd, //do início pro final.

      //Também vai ter um child, que vai ser justamente o checkbox que foi recortado/comentado do expanded, acima. SÓ A PARTE DO CHECKBOX, FICANDO ASSIM, COM ALGUNS AJUSTES:
      child: CheckboxListTile(
        title: Text(_todoList[index]["tarefa"]), //o elemento da lista

        value: _todoList[index]["status"],
        secondary: CircleAvatar(
          child: Icon(_todoList[index]["status"] ? Icons.check : Icons.error),
        ),

        onChanged: (status) {
          setState(() {
            _todoList[index]["status"] = status;
            _saveData(); //Adicionar isto!!!
          });
        },
      ),

      onDismissed: (direction) {
        //remove o item do datasource:
        //Para dar a funcionalidade de DESFAZER EXCLUIR, PRECISAMOS TER UM MAP armazenando o estado anterior.
        //Esse MAP está declarado abaixo da definição da classe _ListaTarefasState extends State<...>

        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPosition = index;
          _todoList.removeAt(index);

          _saveData();
          //exibe o snackbar. PODENDO CONTER a ação DESFAZER:
          Scaffold.of(context).showSnackBar(SnackBar(
              content:
                  Text("A tarefa '${_lastRemoved["tarefa"]}' foi removida!"),

              //Agora, a parte que desfaz a ação:
              action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  //tudo dentro de um setstate:
                  setState(() {
                    _todoList.insert(_lastRemovedPosition, _lastRemoved);
                    _saveData();
                  });
                },
              )));

          /*
        Isso também poderia ser assim:
        //exibe o snackbar. PODENDO CONTER a ação DESFAZER:
        final snack SnackBar(
          duration: Duration(seconds: 5),
          content: Text("A tarefa '${_lastRemoved["tarefa"]}' foi removida!"),
          action: SnackBarAction(
            label: "Desfazer",
            onPressed: () {
              //tudo dentro de um setstate:
              setState(() {
                _todoList.insert(_lastRemovedPosition, _lastRemoved);
                _saveData();
              });
            },
          ),
        );

        Scaffold.of(context).removeCurrentSnackBar(); //caso existisse algum, antes.
        Scaffold.of(context).showSnackBar(snack);
      */
        });
      },
    );
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    //atualizar os dados na view
    setState(() {
      //Quando excluir um item, queremos que seja reordenado. Esse algoritmo é do dart, é simples e faz essa reordenação.
      //sort faz a comparação entre dois valores
      _todoList.sort((x, y) {
        //poderia ser qualquer nome.. aqui, usamos x e y. São dynamics
        //vai retornar 1, 0, ou -1, para saber em qual posição ele tem que ficar.
        //x é o Map, y, APARENTEMENTE é _todoList... // vamos ordenar por status e não por nome de tarefa.
        if (x["status"] && !y["status"])
          return 1;
        else if (!x["status"] && y["status"])
          return -1;
        else
          return 0;
      });

      _saveData();
    });
    return null;
  }

  //método para buscar os itens no arquivo:
  @override
  void initState() {
    super.initState();

    //vamos carregar, agora, o método que lê os dados.
    //Como ele demora para ser carregado, precisa ser ter o auxiliar para o método async (then..., que significa: quando estiver disponível.)
    _readData().then((data) {
      //AGORA, TRANSFORMAR EM JSON:
      //MAS.. COMO PRECISAMOS ATUALIZAR NA TELA, TEM QUE SER DENTRO DE UM SETSTATE!!!
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }

  Future<File> _getFile() async {
    final directory =
        await getApplicationDocumentsDirectory(); //definir o diretório e precisamos esperar ele.
    return File(
        "${directory.path}/data.json"); //um nome de arquivo qualquer... data.json
  }

  //Outro método que será criado é o método save:
  //Vai precisar salvar em um arquivo, com conteúdo do tipo string
  //vamos passar, em encode, como se fosse uma lista, para ficar fácil de trabalhar.
  //Para isso, a lista lá em cima, em global, será criada.
  Future<File> _saveData() async {
    String data = json.encode(_todoList);

    final file = await _getFile();
    return file.writeAsString(data);
  }

  //Agora, a última função de manipulação de dados vai ser a parte que vamos ler os dados
  Future<String> _readData() async {
    //vamos utilizar o try-catch, pois pode dar erro, dando erro, queremos o retorno nulo, por enquanto:
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
