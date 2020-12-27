import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_ui/Home.dart';
import 'package:instagram_ui/Models/Users.dart';
import 'package:instagram_ui/Pages/ProfilePage.dart';
import 'package:lottie/lottie.dart';
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _campopesquisa = TextEditingController();
  Future<QuerySnapshot> usersResults;
  realizar_pesquisa(value) {
    Future<QuerySnapshot> usersMap = usereference.where(
      'username', isGreaterThanOrEqualTo: value).getDocuments();
    setState(() {
      usersResults = usersMap;
    });
  }

  AppBar barra_pesquisa() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        decoration: InputDecoration(
          hintText: "Pesquise aqui",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 12.0
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)
          ),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)
          ),
          filled: true,
          prefixIcon: Icon(Icons.person,color: Colors.grey,),
            suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: ()=> _campopesquisa.clear())
        ) ,
        controller: _campopesquisa,
        onChanged: realizar_pesquisa ,
        ),
      );

  }
  semusersresult() {
   return ListView(

     children: <Widget>[
       Center(
         child: Lottie.asset('animations/search.json',width: 400 ),
       ),
       Text("Pesquise para encontrar usuarios",textAlign: TextAlign.center,)
     ],
   );
  }
  usersresults() {
    return FutureBuilder(
      future: usersResults,
      builder: (context,snapshot){
        switch(snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(backgroundColor: Colors.orange,),
            );
          case ConnectionState.done:
            if(snapshot.hasData) {
              List documents = snapshot.data.documents;
             List usuarios = documents.map((e) => User.fromDocument(e)).toList();
              return ListView.builder(
                 itemCount: usuarios.length,
                 itemBuilder: (context, index) {
                   return GestureDetector(
                     onTap: (){
                       Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(idUser: usuarios[index].id,)));
                     },

                     child:  Card(
                       color: Colors.white,
                       child: ListTile(
                         title: Text(usuarios[index].profileName),

                         leading: CircleAvatar(

                             backgroundColor: Colors.deepPurpleAccent,

                             backgroundImage: NetworkImage(usuarios[index].url)

                         ),
                         subtitle: Text(usuarios[index].username) ,
                       ),
                     ),
                   );
                 }

               );
            }
            else {
               return Center(
                 child: Lottie.asset("animations/404.json",width: 400) ,
               );
            }
        }
      },

    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: barra_pesquisa(),
      backgroundColor: Colors.white,
      body: usersResults == null ? semusersresult() : usersresults(),
    );
  }
}
