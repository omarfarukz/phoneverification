import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_practice/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Stream<QuerySnapshot> users =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Firestore'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Read data from cloud firestore',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 150,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: StreamBuilder<QuerySnapshot>(
                stream: users,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text("Somethig went wrong");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  final data = snapshot.requireData;
                  final details = snapshot.data.toString();
                  print("I am here");
                  print(details);
                  return ListView.builder(
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        return Text(
                            'My name is ${data.docs[index]['name']}  and I am ${data.docs[index]['age']}');
                      });
                },
              ),
            ),
            Text(
              'Write data to cloud firestore',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            MyCutomeForm(),
          ],
        ),
      ),
    );
  }
}

class MyCutomeForm extends StatefulWidget {
  @override
  _MyCutomeFormState createState() => _MyCutomeFormState();
}

class _MyCutomeFormState extends State<MyCutomeForm> {
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController pincontroller = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  phoneAuth() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phonecontroller.text,
      timeout: Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        var result = await _auth.signInWithCredential(credential);
        User user = result.user;
        if (user != null) {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => HomeScreen()));
        }
      },
      verificationFailed: (FirebaseAuthException excption) {
        print(excption);
      },
      codeSent: (String verificationID, int resendToken) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Enter the code'),
                content: Column(
                  children: [
                    TextField(
                      controller: pincontroller,
                    ),
                    RaisedButton(onPressed: () async {
                      var smscode = pincontroller.text;
                      PhoneAuthCredential phoneAuthCredential =
                          PhoneAuthProvider.credential(
                              verificationId: verificationID, smsCode: smscode);
                      var result =
                          await _auth.signInWithCredential(phoneAuthCredential);
                      User user = result.user;
                      if (user != null) {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => HomePage()));
                      }
                    })
                  ],
                ),
              );
            });
      },
      codeAutoRetrievalTimeout: (String verificationID) {},
    );
  }

  final _formKey = GlobalKey<FormState>();
  var name = '';
  int age = 0;
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> usersd =
        FirebaseFirestore.instance.collection('users').snapshots();
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField(
            //   // controller: phonecontroller,
            //   decoration: InputDecoration(labelText: "Name"),
            //   // onChanged: (value) {
            //   //   name = value;
            //   // },
            //   // validator: (value) {
            //   //   if (value == null || value.isEmpty) {
            //   //     return 'Please enter some text';
            //   //   }
            //   //   return null;
            //   // },
            // ),
            TextField(
              controller: phonecontroller,
              decoration: InputDecoration(
                  labelText: "Phone Number",
                  enabledBorder: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              // onChanged: (value) {
              //   age = int.parse(value);
              // },
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return 'Please enter some text';
              //   }
              //   return null;
              // },
            ),
            SizedBox(
              height: 10,
            ),
            // Container(
            //   child: StreamBuilder<QuerySnapshot>(
            //     stream: usersd,
            //     builder: (BuildContext context,
            //         AsyncSnapshot<QuerySnapshot> snapshot) {
            //       // if (snapshot.hasError) {
            //       //   return Text("Somethig went wrong");
            //       // }
            //       // if (snapshot.connectionState == ConnectionState.waiting) {
            //       //   return Text("Loading");
            //       // }

            //       final data = snapshot.requireData;
            //       final details = data.docs[1]['name'];
            //       print("I am here");
            //       // print(details);
            //       for (int i = 0; i < data.size; i++) {
            //         if (!(data.docs[i]['name'] == 'asif')) {
            //           print('imran');
            //         }
            //       }
            //       return Text("");

            //       // return ListView.builder(
            //       //     itemCount: data.size,
            //       //     itemBuilder: (context, index) {
            //       //       return Text(
            //       //           // 'My name is ${data.docs[index]['name']}  and I am ${data.docs[index]['age']}');
            //       //     });
            //     },
            //   ),
            // ),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    phoneAuth();
                  },
                  child: Text("Submit")),
            )
          ],
        ),
      ),
    );
  }
}
