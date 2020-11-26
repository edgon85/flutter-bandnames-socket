import 'package:flutter/material.dart';

class Band {
  String id;
  String name;
  int votes;

  Band({this.id, @required this.name, @required this.votes});

  // no es mas que un contructor que recibe cierto tipo de argumentos y regresa una nueva instancia de mi clase
  factory Band.fromMap(Map<String, dynamic> obj) =>
      Band(id: obj['id'], name: obj['name'], votes: obj['votes']);
}
