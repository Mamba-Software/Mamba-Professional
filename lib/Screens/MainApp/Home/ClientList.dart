import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/models/Client.dart';
import 'package:mamba_castelldefels/screens/Home/ClientTile.dart';
import 'package:provider/provider.dart';

class ClientList extends StatefulWidget {
  @override
  _ClientListState createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  @override
  Widget build(BuildContext context) {

    final clients = Provider.of<List<Client>>(context);
    if (clients != null) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: clients.length,
        itemBuilder: (context, index) {
          return ClientTile(client: clients[index]);
        },
      );
    } else {
      return ListView();
    }
  }
}