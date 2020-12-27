import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_ui/Home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../Models/Users.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image/image.dart' as Imd;
import 'package:http/http.dart';
import 'package:flutter_google_places/flutter_google_places.dart';



import 'package:image_picker/image_picker.dart';
class UploadPage extends StatefulWidget {
  User gCurrentUser;
  UploadPage({this.gCurrentUser});
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
 File file;
 TextEditingController _posicaofiled = TextEditingController();
 TextEditingController _descricaofiled = TextEditingController();
 String postId = Uuid().v4();
 bool upload = false;
 double _progress = 0.0;
 Future<File>compressarfoto() async {
   Directory temporariodiretorio = await getTemporaryDirectory();
   String path = temporariodiretorio.path;
   Imd.Image imdimage = Imd.decodeImage(file.readAsBytesSync());
   File imagemcomprimida = File("${path}/img_${postId}.jpg")..writeAsBytesSync(Imd.encodeJpg(imdimage,quality: 90));
   return imagemcomprimida;


 }
  uploadFoto(foto) async {
   StorageUploadTask uploadTask = await firebaseStorage.child("post_${postId}.jpg").putFile(foto);
   StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
   uploadTask.events.listen((event) {
     setState(() {
       _progress = event.snapshot.bytesTransferred.toDouble() /
           event.snapshot.totalByteCount.toDouble();
     });
   }).onError((error) {
     // do something to handle error
   });
   var urlDownload = storageTaskSnapshot.ref.getDownloadURL();
   return urlDownload;
 }
 controlarUploadPostagem() async {
   setState(() {
     upload = true;

   });
   File fotoUpload = await compressarfoto();
   String url = await uploadFoto(fotoUpload);
   salvarpostagem(url: url,description: _descricaofiled.text,location: _posicaofiled.text,id: postId);
   setState(() {
     file = null;
     upload = false;
     postId = Uuid().v4();
   });

 }
 salvarpostagem({String url, String location,String id,String description}) {
   Map<String,dynamic> data = {
    "postid":id,
     "likes": {},
     "userid": widget.gCurrentUser.id,
     "description":description,
     "position": location,
     "username": widget.gCurrentUser.username,
     "url": url,
     'timestamp' : DateTime.now()
   };
   postreference.document(widget.gCurrentUser.id).collection("Postagens de usuarios").document(postId).setData(data);
 }


 capturarposicao() async {
   Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
   final coordinates = new Coordinates(position.latitude,position.longitude);
  // final coordinates = new Coordinates(-22.1271756, -51.3775478);
   var location = await Geocoder.local.findAddressesFromCoordinates(coordinates);
   for(var x = 0; x <= location.length; x + 1) {
     location[x].featureName;
   }
   var contry = location.first.countryName;
   var city = location.first.subAdminArea;
   var state = location.first.adminArea;
  setState(() {
    _posicaofiled.text =  "${city},${state},${contry}";

  });
  String api_key = "AIzaSyA6EuXyNTfyuNmHr8Eq1juRGPfk3kksG7o";
  String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=48.8584,2,2945&radius=1500&type=restaurant&keyword=cruise&key=$api_key";
  Response response = await get(url);
  print(response.body);




 }
 Scaffold TelaFormPostagem() {
   return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.white,
       title: Text("Nova Postagem",style: TextStyle(color: Colors.black),),
       leading: IconButton(
         icon: Icon(Icons.arrow_back,color: Colors.black,),
         onPressed: (){
           setState(() {
             file = null;
             upload = false;
             postId = Uuid().v4();
           });
         },

       ),
       actions: <Widget>[
         FlatButton(
           child: Text("Compartilhar"),
           onPressed: upload ? null : controlarUploadPostagem,
         )
       ],
     ),
     body: ListView(
       children: <Widget>[
         upload ? LinearProgressIndicator(
           value: _progress,
         ): Text(""),
         Container(
           height: 270.0,
           width: MediaQuery.of(context).size.width * 0.8,
           child: Center(
             child: AspectRatio(
               aspectRatio: 16/9,
               child: Container(
                 decoration: BoxDecoration(
                   image: DecorationImage(
                     image: FileImage(file),
                     fit: BoxFit.cover

                   )
                 )
               ),
             ),
           ),
         ),
         Padding(padding: EdgeInsets.only(top: 20),),
         ListTile(
           leading: CircleAvatar(
             backgroundImage: NetworkImage(widget.gCurrentUser.url),

           ),
           title: TextField(
             controller: _descricaofiled,
             decoration: InputDecoration(
               hintText: "O que você está fazendo ou pensando ?",
               hintStyle: TextStyle(color: Colors.grey, fontSize: 20,fontWeight: FontWeight.bold),
               border: InputBorder.none,


             ),

           ),
         ),
         Divider(),
         ListTile(
           leading: Icon(Icons.person_pin_circle),


           title: TextField(
             controller: _posicaofiled ,
             decoration: InputDecoration(

               hintText: "Onde Você está ?",
               hintStyle: TextStyle(color: Colors.grey, fontSize: 20,fontWeight: FontWeight.bold),
               border: InputBorder.none,


             ),

           ),
         ),
         Divider(),
        GestureDetector(
          child: Container(
            width: 200,
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Center(
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 6.0),
                child: Icon(Icons.location_on),

              ),
            Text("Pegar minha Locaização",style: TextStyle(color: Colors.white, fontSize: 20),),
            ],

          ),
                )

                ),



              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.purple,
                    Colors.orange,

                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
        ),
         onTap: capturarposicao
        )



       ],
     ),
   );
 }

 Scaffold TelaescolherImagem() {
   return Scaffold(
     appBar: AppBar(
       backgroundColor: Colors.white,
       title: Center(
         child: Image.asset("images/logo.png",width: 200,),
       ),

     ),
     body: Container(
       width: double.infinity,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.center,

         children: <Widget>[
           Icon(

             Icons.add_photo_alternate,

             color: Colors.grey,
             size: 220,
           ),

           Padding(
               padding: EdgeInsets.only(top: 12),
               child: GestureDetector(
                 onTap: () {

                   return showDialog(context: context,
                       builder: (context)
                       {
                         return SimpleDialog(
                           backgroundColor: Colors.black,
                           title: Text("Nova Postagem",
                             style: TextStyle(color: Colors.white),
                           ),

                           children: <Widget>[
                             SimpleDialogOption(
                               child:  Text("Capturar imagem pela Câmera",
                                 style: TextStyle(color: Colors.white),

                               ) ,
                               onPressed: () async {
                                 Navigator.pop(context);
                                 File imageFile = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 970, maxHeight: 680);
                                 setState(() {
                                   file = imageFile;
                                 });
                               },
                             ),
                             SimpleDialogOption(
                               child:  Text("Pegar Imagem da Galeria",
                                 style: TextStyle(color: Colors.white),
                               ) ,
                               onPressed: () async {
                                 Navigator.pop(context);
                                 File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery,maxWidth: 670, maxHeight: 400);
                                 setState(() {
                                   file = imageFile;
                                 });
                               },
                             ),
                             SimpleDialogOption(
                               child:  Text("Cancelar",
                                 style: TextStyle(color: Colors.white),

                               ) ,
                               onPressed: () async {
                                 Navigator.pop(context);

                               },
                             )
                           ],

                         );
                       });
                 },
                 child: Container(
                   child: Padding(
                     padding: EdgeInsets.all(15),
                     child: Text("Escolher imagem",textAlign: TextAlign.center,
                       style: TextStyle(
                           fontSize: 25,
                           color: Colors.white
                       ),
                     ),
                   ),


                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       begin: Alignment.topRight,
                       end: Alignment.bottomLeft,
                       colors: [
                         Colors.purple,
                         Colors.orange,

                       ],
                     ),
                     borderRadius: BorderRadius.circular(20),
                   ),
                 ),
               )
           )
         ],
       ),
     ),
   );
 }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return file == null ? TelaescolherImagem(): TelaFormPostagem();
  }
}



