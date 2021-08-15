import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/models/Client.dart';
import 'package:provider/provider.dart';

class ClientList extends StatefulWidget {
  @override
  _ClientListState createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  @override
  Widget build(BuildContext context) {

    final clients = Provider.of<List<Client>>(context);
    var cnt = 0;
    clients.forEach((client) {
      print(client.name);
      print(client.email);
      cnt++;
      print(cnt);
    });
    return Container(

    );
  }
}