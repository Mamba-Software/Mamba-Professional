import 'package:flutter/material.dart';
import 'LocationPlacesSearch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddressSearch extends SearchDelegate<Suggestion> {

  String? sessionToken;
  LocationPlacesSearch? apiClient;

  AddressSearch(this.sessionToken) {
    apiClient = LocationPlacesSearch(sessionToken);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: AppLocalizations.of(context)!.clear,
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context)!.back,
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Suggestion('',''));
      },
    );
  }
  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Suggestion>>(
      future: query == "" ? null : apiClient!.fetchSuggestions(query),
      builder: (context, snapshot) => query == '' ?
        Container(
          padding: EdgeInsets.all(16.0),
          child: Text(AppLocalizations.of(context)!.enterAddress),
        )
        : snapshot.hasData ?
        ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => ListTile(
            title: Text((snapshot.data![index]).description),
            onTap: () {
              close(context, snapshot.data![index]);
            },
          ),
        )
        :
      Container(
        padding: EdgeInsets.all(16.0),
        child: Text(AppLocalizations.of(context)!.loading),
      )
    );
  }
}