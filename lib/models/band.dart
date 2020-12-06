import 'package:flutter/material.dart';

class Band {
  String id;
  String name;
  int votes;

  Band({this.id, @required this.name, @required this.votes});

  // no es mas que un contructor que recibe cierto tipo de argumentos y regresa una nueva instancia de mi clase
  factory Band.fromMap(Map<String, dynamic> obj) => Band(
      id: obj.containsKey('id') ? obj['id'] : 'no-id',
      name: obj.containsKey('name') ? obj['name'] : 'no-name',
      votes: obj.containsKey('votes') ? obj['votes'] : 'no-votes');
}
