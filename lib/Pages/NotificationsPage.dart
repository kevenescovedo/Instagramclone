

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_ui/Home.dart';
import 'ProfilePage.dart';
import 'package:timeago/timeago.dart' as time_ago;
import 'PostScrennPage.dart';
class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notificações", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: getNotifications(),
        builder: (context,snapshot){
          if(!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data);
        },
      ),
    );

  }
  getNotifications() async {
    QuerySnapshot query = await activityReference.document(user.id).collection('FeedItems').orderBy('timestamp',descending: true).limit(50).getDocuments();
    List<NotificationItem> notifications = [];
    query.documents.forEach((element) {
      notifications.add(NotificationItem.fromDocument(element));
    });
  return notifications;
  }
}
String textNotification;
Widget mediaPreview;

class NotificationItem extends StatelessWidget {
  String username;
  String postid;
  String type;
  String userid;
  String url;
  String userprofileimg;
  String commentdata;
  Timestamp timestamp;


  NotificationItem({this.username, this.postid, this.type, this.userid, this.url,
      this.userprofileimg, this.commentdata, this.timestamp});
  factory  NotificationItem.fromDocument(DocumentSnapshot doc){
    return NotificationItem(
     username: doc['username'],
      postid: doc['postid'],
      type: doc['type'],
      userid: doc['userid'],
      url: doc['url'],
      userprofileimg: doc['userprofileimg'],
      timestamp: doc['timestamp'],
      commentdata: doc['commentsdata'],
    );

  }

  BuildContext get context => null;

  @override
  Widget build(BuildContext context) {
    configureMediaPreview();
    return ListTile(
      title: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(idUser: userid,)));
        },
        child:RichText(
         overflow: TextOverflow.clip,
          text: TextSpan(
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: username, style: TextStyle(color: Colors.black,)),
                TextSpan(text: " $textNotification  ", style: TextStyle(color: Colors.black))
              ]
          ),
        ),

      ),
      leading: CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(userprofileimg),
      ),
      trailing: mediaPreview,
      subtitle: Text( covertTimeago(timestamp), style: TextStyle(color: Colors.grey),),
    );
  }
  covertTimeago(Timestamp data) {
   time_ago.setLocaleMessages('br', time_ago.PtBrMessages());
   return time_ago.format(data.toDate(), locale: 'br');
  }
  configureMediaPreview() {
    if(type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: (){gotoPostScreenPage(context);},
      child: Container(
        width: 50,
        height: 50,
        child: AspectRatio(
          aspectRatio: 16/9,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(url)
              )
            ),
          ),
        ),
      ),
      );
    }
    else {
      mediaPreview = Text('');

    }
    print(type);
    if(type == 'comment') {
      textNotification = "comentou isso: $commentdata";
    }
    else if(type == 'like') {
      textNotification = "deu like no seu post";
    }
    if(type == 'follow') {
      textNotification = "começou a seguir você";
    }

  }
  gotoPostScreenPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => PostScreenPage(userId: userid, postId: postid,)));
  }
}

