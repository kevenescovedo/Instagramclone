
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_ui/Pages/EditProfilePage.dart';
import 'package:instagram_ui/Pages/PostScrennPage.dart';
import '../Home.dart';
import '../Models/Users.dart';
import '../Widget/PostWidget.dart';
class ProfilePage extends StatefulWidget {
  String idUser;
  ProfilePage({this.idUser});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String current = user?.id;
  List<Post> postagens = List<Post>();
  int countPosts;
  bool loading = false;
  String postorintation = 'grid';
  int countFollowers;
  int countFollowing;


  bool following;
  FutureBuilder TopViewProfile() {

  
    return FutureBuilder(

      future: usereference.document(widget.idUser).get(),
      builder: (context,snapshot){
        switch(snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center( child: CircularProgressIndicator());
          case ConnectionState.done:
            if(snapshot.hasData) {
              User usuario = User.fromDocument(snapshot.data);
               return Container(
                 child: Column(
                   children: <Widget>[
                     Row(
                       children: <Widget>[
                         Padding(
                           padding: EdgeInsets.only(top: 15.0),
                           child: CircleAvatar(
                             radius: 54,
                             backgroundImage: NetworkImage(usuario.url),
                           ),
                         ),
                         Expanded(
                           flex: 1,
                           child: Column(
                             children: <Widget>[
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                 mainAxisSize: MainAxisSize.max,
                                 children: <Widget>[
                                   CreateColum("Postagens", countPosts),
                                   CreateColum("Seguidores",countFollowers),
                                   CreateColum("Seguindo",countFollowing)
                                 ],
                               ),
                               CriarButton(),

                             ],
                           ),
                         )
                       ],
                     ),
                     Container(

                       
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: <Widget>[
                             Text(usuario.username,style: TextStyle(fontSize: 20),textAlign: TextAlign.left ),
                             Text(usuario.profileName,style: TextStyle(fontSize: 20),textAlign: TextAlign.left ),
                             Text(usuario.bio,style: TextStyle(fontSize: 20), textAlign: TextAlign.left,)
                           ],

                         )
                     )

                   ],

                 ),
               );
            }
        }
      },
    );

  }
  Widget CriarButton() {
    if(widget.idUser == current ) {

    return RaisedButton(
      color: Colors.white,
      child: Container(
        alignment: Alignment.center,
        width: 200,
        child: Text("Editar Perfil", style: TextStyle(color: Colors.black),),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.orange)

      ),
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => EditProfilePage(UserId: current,)
        ));
      },
    );






    }
    else if(following == false) {
      return RaisedButton(
        color: Colors.orange,
        child: Container(
          alignment: Alignment.center,
          width: 200,
          child: Text("Seguir", style: TextStyle(color: Colors.black),),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.orange)

        ),
        onPressed: (){
         setState(() {
           following = true;
           countFollowers = countFollowers + 1;
         });
         followersReference.document(widget.idUser).collection('usersFollowers').document(current).setData({});
         followingsReference.document(current).collection('usersFollowings').document(widget.idUser).setData({});
         activityReference.document(widget.idUser).collection('FeedItems').document(current).setData({
           'type': 'follow',
           'ownerid' : widget.idUser,
           'username' : user.username,
            'timestamp' : DateTime.now(),
           'userprofileimg' : user.url,
           'userid' : current

         });

        },
      );

    }
    else if(following == true) {
      return RaisedButton(
        color: Colors.deepPurpleAccent,
        child: Container(
          alignment: Alignment.center,
          width: 200,
          child: Text("Deseguir", style: TextStyle(color: Colors.black),),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.orange)

        ),
        onPressed: (){
          setState(() {
            following = false;
            countFollowers = countFollowers - 1;
          });
          followersReference.document(widget.idUser).collection('usersFollowers').document(current).get().then((value){
            if(value.exists) {
              value.reference.delete();
            }
          });
          followingsReference.document(current).collection('usersFollowings').document(widget.idUser).get().then((value){
            if(value.exists) {
              value.reference.delete();
            }
          });
          activityReference.document(widget.idUser).collection('feedItems').document(current).get().then((value){
            if(value.exists) {
              value.reference.delete();
            }
          });
        },
      );

    }
  }
 Column CreateColum(String title, int count) {
   return Column(
     mainAxisAlignment: MainAxisAlignment.center,
     mainAxisSize: MainAxisSize.min,
     children: <Widget>[
       Text(count.toString(), style: TextStyle(color: Colors.black, fontSize: 23),),
       Text(title, style: TextStyle(color: Colors.black, fontSize: 19),)
     ],
   );
 }
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllPostsFromUser();
    getAllFollowers();
    getAllFollowing();
    checkcurentuserfollowneruserprofile();
  }
  getAllFollowers() async {
    QuerySnapshot querySnapshot = await followersReference.document(widget.idUser).collection('usersFollowers').getDocuments();
    setState(() {
      countFollowers = querySnapshot.documents.length;
    });
  }
  getAllFollowing() async {
    QuerySnapshot querySnapshot = await followingsReference.document(widget.idUser).collection('usersFollowings').getDocuments();
    setState(() {
      countFollowing = querySnapshot.documents.length;
    });
  }
  checkcurentuserfollowneruserprofile() async {
    DocumentSnapshot docSnapshot = await followersReference.document(widget.idUser).collection('usersFollowers').document(current).get();

      setState(() {
        following = docSnapshot.exists;
      });
    }





  @override
  Widget build(BuildContext context) {
  return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.white,
       title: Text("Perfil",style: TextStyle(color: Colors.black),),

     ),
     body: ListView(
       children: <Widget>[
         TopViewProfile(),
         Divider(),
         createmenuOrientationPost(),
         Divider(height: 0.0,),
         Padding(
           padding: EdgeInsets.only(top: 20),
           child: PostUser(),

         ),
       ],
     ),
   );
  
  }
  PostUser() {
    if(loading) {
      return Center(
        child: CircularProgressIndicator(),
      );

    }
    else if(postagens.isEmpty) {
      return Center(
        child:  Text("não tem postagem"),
      );
    }
    else if(postorintation == 'list') {
      return Column(
      children: postagens
      );

    }
    else if(postorintation == 'grid') {
      List<GridTile> photos = List();
      postagens.forEach((element) {
     var item =   GridTile(child: GestureDetector(

          onTap: (){Navigator.push(context, MaterialPageRoute(
            builder: (context) => PostScreenPage(userId: element.ownerId, postId: element.postId,)
          ));},
          child: Image.network(element.url),
        ),);
       photos.add(item);
      });
     return GridView.count(
        crossAxisCount: 3,
       childAspectRatio: 1.0,
       mainAxisSpacing: 1.5,
       crossAxisSpacing: 1.5,
       shrinkWrap: true,
       physics: NeverScrollableScrollPhysics(),
       children: photos,
      );
    }

  }

  getAllPostsFromUser() async {
    setState(() {
     loading = true;
    });
   QuerySnapshot querySnapshot = await postreference.document(widget.idUser).collection('Postagens de usuarios').orderBy('timestamp').getDocuments();
   setState(() {
     countPosts = querySnapshot.documents.length;
     postagens = querySnapshot.documents.map((value)=>Post.fromDocument(value)).toList();
     loading = false;
   });


  }
  createmenuOrientationPost() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
          Icons.grid_on,
            size: 40,
            color: postorintation == 'grid' ? Colors.black: Colors.grey,

          ),
          onPressed: (){
            setState(() {
              postorintation  = 'grid';
            });
          },
        ),
        IconButton(
          icon: Icon(
            Icons.list,
            color: postorintation == 'list' ? Colors.black: Colors.grey,
            size: 40,

          ),
          onPressed: (){
            setState(() {
              postorintation  = 'list';
            });
          },
        ),
      ],
    );
  }
}
