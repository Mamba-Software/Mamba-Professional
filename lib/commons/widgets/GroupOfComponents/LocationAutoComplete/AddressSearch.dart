import 'package:flutter/material.dart';
import 'LocationPlacesSearch.dart';
import 'package:mamba/commons/extensions/context.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  LocationPlacesSearch? apiClient;

  AddressSearch(String sessionToken, String language) {
    apiClient = LocationPlacesSearch(sessionToken, language);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: context.l10n.clear,
        icon: Icon(
          Icons.clear,
          color: Theme.of(context).primaryColor,
          size: MediaQuery.of(context).size.width * 0.06,
        ),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.back,
      icon: Icon(
        Icons.arrow_back,
        color: Theme.of(context).primaryColor,
        size: MediaQuery.of(context).size.width * 0.06,
      ),
      onPressed: () {
        close(context, Suggestion('', ''));
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
        builder: (context, snapshot) => query == ''
            ? Container(
                padding: const EdgeInsets.all(16.0),
                child: Text(context.l10n.enterAddress,
                    style: Theme.of(context).textTheme.bodySmall),
              )
            : snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(
                        (snapshot.data![index]).description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      onTap: () {
                        close(context, snapshot.data![index]);
                      },
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(context.l10n.loading),
                  ));
  }
}
