import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_ui/Home.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeago;
class CommentsPage extends StatefulWidget {
  String postId;
  String ownerId;
  String url;

  CommentsPage({this.postId, this.ownerId, this.url});


  @override
  _CommentsPageState createState() => _CommentsPageState(postId: this.postId, ownerId: ownerId, url: url);
}

class _CommentsPageState extends State<CommentsPage> {
  String postId;
  String ownerId;
  String url;
  TextEditingController coments = TextEditingController();

  _CommentsPageState({this.postId, this.ownerId, this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comentários",style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,

      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: displayComments(),
          ),
          Divider(),
          ListTile(
            title: TextField(
              controller: coments,
              decoration: InputDecoration(
                hintText: 'Escreva seu comentário aqui',
                hintStyle: TextStyle(color: Colors.grey)
              ),

            ),
            trailing: FlatButton(
              child: Text("Comentar",  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
              onPressed: () async {
                commentsReference.document(postId).collection('commentsPosts').add({
                  'username' : user.username,
                  'postid' : postId,
                  'comment' : coments.text,
                  'urlprofile' : user.url,
                  'timestamp' : DateTime.now(),
                  'userid' : user.id,
                });
                bool isNotPosterOwne = ownerId != user.id;
                if(isNotPosterOwne) {
                  activityReference.document(ownerId).collection('FeedItems').add({'type': 'comment',
                    'userid': user.id,
                    'username' : user.username,
                    'url' : url,
                    'userprofileimg' : user.url,
                    'postid': postId,
                    'commentsdata': coments.text,
                    'timestamp': DateTime.now(),

                  });

                }
                coments.clear();
              },
            ),
          )
        ],

      ),
    );
  }
  displayComments() {
    return StreamBuilder(
      stream: commentsReference.document(postId).collection('commentsPosts').orderBy('timestamp', descending: false).snapshots(),
      builder: (context,snapshot) {

          if(snapshot.hasData) {
            List<Comment> coments = [];
            snapshot.data.documents.forEach((value) {
              coments.add(Comment.fromDocument(value));
            });



            return ListView(
              children: coments,
            );
          }
          else if(!snapshot.hasData) {
            return Text('sem dados');
          }
        }



    );
  }
}

class Comment extends StatelessWidget {
  String postId;
  String userId;
  String username;
  String comment;
  String urlprofile;
  Timestamp timestamp;


  Comment({this.postId, this.userId, this.username, this.comment,
      this.urlprofile, this.timestamp});
 factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      postId: doc['postid'],
      urlprofile: doc['urlprofile'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      userId: doc['userid'],
      username: doc['username'],

    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: ListTile(
        title: Text(username + ": " + comment, style: TextStyle(color: Colors.black, fontSize: 18),),
        leading: CircleAvatar(

          backgroundImage: NetworkImage(urlprofile),

        ),
        subtitle: Text(fortimeago(timestamp),style: TextStyle(color: Colors.grey, fontSize: 18),) ,
      ),
    );
  }
  fortimeago(Timestamp timestamp) {
   timeago.setLocale('br', timeago.Portuguese(shortForm: true));
    return timeago.format(timestamp.toDate() , locale: 'br',);
  }
}
