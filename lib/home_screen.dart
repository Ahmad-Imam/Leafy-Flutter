import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomeScreen extends StatefulWidget {


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;

  File imageFile;

  List outputList=[];

  final picker = ImagePicker();

  double confidence;

  pickImageCamera()async{
    var image = await picker.getImage(source: ImageSource.camera);
    if(image==null)return null;
    setState(() {
      imageFile=File(image.path);
    });
    classifyImage(imageFile);
  }

  pickImageGallery()async{
    var image = await picker.getImage(source: ImageSource.gallery);
    if(image==null)return null;
    setState(() {
      imageFile=File(image.path);
    });
    classifyImage(imageFile);
  }

  classifyImage(File imageFile)async
  {
    var output = await Tflite.runModelOnImage(path: imageFile.path,
    numResults: 38,
      threshold: .5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    print(output);
   double conf = output[0]['confidence']*100;
   conf=conf.floorToDouble();
    print('conf is $conf');

    setState(() {
      outputList=output;
      isLoading=false;
      confidence=conf;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel().then((value) {
      setState(() {
      });
    });
  }

  Future loadModel()async
  {
    await Tflite.loadModel(model: 'assets/mobile_graph.tflite',labels: 'assets/retrained_labels.txt',);

  }

@override
  void dispose() {
    // TODO: implement dispose
  Tflite.close();
  super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
              ),
              Text(
                'Leaf Detection',style: TextStyle(color: Colors.black,fontSize: 20),
              ),
              SizedBox(
                height: 100,
              ),
              isLoading? Image.asset('assets/leafy.PNG')
              : Column(
                children: [
                  Container(
                      height: 300,
                      width: 300,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Image.file(imageFile,fit: BoxFit.cover,)),
                  SizedBox(height: 20,),
                  outputList!=null?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Class : ${outputList[0]['label']} $confidence %',style: TextStyle(color: Colors.black54,fontSize: 20),),
                        ],
                      ):Container(),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: TextButton(onPressed: (){
                        pickImageCamera();
                      }, child: Text('Take Photo',style: TextStyle(color: Colors.black54),),)),
                  Align(
                      alignment: Alignment.center,
                      child: TextButton(onPressed: (){
                        pickImageGallery();
                      }, child: Text('Choose from Gallery',style: TextStyle(color: Colors.black54),),),),
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
}
