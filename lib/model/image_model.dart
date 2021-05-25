class ImageModel {
  ImageModel({
    this.imageLink,
    this.audioLink,
    this.source = "file",
  });

  String imageLink;
  String audioLink;
  String source;

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
    imageLink: json["image_link"],
    audioLink: json["audio_link"],
    source: json["source"],
  );

  Map<String, dynamic> toJson() => {
    "image_link": imageLink,
    "audio_link": audioLink,
    "source": source,
  };
}


