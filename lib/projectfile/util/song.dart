class Song {
  final String title;
  final String artist;
  final String filePath;

  final String album;

  final String genre;

  final String duration;

  final String releasedate;

  final String id;
  final String img;
  final String songLyrics;
  bool isFavorite;
  Song(
      {required this.title,
      required this.artist,
      required this.filePath,
      required this.album,
      required this.genre,
      required this.duration,
      required this.releasedate,
      required this.id,
      required this.img,
      required this.songLyrics,
      this.isFavorite = false});
}
