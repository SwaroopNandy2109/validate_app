import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:validatedapp/services/database.dart';

class PostsBloc {
  DatabaseService databaseService;
  bool showIndicator = false;
  List<DocumentSnapshot> documentList;

  BehaviorSubject<List<DocumentSnapshot>> postController;

  BehaviorSubject<bool> showIndicatorController;

  PostsBloc() {
    postController = BehaviorSubject<List<DocumentSnapshot>>();
    showIndicatorController = BehaviorSubject<bool>();
    databaseService = DatabaseService();
  }

  Stream get getShowIndicatorStream => showIndicatorController.stream;

  Stream<List<DocumentSnapshot>> get postStream => postController.stream;

  /*This method will automatically fetch first 10 elements from the document list */
  Future fetchFirstList() async {
    try {
      documentList = await databaseService.fetchFirstList();
      postController.sink.add(documentList);
      try {
        if (documentList.length == 0) {
          postController.sink.addError("No Data Available");
        }
      } catch (e) {}
    } on SocketException {
      postController.sink.addError(SocketException("No Internet Connection"));
    } catch (e) {
      print(e.toString());
      postController.sink.addError(e);
    }
  }

  /*This will automatically fetch the next 10 elements from the list*/
  fetchNextPosts() async {
    try {
      updateIndicator(true);
      List<DocumentSnapshot> newDocumentList =
          await databaseService.fetchNextList(documentList);
      documentList.addAll(newDocumentList);
      postController.sink.add(documentList);
      try {
        if (documentList.length == 0) {
          postController.sink.addError("No Data Available");
          updateIndicator(false);
        }
      } catch (e) {
        updateIndicator(false);
      }
    } on SocketException {
      postController.sink.addError(SocketException("No Internet Connection"));
      updateIndicator(false);
    } catch (e) {
      updateIndicator(false);
      print(e.toString());
      postController.sink.addError(e);
    }
  }

  /*For updating the indicator below every list and paginate*/
  updateIndicator(bool value) async {
    showIndicator = value;
    showIndicatorController.sink.add(value);
  }

  void dispose() {
    postController.close();
    showIndicatorController.close();
  }
}
