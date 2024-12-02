import 'package:pam4lab/domain/entities/wine_by.dart';

class WineByModel extends WineBy {
  WineByModel({required String tag, required String name})
      : super(tag: tag, name: name);

  factory WineByModel.fromJson(Map<String, dynamic> json) {
    return WineByModel(
      tag: json['tag'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'name': name,
    };
  }
}
