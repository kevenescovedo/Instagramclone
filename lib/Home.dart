

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram_ui/Pages/Criar_nova_conta.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_ui/Pages/NotificationsPage.dart';
import 'package:instagram_ui/Pages/ProfilePage.dart';
import 'package:instagram_ui/Pages/SearchPage.dart';
import 'package:instagram_ui/Pages/TimeLinePage.dart';
import 'package:instagram_ui/Pages/UploadPage.dart';
import 'Models/Users.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();

}
FirebaseAuth _auth = FirebaseAuth.instance;
GoogleSignIn googleSignIn = GoogleSignIn();
var usereference = Firestore.instance.collection("users");
  var firebaseStorage = FirebaseStorage.instance.ref().child("Fotos Postagens");
var postreference = Firestore.instance.collection("Postagens");
var activityReference =  Firestore.instance.collection('Feed');

var commentsReference =  Firestore.instance.collection('comments');
var followersReference = Firestore.instance.collection('followers');
var followingsReference = Firestore.instance.collection('followings');
User user = User(id: "aaaaaa");


class _HomeState extends State<Home> {
  void initState() {
    // TODO: implement initState
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount googleas) {
      controleexibirtelas(googleas);
    },
        onError: (e) {
          print("erro ${e}");
        }
    );
    googleSignIn.signInSilently(suppressErrors: false).then((value) =>
        controleexibirtelas(value),  onError: (e) {
      print("erro ${e}");
    });
  }

  controleexibirtelas(GoogleSignInAccount g) {
    if(g != null) {
      setState(() {
        saveuserstore();
        _isauth = true;
      });
    }
    else {
      setState(() {
        _isauth = false;
      });
    }
  }
  saveuserstore() async {
    GoogleSignInAccount  gcurentuser = googleSignIn.currentUser;
    DocumentSnapshot documentsnap = await usereference.document(gcurentuser.id).get();
    if(!documentsnap.exists) {
      String username = await  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAcountPage()));
      usereference.document(gcurentuser.id).setData({
        "id": gcurentuser.id,
        "username" : username,
        "bio" : "",
        "email": gcurentuser.email,
        "profileName": gcurentuser.displayName,
        "url": gcurentuser.photoUrl,


      });
      await usereference.document(gcurentuser.id).get();
    }

   setState(() {
     user =  User.fromDocument(documentsnap);
   });
  }
  var _isauth = false;
  PageController _pagecontroller  = PageController();
 int indexgetpage = 0;
  Scaffold HomeScreen() {

    return Scaffold(
      backgroundColor: Colors.black,

      body: PageView(
        children: <Widget>[
           TimeLinePage(),
           NotificationsPage(),
           UploadPage(gCurrentUser: user,),
           SearchPage(),
          ProfilePage(idUser: user.id,),
        ],
        controller: _pagecontroller ,
        onPageChanged: (int index){
          setState(() {
            indexgetpage = index;
          });
        },
        scrollDirection: Axis.horizontal,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indexgetpage,
        fixedColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("")

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text(""),


          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              title: Text("")

          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text(""),

          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text("")

          ),
        ],
        onTap: (int index) {
          _pagecontroller.animateToPage(index, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
        },
      )
    );
  }
  Scaffold loginscrenn() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
        Colors.purple,
        Colors.orange,

    ],
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            Image.asset("images/logo.png",height: 70,),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: GestureDetector(
                  child: Container(
                    width: 360,
                    height: 55,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/button_googlesignin.png"),
                        fit: BoxFit.cover,

                      )

                    ),
                  ),
                  onTap: (){
                   googleSignIn.signIn();
                  },
                ),
              )
            ],
          ),
        )

        ),
      ),
    );
  }
  @override


  @override
  Widget build(BuildContext context) {
    if(!_isauth) {
         return loginscrenn();
    }
    else {

     return HomeScreen();

    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pagecontroller.dispose();
  }
}
