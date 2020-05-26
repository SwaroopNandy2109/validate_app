import 'dart:convert';

import 'package:http/http.dart';

class FetchPreview {
  String title;
  String description;
  String image;
  String url;
  int error;

  validateUrl(String url) {
    if (url?.startsWith('http://') == true ||
        url?.startsWith('https://') == true) {
      return url;
    } else {
      return 'http://$url';
    }
  }

  Future getPreview(String link) async {
    try {
      Response response = await get(
          'https://api.linkpreview.net/?key=be284a1fe82fc677201ac7ab33384470&q=$link');
      Map data = jsonDecode(response.body);

      title = data['title'];
      description = data['description'];
      image = data['image'];
      url = data['url'];
      error = data['error'];

      return {
        'title': title ?? '',
        'description': description ?? '',
        'image': image ?? '',
        'url': url ?? '',
        'error': error ?? '',
      };
    } catch (e) {
      print("Error caught: $e");
    }
  }
}
