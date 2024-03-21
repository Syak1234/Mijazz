import 'package:Music_Pluse/projectfile/Allsongs.dart';
import 'package:Music_Pluse/projectfile/gobalclass.dart';
import 'package:Music_Pluse/projectfile/localMusic.dart';
import 'package:Music_Pluse/projectfile/localmusic1.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LocalMusicSearchState extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Close with no result.
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
            child: Text(
          "Enter a search query",
          style: TextStyle(color: Colors.white),
        )),
      );
    }

    if (query.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
            child: Text(
          "Start typing to search",
          style: TextStyle(color: Colors.white),
        )),
      );
    }

    return Container(
      color: Colors.black,
      child: FutureBuilder<List<SongModel>>(
        future: _filterItems(query),
        builder: (context, AsyncSnapshot<List<SongModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final searchResults = snapshot.data;

            if (searchResults != null && searchResults.isNotEmpty) {
              return ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      searchResults[index].title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DeviceMusic(searchResults,
                              index, player1, searchResults[index].id),
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return Center(
                  child: Text(
                "No results found",
                style: TextStyle(color: Colors.white),
              ));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container(
          color: Colors.black,
          child: Center(
              child: Text(
            "Start typing to search",
            style: TextStyle(color: Colors.white),
          )));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          child: FutureBuilder<List<SongModel>>(
            future: _filterItems(query),
            builder: (context, AsyncSnapshot<List<SongModel>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final searchResults = snapshot.data;

                if (searchResults != null && searchResults.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          searchResults[index].title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacement(PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return DeviceMusic(searchResults, index, player1,
                                  searchResults[index].id);
                            },
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin =
                                  Offset(0.0, 1.0); // Slide from the bottom
                              const end = Offset.zero;
                              const curve = Curves.easeOut; // Adjust the curve
                              const duration = Duration(
                                  milliseconds: 1000); // Adjust the duration

                              var tween = Tween(begin: begin, end: end).chain(
                                CurveTween(curve: curve),
                              );

                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ));
                        },
                      );
                    },
                  );
                } else {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                        child: Text(
                      "No results found",
                      style: TextStyle(color: Colors.white),
                    )),
                  );
                }
              } else {
                return Container(
                    height: MediaQuery.of(context).size.height,
                    child: Center(child: CircularProgressIndicator()));
              }
            },
          ),
        ),
      ),
    );
  }

  Future<List<SongModel>> _filterItems(String query) async {
    query = query.toLowerCase();
    localmusic.clear();

    if (query.isEmpty) {
      localmusic.clear();
    } else {
      localmusic = AllSongsState.songs
          .where((item) => item.title.toLowerCase().contains(query))
          .toList();
    }

    return localmusic;
  }
}
