class PlayersList {
  String? pName;
  String? pId;
  String? pUrl;
  bool? isPlaying;

  PlayersList({this.pName, this.pId, this.pUrl, this.isPlaying});

  factory PlayersList.fromMap(Map<dynamic, dynamic> data, String id) =>
      PlayersList(
        pName: data["name"].toString() ?? "",
        pId: id ?? "",
        pUrl: data["url"].toString() ?? "",
        isPlaying: data["playing"] as bool ?? false,
      );
}
