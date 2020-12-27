import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_ui/Pages/ProfilePage.dart';
import '../Home.dart';
import '../Models/Users.dart';
class EditProfilePage extends StatefulWidget {
  String UserId;
  EditProfilePage({this.UserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}


class _EditProfilePageState extends State<EditProfilePage> {
  User usuario;
 bool loading = false;
 TextEditingController profileName = TextEditingController();
  TextEditingController bio = TextEditingController();
  bool profilenamevalid = true;
  bool biovalidad = true;
  final scafoldkey = GlobalKey<ScaffoldState>();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pegarInfoUser();
  }

  pegarInfoUser() async{
    setState(() {
      loading = true;
    });
    print(widget.UserId);
 DocumentSnapshot documentSnapshot = await usereference.document(widget.UserId).get();
    

    usuario = User.fromDocument(documentSnapshot);
    profileName.text = usuario.profileName;
    bio.text = usuario.bio;

    setState(() {


      loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafoldkey,
      appBar: AppBar(
        title: Text("Configurar Perfil", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        actions: <Widget>[

          IconButton(

            icon: Icon(Icons.done, color: Colors.black,),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(idUser: widget.UserId,)));
            },

          )
        ],
      ),
      body: loading ?Center(child:CircularProgressIndicator()): ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(

                  child: CircleAvatar(
                    radius: 54,
                    backgroundImage: NetworkImage(usuario.url),

                  ),
                  padding: EdgeInsets.only(top: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Nome de Perfll"),
                    TextField(
                      style: TextStyle(fontSize: 24),
                         controller: profileName,
                         decoration: InputDecoration(
                           hintText: "Escreva seu Nome der Perfil",
                           hintStyle: TextStyle(color: Colors.grey),
                           errorText: profilenamevalid ? null : "Nome curto demais"


                         ),
                    )
                  ],

                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Bio de Perfil"),
                      TextField(
                          controller: bio,
                        style: TextStyle(fontSize: 24),
                        decoration: InputDecoration(
                            hintText: "Escreva sua Bio",
                            hintStyle: TextStyle(color: Colors.grey),
                            errorText: profilenamevalid ? null : "Bio longa de mais"


                        ),
                      )
                    ],

                  ),

                ),
                Center(
                  child: RaisedButton(
                    color: Colors.deepPurpleAccent,
                    child: Text("Alterar",style: TextStyle(color: Colors.white, fontSize: 24),),
                    onPressed: () async {
                      if(profileName.text.trim().length < 3 || profileName.text.trim().isEmpty) {
                        setState(() {
                          profilenamevalid = false;
                        });


                      }
                      if(profileName.text.trim().length > 110) {
                        setState(() {
                          biovalidad = false;
                        });


                      }
                      if(biovalidad == true && profilenamevalid == true) {
                        await usereference.document(widget.UserId).updateData({
                         "profileName": profileName.text,
                          "bio": bio.text,
                        }) ;
                          SnackBar snacksucess = SnackBar(
                            backgroundColor: Colors.green,
                            content: Text("Ação realizada com sucesso !!!", style: TextStyle(color: Colors.white),),
                          );

                        scafoldkey.currentState.showSnackBar(snacksucess);
                      }



                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 5.0),),
                Center(
                  child: RaisedButton(
                    color: Colors.red,
                    child: Text("Deslogar",style: TextStyle(color: Colors.white, fontSize: 24),),
                    onPressed: () async{
                      await googleSignIn.signOut();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                    },
                  ),
                )

              ],
            ),

          )
        ],
      )
    );
  }
}
