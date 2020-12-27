import 'dart:io';

import 'package:flutter/material.dart';
import 'package:instagram_ui/Home.dart';
import '../Widget/PostWidget.dart';
class PostScreenPage extends StatefulWidget {
  @override
  _PostScreenPageState createState() => _PostScreenPageState();
 String userId;
 String postId;
  PostScreenPage({this.postId, this.userId});

}

class _PostScreenPageState extends State<PostScreenPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postreference.document(widget.userId).collection(
            'Postagens de usuarios').document(widget.postId).get(),
        builder: (context, snapshot) {

          switch(snapshot.connectionState) {
          case ConnectionState.waiting:
          return Center(
          child: CircularProgressIndicator(),
          );
          case ConnectionState.done:
          if(snapshot.hasData) {
          Post post = Post.fromDocument(snapshot.data);
          return Center(
            child: Scaffold(
              appBar: AppBar(
                title: Text(post.description, style: TextStyle(color: Colors.black),),
                backgroundColor: Colors.white,
              ),
              body: ListView(
              children: <Widget>[
                post
              ],
              ),
            ) ,
          );
          }
          }

        });
  }
}
