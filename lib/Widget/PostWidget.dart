
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_ui/Pages/CommentsPage.dart';
import 'package:instagram_ui/Pages/ProfilePage.dart';
import '../Models/Users.dart';
import '../Home.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  //final String timestamp;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;



  Post({this.postId, this.ownerId,  this.likes,
    this.username, this.description, this.location, this.url});
  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot["postid"],
      ownerId: documentSnapshot["userid"],
      //timestamp: documentSnapshot['timestamp'],
      likes: documentSnapshot["likes"],
      username: documentSnapshot['username'],
      description: documentSnapshot["description"],
      location: documentSnapshot["position"],
      url: documentSnapshot['url'],
    );
  }
  int getTotalNumberLikes(likes) {
    if(likes == null) {
      return 0;
    }
    else {
      int counter = 0;
      likes.values.forEach((value){
        if(value == true) {
          counter = counter + 1;
        }
      });
      return counter;
    }


  }
  @override
  _PostState createState() => _PostState(postId: this.postId,
      ownerId: this.ownerId,
      likes: this.likes,
      username: this.username,
      description: this.description,
      location: this.location,
      url: this.url,
      likescount: getTotalNumberLikes(this.likes)

  );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  //final String timestamp;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int  likescount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = user?.id;



  _PostState({this.postId, this.ownerId, this.likes,
    this.username, this.description, this.location, this.url, this.likescount,

  });
  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          createPostPicture(),
          CreatePostFooter(),
        ],
      ),
    );
  }
  createPostHead() {
    return FutureBuilder(
      future: usereference.document(ownerId).get(),
      builder: (data, snapshot) {
        if(!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        else {
          User user = User.fromDocument(snapshot.data);
          bool isPostOwner = user.id == ownerId;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.url),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(idUser: ownerId,)));
              },
              child: Text(user.username,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            subtitle: Text(location,style: TextStyle(color: Colors.grey),),
            trailing: isPostOwner ? IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onPressed: (){},
            ) : Text(""),
          );
        }

      },
    );
  }
  removeLike() {
 bool ispostOner = currentOnlineUserId != ownerId;
 if(ispostOner) {
   activityReference.document(ownerId).collection('FeedItems').document(postId).get().then((value) => {
     value.reference.delete()
   });
 }
  }
  addLike() {
    bool ispostOner = currentOnlineUserId != ownerId;
    if(ispostOner) {
      activityReference.document(ownerId).collection('FeedItems').document(
          postId).setData({'type': 'like',
        'userid': user.id,
        'username' : user.username,
         'url' : url,
         'userprofileimg' : user.url,
        'postid': postId,
        'timestamp':DateTime.now(),

      });
    }
  }
  controlLikePost() {
    bool _liked = likes[currentOnlineUserId] == true;
    if(_liked) {
      postreference.document(ownerId)
          .collection('Postagens de usuarios')
          .document(postId)
          .updateData({'likes.$currentOnlineUserId': false});

      removeLike();
      setState(() {
        likes[currentOnlineUserId] = false;
        likescount = likescount - 1;
        isLiked = false;
      });
    }
    else {
      postreference.document(ownerId)
          .collection('Postagens de usuarios')
          .document(postId)
          .updateData({'likes.$currentOnlineUserId': true});

    addLike();
      setState(() {
        likes[currentOnlineUserId] = true;
        likescount = likescount + 1;
        isLiked = true;

        showHeart = true;
        print('showheart');
      });
      Timer(Duration(milliseconds: 800),(){
        setState(() {
          showHeart = false;
        });
      });
    }


    
  }
  createPostPicture() {
    print(showHeart.toString());
    return GestureDetector(
      onDoubleTap: controlLikePost,
      child:  Stack(
        alignment: Alignment.center,
        children: <Widget>[


          Image.network(url),
          showHeart ? Icon(Icons.favorite, color: Colors.deepPurpleAccent, size: 140) : Text('')
        ],
      ),
    );
  }
  CreatePostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment:  MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 40.0, left: 20.0)),

            GestureDetector(
              onTap: controlLikePost,
              child: isLiked ? Icon( Icons.favorite, size: 40, color: Colors.deepPurpleAccent,): Icon( Icons.favorite_border, size: 30, color: Colors.deepPurpleAccent,) ,
            ),
            Padding(
                padding: EdgeInsets.only(right: 20)),

            GestureDetector(
              onTap: (){goToCommentsPage(context, postId: postId, owneruserId: ownerId, url: url );},
              child: Icon(Icons.chat_bubble_outline, size: 30, color: Colors.black,) ,
            ),

          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text("${likescount} Likes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),

            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20, right: 7),
              child: Text(username, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),),

            ),
            Expanded(
              child: Text(description, style: TextStyle(color: Colors.black, fontSize: 18),),
            )
          ],
        )

      ],
    );
  }
  goToCommentsPage(BuildContext context, {String postId, String owneruserId, url}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => CommentsPage(postId: postId, ownerId: owneruserId, url: url,)
    ));
  }
}
