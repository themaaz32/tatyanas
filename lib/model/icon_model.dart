import 'package:tatyanas_app/model/image_model.dart';

import 'dart:convert';

bool ifSourceIsFile(String source) {
  return source.compareTo("file") == 0;
}

List<IconModel> iconModelFromJson(String str) => List<IconModel>.from(json.decode(str).map((x) => IconModel.fromJson(x)));

String iconModelToJson(List<IconModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class IconModel {
  IconModel({
    this.iconLink,
    this.source,
    this.images,
  });

  String iconLink;
  String source;
  List<ImageModel> images;

  addImageEntry(ImageModel imageModel) {
    images.add(imageModel);
  }

  removeImageEntry(index) {
    images.removeAt(index);
  }

  factory IconModel.fromJson(Map<String, dynamic> json) => IconModel(
        iconLink: json["icon_link"],
        source: json["source"],
        images: List<ImageModel>.from(
            json["images"].map((x) => ImageModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "icon_link": iconLink,
        "source": source,
        "images": List<dynamic>.from(images.map((x) => x.toJson())),
      };
}
