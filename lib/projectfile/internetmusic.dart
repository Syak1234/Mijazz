import 'dart:async';
import 'dart:convert';
import 'package:Music_Pluse/projectfile/artist.dart';
import 'package:Music_Pluse/projectfile/loader.dart';
import 'package:Music_Pluse/projectfile/util/artistclass.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:Music_Pluse/projectfile/util/webUrl.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'backgroundmusic.dart';
import 'localMusic.dart';
import 'util/song.dart';
import 'package:Music_Pluse/projectfile/gobalclass.dart' as global;

class InternetMusic extends StatefulWidget {
  const InternetMusic({super.key});

  @override
  State<InternetMusic> createState() => InternetMusicState();
}

class InternetMusicState extends State<InternetMusic>
    with WidgetsBindingObserver {
  // static StreamController<bool> streamController = StreamController<bool>();

  static int musicindex = 0;
  static int id = 0;
  static String drawerimg = '', title = '', subtitle = '';
  // static bool ab = false;
  static String img = '';
  // ignore: non_constant_identifier_names

  // TabController tabController = TabController(length: length, vsync: vsync);
  Color color = Colors.white;
// dynamics
  static late ConcatenatingAudioSource playlist;
  List<Song> trackUrls = [];
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    appImage().whenComplete(() {
      if (global.artistdetails.isEmpty) {
        artisdata();
      }
    });
    if (global.songs.isEmpty) {
      fetchMusicData().whenComplete(() {
        // Fluttertoast.showToast(msg: 'msg');
        _filterItems();
        if (mounted) {
          setState(() {});
        }
      });
    }
    @override
    void dispose() {
      WidgetsBinding.instance.removeObserver(this);
      super.dispose();
    }

    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
  }

  Future appImage() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      String userno = sp.getString('user') ?? '';
      if (userno != '' && userno == '0') {
        final profileimg = sp.getString('image') ?? '';

        drawerimg = "${UrlPage.link}profile_img/$profileimg";
      } else if (userno != '' && userno == '1') {
        drawerimg = sp.getString('image') ?? '';
      }
    });
  }

  Future<void> _filterItems() async {
    if (global.songs.isEmpty) {
      global.songs.clear();
    } else {
      global.bengali = global.songs
          .where((item) =>
              item.genre.toLowerCase().contains('bengali') ||
              item.album.toLowerCase().contains('bengali'))
          .toList();
      global.panjabi = global.songs
          .where((item) =>
              item.genre.toLowerCase().contains('punjabi') ||
              item.album.toLowerCase().contains('punjabi'))
          .toList();
      global.hollywood = global.songs
          .where((item) =>
              item.genre.toLowerCase().contains('hollywood') ||
              item.genre.toLowerCase().contains('english') ||
              item.album.toLowerCase().contains('english'))
          .toList();
      global.bollywood = global.songs
          .where((item) =>
              item.genre.toLowerCase().contains('bollywood') ||
              item.genre.toLowerCase().contains('hindi') ||
              item.album.toLowerCase().contains('hindi'))
          .toList();
    }
  }

  List<AudioSource> buildPlaylist(song) {
    setState(() {
      trackUrls = song;
    });
    List<AudioSource> playlist = [];
    playlist.clear();

    for (int i = 0; i < trackUrls.length; i++) {
      try {
        playlist.add(
          AudioSource.uri(
            Uri.parse(UrlPage.link + trackUrls[i].filePath),
            tag: MediaItem(
              displaySubtitle: trackUrls[i].releasedate,
              id: trackUrls[i].id,
              album: trackUrls[i].album,
              title: trackUrls[i].title,
              artist: trackUrls[i].artist,
              displayDescription: trackUrls[i].filePath,
              displayTitle: trackUrls[i].songLyrics,
              genre: trackUrls[i].genre,
              duration: Duration(minutes: int.parse(trackUrls[i].duration)),
              artUri: Uri.parse("${UrlPage.link}music_img/${trackUrls[i].img}"),
            ),
          ),
        );
      } catch (e) {
        // Fluttertoast.showToast(msg: e.toString());
      }
    }
    setState(() {});
    return playlist;

    // Fluttertoast.showToast(msg: global.songs.length.toString());
  }

  Future artisdata() async {
    try {
      final res = await http.get(Uri.parse('${UrlPage.link}fetchartist.php'));
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        // return data;
        global.artistdetails.clear();
        for (int i = 0; i < data.length; i++) {
          // setState(() {});
          ArtistClass artist = ArtistClass(
              artistname: data[i]['artist_name'],
              artistimg: data[i]['artist_img'],
              artisid: data[i]['artist_id']);
          global.artistdetails.add(artist);
        }
      } else {
        print('Failed to fetch artist data');
      }
    } catch (e) {}

    (exception) {
      //Handle exception message
      if (exception.message != null) {
        debugPrint(exception
            .message); // Here you get : "Connection  Timeout Exception"
      }
    };
  }

  Future fetchMusicData() async {
    try {
      final response =
          await http.get(Uri.parse('${UrlPage.link}findmusic.php'));

      // Fluttertoast.showToast(msg: 'Ok');

      if (response.statusCode == 200) {
        // Fluttertoast.showToast(msg: 'Ok');
        var data = jsonDecode(response.body);
        // return data;
        global.songs.clear();
        for (int i = 0; i < data.length; i++) {
          // setState(() {});
          Song song = Song(
            title: data[i]['Title'],
            artist: data[i]['Artist'],
            filePath: data[i]['File_Path'],
            album: data[i]['Album'],
            genre: data[i]['Genre'],
            duration: data[i]['Duration'],
            id: data[i]['uid'],
            img: data[i]['img'],
            releasedate: data[i]['Release_Date'],
            songLyrics: data[i]['SongLyrics'],
          );
          global.songs.add(song);
        }

        // return Song(title: title, artist: artist, filePath: filePath);
      } else {
        // Handle error
        // Fluttertoast.showToast(msg: 'Ok');
        // ignore: avoid_print
        print('Failed to fetch music data');
      }
    } catch (e) {
      // Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
    (exception) {
      //Handle exception message
      if (exception.message != null) {
        debugPrint(exception
            .message); // Here you get : "Connection  Timeout Exception"
      }
    };
  }

  static List<Song> listsong = [];
  late SharedPreferences sp;

  Color w = Colors.white;
  Color b = const Color.fromARGB(255, 0, 0, 0);
  var lc1 = const LinearGradient(
    colors: [
      // Color.fromARGB(255, 241,

      Color.fromARGB(255, 7, 17, 36), Color.fromARGB(255, 7, 17, 36)
    ],
  );
  LinearGradient lc2 = const LinearGradient(colors: [
    Color.fromARGB(255, 145, 199, 224),
    Color.fromARGB(255, 49, 183, 228),
    Color.fromARGB(96, 240, 137, 137),
  ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
  // Future setting(value) async {
  //   sp = await SharedPreferences.getInstance();

  //   lg = ThemeDataColor.t ? lc1 : lc2;
  //   fc = ThemeDataColor.t ? w : b;
  //   ThemeDataColor.t = value;
  //   sp.setBool('color', ThemeDataColor.t);
  // }

  bool y = false;
  bool t = true;
  static double size = 0.0;
  Color c = Colors.white;
  static Song songclass = Song(
    title: 'title',
    artist: 'artist',
    filePath: 'filePath',
    album: 'album',
    genre: 'genre',
    duration: 'duration',
    releasedate: 'releasedate',
    id: 'id',
    img: 'img',
    songLyrics: '',
  );

  double yOffset = 0.0; // Initial vertical offset
  double dragY = 0.0; // Vertical drag amount
  String playing = '0';

  back() {
    Navigator.of(context).pop();
  }

  Future refresh() async {
    // global.artist.clear();
    global.songs.clear();
    global.bengali.clear();
    global.bollywood.clear();
    global.hollywood.clear();
    global.panjabi.clear();
    global.artist.clear();
    await artisdata();
    await fetchMusicData().whenComplete(() => _filterItems());
    setState(() {});
  }

  // int logout = 0;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Color _containerColor = Colors.transparent;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) audioplayer.pause();
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    //

    return Material(
      child: Scaffold(
        key: scaffoldKey,
        drawer: Drawer(
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              children: <Widget>[
                DrawerHeader(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'asset/img/music.jpg',
                        width: 50,
                      ),
                      Container(
                        padding: const EdgeInsets.only(),
                        child: Text(
                          'Mijazz',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                      child: Text(
                        'Menu',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            backgroundColor: _containerColor),
                      ),
                    )
                  ],
                ),
                MaterialButton(
                  onPressed: () {
                    if (MusicPlayUiState.isPlayerInitialized == false) {
                      setState(() {
                        if (global.streamController1.isClosed) {
                          global.streamController1 =
                              StreamController<bool>.broadcast();
                        }
                      });
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              LocalMusic(global.streamController1.stream)));
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Alert Infomation'),
                          content: const Text(
                            'Your online music stream is on! you want to close the music stream?',
                          ),
                          actions: [
                            ElevatedButton(
                              style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.grey)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.red)),
                              onPressed: () {
                                setState(() {
                                  audioplayer.stop();

                                  MusicPlayUiState.isPlayerInitialized = false;
                                  // MusicPlayUiState.beforeid = 0;
                                  // MusicPlayUiState.beforeindex = 0;
                                  global.streamController.add(false);

                                  if (global.streamController1.isClosed) {
                                    global.streamController1 =
                                        StreamController<bool>.broadcast();
                                  }
                                });
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => LocalMusic(
                                            global.streamController1.stream)));
                              },
                              child: const Text(
                                'Ok',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: Colors.pink,
                      ),
                      Text(
                        'Your local music',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          content: Text(
                            'Version 1.0.0',
                            style: TextStyle(color: Colors.white),
                          ),
                          title: Text('Ai Music',
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Color.fromARGB(255, 16, 22, 42),
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'Version',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          leading: drawerimg.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    if (scaffoldKey.currentState!.isDrawerOpen) {
                      scaffoldKey.currentState!.openEndDrawer();
                    } else {
                      scaffoldKey.currentState!.openDrawer();
                    }
                  },
                  child: CircleAvatar(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: CachedNetworkImage(
                        imageUrl: drawerimg,
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                )
              : InkWell(
                  onTap: () {
                    if (scaffoldKey.currentState!.isDrawerOpen) {
                      scaffoldKey.currentState!.openEndDrawer();
                    } else {
                      scaffoldKey.currentState!.openDrawer();
                    }
                  },
                  child: CircleAvatar(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: Image.asset(
                      'asset/img/female1.png',
                      fit: BoxFit.cover,
                      height: 50,
                      width: 50,
                    ),
                  )),
                ),
          backgroundColor: Color.fromARGB(255, 15, 12, 164),
          title: const Text(
            'Music with live',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: RefreshIndicator(
          onRefresh: () => refresh(),
          child: SingleChildScrollView(
            child: Container(
              color: Colors.black,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(9.0),
                        child: Text(
                          'Your Fevorite artist',
                          textScaleFactor: 1.8,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 130,
                    child: global.artistdetails.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: global.artistdetails.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Container(
                                      // height: 100,
                                      // width: 100,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      // width: 120,
                                      margin: const EdgeInsets.only(
                                          right: 10, top: 0, bottom: 5),
                                      // padding: EdgeInsets.all(10),
                                      child: CircularProfileAvatar(
                                        // child: CachedNetworkImage(imageUrl:),
                                        // showInitialTextAbovePicture: true,
                                        UrlPage.link +
                                            global
                                                .artistdetails[index].artistimg,

                                        borderWidth: 5,
                                        backgroundColor: Colors.transparent,
                                        // borderColor: Colors.white,
                                        imageFit: BoxFit.cover,
                                        showInitialTextAbovePicture: true,
                                        elevation: 5.0,
                                        // foregroundColor:
                                        //     Colors.cyan.withOpacity(0.5),
                                        progressIndicatorBuilder: (context, url,
                                                progress) =>
                                            const CircularProgressIndicator(),
                                        cacheImage: true,
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) => Artist(
                                                      UrlPage.link +
                                                          global
                                                              .artistdetails[
                                                                  index]
                                                              .artistimg,
                                                      global
                                                          .artistdetails[index]
                                                          .artistname)));
                                        },
                                      )),
                                  Text(
                                    global.artistdetails[index].artistname,
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ],
                              );
                            })
                        : Center(
                            child: LoaderProgress(),
                          ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, left: 9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Panjabi',
                          style: TextStyle(
                              color: color,
                              fontSize: 20,
                              decoration: TextDecoration.underline,
                              decorationThickness: 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    child: global.panjabi.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: false,
                            scrollDirection: Axis.horizontal,
                            itemCount: global.panjabi.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, right: 4),
                                child: Stack(children: [
                                  SizedBox(
                                    height: 140,
                                    width: 130,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          imageUrl:
                                              '${UrlPage.link}music_img/${global.panjabi[index].img}',
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left:
                                        MediaQuery.of(context).size.width / 24,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: const Color.fromARGB(
                                                  0, 250, 251, 252)
                                              .withOpacity(0.8)),
                                      height: 40,
                                      width: 100,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            audioplayer.seek(Duration.zero,
                                                index: index);
                                            playlist = ConcatenatingAudioSource(
                                                children: buildPlaylist(
                                                    global.panjabi));

                                            songclass = global.panjabi[index];
                                            listsong = global.panjabi;
                                            id = int.parse(songclass.id);
                                            size = 70;

                                            musicindex = index;

                                            Navigator.of(context)
                                                .push(PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                  secondaryAnimation) {
                                                return MusicPlayUi(
                                                    InternetMusicState.playlist,
                                                    InternetMusicState
                                                        .musicindex,
                                                    id,
                                                    InternetMusicState
                                                        .listsong);
                                              },
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.easeInOut;
                                                var tween = Tween(
                                                        begin: begin, end: end)
                                                    .chain(CurveTween(
                                                        curve: curve));

                                                var offsetAnimation =
                                                    animation.drive(tween);

                                                return SlideTransition(
                                                  position: offsetAnimation,
                                                  child: child,
                                                );
                                              },
                                            ));

                                            // Navigator.of(context).push(MaterialPageRoute(
                                            //     builder: (context) => MusicPlayUi(
                                            //         InternetMusicState
                                            //             .playlist,
                                            //         InternetMusicState
                                            //             .musicindex,
                                            //         id,
                                            //         InternetMusicState
                                            //             .listsong)));
                                          });
                                        },
                                        icon: const Icon(
                                            Icons.play_circle_filled_sharp,
                                            color: Colors.pink),
                                        label: const Text(
                                          'Play',
                                          style: TextStyle(color: Colors.pink),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                              );
                            })
                        : Center(
                            child: LoaderProgress(),
                          ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, left: 9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bengali',
                          style: TextStyle(
                              color: color,
                              fontSize: 20,
                              decoration: TextDecoration.underline,
                              decorationThickness: 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 160,
                    child: global.bengali.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: false,
                            scrollDirection: Axis.horizontal,
                            itemCount: global.bengali.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, right: 4),
                                child: Column(children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        audioplayer.seek(Duration.zero,
                                            index: index);
                                        playlist = ConcatenatingAudioSource(
                                            children:
                                                buildPlaylist(global.bengali));

                                        songclass = global.bengali[index];
                                        listsong = global.bengali;
                                        id = int.parse(songclass.id);
                                        size = 70;

                                        musicindex = index;

                                        Navigator.of(context)
                                            .push(PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                              secondaryAnimation) {
                                            return MusicPlayUi(
                                                InternetMusicState.playlist,
                                                InternetMusicState.musicindex,
                                                id,
                                                InternetMusicState.listsong);
                                          },
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));

                                            var offsetAnimation =
                                                animation.drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                        ));

                                        // Navigator.of(context).push(MaterialPageRoute(
                                        //     builder: (context) => MusicPlayUi(
                                        //         InternetMusicState
                                        //             .playlist,
                                        //         InternetMusicState
                                        //             .musicindex,
                                        //         id,
                                        //         InternetMusicState
                                        //             .listsong)));
                                      });
                                    },
                                    child: SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(80),
                                          child: CachedNetworkImage(
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                            imageUrl:
                                                '${UrlPage.link}music_img/${global.bengali[index].img}',
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                  ),
                                  Container(
                                      height: 60,
                                      width: 100,
                                      child: Column(
                                        children: [
                                          Text(
                                            global.bengali[index].title,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                TextStyle(color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            global.bengali[index].artist,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 214, 195, 195),
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      )),
                                ]),
                              );
                            })
                        : Center(
                            child: LoaderProgress(),
                          ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, left: 9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'English',
                          style: TextStyle(
                              color: color,
                              fontSize: 20,
                              decoration: TextDecoration.underline,
                              decorationThickness: 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 160,
                    child: global.hollywood.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: false,
                            scrollDirection: Axis.horizontal,
                            itemCount: global.hollywood.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    audioplayer.seek(Duration.zero,
                                        index: index);
                                    playlist = ConcatenatingAudioSource(
                                        children:
                                            buildPlaylist(global.hollywood));

                                    songclass = global.hollywood[index];
                                    listsong = global.hollywood;
                                    id = int.parse(songclass.id);
                                    musicindex = index;

                                    Navigator.of(context).push(PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return MusicPlayUi(
                                            InternetMusicState.playlist,
                                            InternetMusicState.musicindex,
                                            id,
                                            InternetMusicState.listsong);
                                      },
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));

                                        var offsetAnimation =
                                            animation.drive(tween);

                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                    ));
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 4, right: 4),
                                  child: Column(children: [
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: CachedNetworkImage(
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        imageUrl:
                                            '${UrlPage.link}music_img/${global.hollywood[index].img}',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      height: 60,
                                      width: 100,
                                      child: Column(
                                        children: [
                                          Text(
                                            global.hollywood[index].title,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            global.hollywood[index].artist,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 214, 195, 195),
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  ]),
                                ),
                              );
                            })
                        : Center(
                            child: LoaderProgress(),
                          ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, left: 9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bollywood',
                          style: TextStyle(
                              color: color,
                              fontSize: 20,
                              decoration: TextDecoration.underline,
                              decorationThickness: 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    // height: 140,
                    child: StreamBuilder<PlayerState>(
                        stream: audioplayer.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;

                          return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: global.bollywood.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color.fromARGB(159, 10, 7, 154),
                                  ),
                                  key: ValueKey(global.bollywood[index]),
                                  child: ListTile(
                                    iconColor: Colors.cyan,
                                    textColor: Colors.white,
                                    leading: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CachedNetworkImage(
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        imageUrl:
                                            '${UrlPage.link}music_img/${global.bollywood[index].img}',
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                      ),
                                    ),
                                    title: Text(
                                      global.bollywood[index].title,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      global.bollywood[index].artist,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    // trailing: Text('Playing'),
                                    onTap: () {
                                      setState(() {
                                        audioplayer.seek(Duration.zero,
                                            index: index);
                                        playlist = ConcatenatingAudioSource(
                                            children: buildPlaylist(
                                                global.bollywood));

                                        songclass = global.bollywood[index];
                                        listsong = global.bollywood;
                                        id = int.parse(songclass.id);
                                        size = 70;

                                        musicindex = index;

                                        Navigator.of(context)
                                            .push(PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                              secondaryAnimation) {
                                            return MusicPlayUi(
                                                InternetMusicState.playlist,
                                                InternetMusicState.musicindex,
                                                id,
                                                InternetMusicState.listsong);
                                          },
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));

                                            var offsetAnimation =
                                                animation.drive(tween);

                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                        ));
                                      });
                                    },
                                  ),
                                );
                              });
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
