import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class CreateAcountPage extends StatefulWidget {
  @override
  _CreateAcountPageState createState() => _CreateAcountPageState();
}

class _CreateAcountPageState extends State<CreateAcountPage> {
  String username = "";
  final _formkey = GlobalKey<FormState>();
  final _scafoldkey = GlobalKey<ScaffoldState>();
  final userreference = Firestore.instance.collection("users");
 Future<bool>  userexist(valor) async {
    DocumentSnapshot documentSnapshot = await userreference.document(valor).get();
    return documentSnapshot.exists;
  }
  submituser() async {
    var form = _formkey.currentState;
   
    if(form.validate()){

      form.save();
      print("validado ${username}");
      SnackBar snackbar = SnackBar(content: Text("Seja Bem vindo  ${username}"),);
    _scafoldkey.currentState.showSnackBar(snackbar);
     Timer(Duration(seconds: 5),(){
       Navigator.pop(context,username);
     });
    }
  }

  Future<bool> doesNameAlreadyExist(String name) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('username', isEqualTo: name)
        .limit(1)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    return documents.length == 1;
  }
  bool _userExist = false;
  checkUserValue<bool>(String user) {
    doesNameAlreadyExist(user).then((val){
      if(val){
        print ("UserName Already Exits");
        _userExist = val;
      }
      else{
        print ("UserName is Available");
        _userExist = val;

      }
    });
    print(_userExist.toString());
    return _userExist;

  }

  String validate(valor) {


     if(valor.trim().length < 5 || valor.isEmpty) {
  return "Nome muito curto, Por favor insira um nome que possua mais de 5 caracteres";
  }

  else if(valor.trim().length > 15) {
  return "Nome, muito longo, Por favor insira um nome que possua menos de 15 caracteres";

  }


  else {
   return checkUserValue(valor) ? "Usuario extiste" :  null;

  }


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldkey,
      backgroundColor: Colors.black,
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:  26.0),
                  child: Center(
                    child: Text("Cadastre-se", style: TextStyle(fontSize: 26.0, color: Colors.white),),
                  ),


                ),
                Padding(
                  padding: EdgeInsets.only(top:  17.0),
                  child:  Center(
                    child:  Lottie.asset('animations/ani_login.json', width: 400),
                  ),

                ),
                Padding(
                  padding: EdgeInsets.only(top:  17.0),
                  child: Container(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0),
                    child: Form(
                      key: _formkey,
                      autovalidate: true,
                      child:  TextFormField(
                        style: TextStyle(
                            color:  Colors.white
                        ),
                        decoration: InputDecoration(
                            hintText: "Insira aqui o seu nome de usuário possuindo no minimo 5 caracteres",
                            hintStyle: TextStyle(color: Colors.grey),
                            labelText: "Nome de usuario",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey)
                            ) ,
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.white)
                            ) ,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.red)
                            ) ,










                        ),
                        validator: validate,
                        onSaved: (texto) {
                          setState(() {
                            username = texto;
                          });

                        },
                      ),
                    ),
                  ),

                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: GestureDetector(

                    child: Container(
                      width: 360.0,
                      height: 55.0,
                      child: Center(
                        child:  Text("Cadastrar", style: TextStyle(color: Colors.white),),
                      ),
                      decoration:  BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onTap: submituser ,
                  ),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}
