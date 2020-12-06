import 'dart:io';

import 'package:band_names/services/socket_service.dart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// propios
import 'package:band_names/models/band.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      /* Appbar */
      appBar: myAppBar(context),

      /* --  Body --*/
      body: Column(
        children: [
          /* === graficas === */
          _showGraph(),

          /* === expanded para lista de bandas */
          Expanded(
              child: ListView.builder(
            itemCount: bands.length,
            itemBuilder: (BuildContext context, int i) => _bandTile(bands[i]),
          ))
        ],
      ),

      /* === Floating button === */
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  /* ========================= */
  /* Mi AppBar */
  /* ========================= */
  AppBar myAppBar(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return AppBar(
      title: Text(
        'BandNames',
        style: TextStyle(color: Colors.black87),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 10.0),
          child: (socketService.serverStatus == ServerStatus.Online)
              ? Icon(Icons.offline_bolt, color: Colors.blue[300])
              : Icon(
                  Icons.online_prediction,
                  color: Colors.red,
                ),
        )
      ],
    );
  }

  /* ========================= */
  /*  Band Tile  */
  /* ========================= */
  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete band',
              style: TextStyle(color: Colors.white),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
    );
  }

  /* ========================= */
  /* Agregar una nueva banda */
  /* ========================= */
  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New band name:'),
                content: TextField(
                  controller: textController,
                ),
                actions: <Widget>[
                  MaterialButton(
                    child: Text('Add'),
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () => addBandToList(textController.text),
                  )
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text('New band name:'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Add'),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text('Dismiss'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  /* ========================= */
  /* Agregarbanda a la lista */
  /* ========================= */
  void addBandToList(String name) {
    print(name);
    if (name.length >= 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', ({'name': name}));
    }
    Navigator.pop(context);
  }

  /* ========================= */
  /* Mostrar la grafica */
  /* ========================= */
  Widget _showGraph() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
        width: double.infinity, // que use todo el ancho posible
        height: 200,
        child: PieChart(dataMap: dataMap));
  }
}
