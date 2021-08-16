import 'package:flutter/material.dart';
import 'package:mamba_castelldefels/models/Client.dart';

class ClientTile extends StatelessWidget {

  final Client client;
  ClientTile({ required this.client });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Color(0x80F4AD1F),
          ),
          title: Text(client.name),
          subtitle: Text('Has ${client.email} as its email'),
        ),
      ),
    );
  }
}