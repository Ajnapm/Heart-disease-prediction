import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:uuid/uuid.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: ChatPage(),
      );
}

class Background extends StatelessWidget {
  const Background({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [
            0.1,
            0.25,
            0.75,
            0.9,
          ],
          colors: [
            Color(0xffd2f6fc),
            Color(0xffd7f8e8),
            Color(0xfff0fff3),
            Color(0xff9df3c4),
          ],
        ),
      ),
      child: child,
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String error = "";
  List<types.Message> _messages = [];
  Map userDetails = {};
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  final _bot = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3bb',
  );

  int bot_msg_id = 100;

  types.Message message_from_bot(String msg) {
    bot_msg_id++;
    return types.TextMessage(
        id: '$bot_msg_id',
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: msg);
  }

  @override
  void initState() {
    super.initState();
    _messages.insert(
        0,
        message_from_bot(
            'Hello User, I am your disease prediction chatbot. Do you want to start the prediction?'));
  }

  Future<void> _sendUserInput() async {
    try {
      final response = await http.post(
        Uri.parse("http://172.17.5.184:5000/input"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userDetails),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        error = data.toString();
        setState(() {});
        print(data);
        setState(() {
          _messages.insert(
              0,
              message_from_bot(data['prediction'] == 'Presence'
                  ? 'You have heart disease. Please consult a doctor.'
                  : 'You do not have heart disease. Stay healthy!'));
        });
        _messages.insert(0,
        message_from_bot('Do you want to predict again?(yes/no)'), );
        msg_seq=0;
      } else {
        _messages.insert(
            0,
            message_from_bot(
                'An unexpected error occurred. Please try again later'));
      }
    } catch (e) {
      _messages.insert(0, message_from_bot('Unable to connect to server'));
    }
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    _addMessage(textMessage);
    (() async {
      Future.delayed(const Duration(milliseconds: 500), () {
        _addMessage(message_from_bot(getResponse(message.text)));
      });
    })();
  }

  int msg_seq = -3;

  String getResponse(String message) {
    switch (msg_seq) {
      case -3:
        if (message.toLowerCase().trim() == 'yes') {
          msg_seq++;
          return 'Great! Let us start the prediction.\nFirst measure your BP. Do you want to measure your BP now? Type "No" to enter BP manually';
        } else if (message.toLowerCase().trim() == 'no')
          return 'Okay! Let me know if you want to start the prediction by sending me a message saying "Yes"';
        else
          return 'Please enter a valid response(Yes / No).';
      case -2:
        if (message.toLowerCase().trim() == 'yes') {
          msg_seq += 2;
          ListenForBP();
          return 'Ok .Connect the BP sensor and click start. I am wait for the BP values';
        } else if (message.toLowerCase().trim() == 'no') {
          msg_seq++;
          return "Ok .Please enter your BP in mmHg";
        }
        return 'Please enter a valid response(Yes / No).';
      case -1:
        msg_seq += 2;
        userDetails['BP'] = int.parse(message);
        return "Ok,What is your age ?";
      case 0:
        return "I am wating for the BP values. Please wait for a moment.";
        // if (message.toLowerCase().trim() == 'yes') {
        //   msg_seq++;
        //   return 'Great! Let us start the prediction. Please provide the details. What is your age ?';
        // } else if (message.toLowerCase().trim() == 'no')
        //   return 'Okay! Let me know if you want to start the prediction by sending me a message saying "Yes"';
        // else
        //   return 'Please enter a valid response(Yes / No).';
      case 1:
        if (int.tryParse(message) == null) {
          return "Please enter a valid age (in years).";
        }
        if (int.parse(message) < 0 || int.parse(message) > 150) {
          return "Please enter a valid age (in years).";
        }
        msg_seq++;
        userDetails['Age'] = int.parse(message);
        return "What is your gender ?";
      case 2:
        if (!['male', 'female'].contains(message.toLowerCase().trim())) {
          return "Please enter a valid gender (Male / Female).";
        }
        msg_seq++;
        userDetails['Sex'] = message;
        return "Please describe your chest pain type ? (typical angina/ atypical angina/ non-anginal pain/ asymptomatic)";
      case 3:
        if (!['typical angina', 'atypical angina', 'non-anginal pain', 'asymptomatic'].contains(message.toLowerCase().trim())) {
          return "Please enter a valid chest pain type.";
        }
        msg_seq+=2;
        userDetails['Chest_pain_type'] = message;
        return "What is your cholestrol level ?(126-564mm/dl)";
        // return "What is your current Blood pressure ?(94-200mmHG)";
      // case 4:
      //   // if (int.tryParse(message) == null) {
      //   //   return "Please enter a valid BP.";
      //   // }
      //   //  if (int.parse(message) < 94|| int.parse(message) > 200) {
      //   //   return "Please enter a valid BP.";
      //   // }
      //   msg_seq++;
      //   userDetails['BP'] = int.parse(message);
        
      case 5:
        if (int.tryParse(message) == null) {
          return "Please enter a valid cholestrol level.";
        }
         if (int.parse(message) < 126|| int.parse(message) > 564) {
          return "Please enter a valid cholestrol level.";
        }
        msg_seq++;
        userDetails['Cholesterol'] = int.parse(message);
        return "What is your ECG result ?(normal/irregular/abnormal)";
      case 6:
        if (!['normal', 'irregular', 'abnormal'].contains(message.toLowerCase().trim())) {
          return "Please enter a valid ECG result.";
        }
        // if(userDetails['Max HR']!=null){
        //   msg_seq++;
        //   return "Do you have chest pain during exercise ?(yes/no)";
        // }
        msg_seq++;
        userDetails['EKG_results'] = message;
        return "What is your max Heart Rate value ?(71-202bpm)";
      case 7:
        if (int.tryParse(message) == null) {
          return "Please enter a valid max Heart Rate value.";
        }
         if (int.parse(message) < 71|| int.parse(message) > 202) {
          return "Please enter a valid max Heart Rate value.";
        }
        msg_seq++;
        userDetails['Max HR'] = int.parse(message);
        return "Do you have chest pain during exercise ?(yes/no)";
      case 8:
        if (!['yes', 'no'].contains(message.toLowerCase().trim())) {
          return "Please provide correct answer.";
        }
        msg_seq++;
        userDetails['Exercise_angina'] = message;
        return "What is your the ST depression value(0-6.2) ?";
      case 9:
        if (double.tryParse(message) == null) {
          return "Please enter a valid ST depresion.";
        }
        if (double.parse(message) < 0|| double.parse(message) > 6.2) {
          return "Please enter a valid ST Depression.";
        }
        msg_seq++;
        userDetails['ST_depression'] = double.parse(message);
        return "How many number of major coloured flurosopy are present in your blood (0-4)?";
      case 10:
        if (int.tryParse(message) == null) {
          return "Please enter a valid number of fluro vessels.";
        }
        if (int.parse(message) < 0|| int.parse(message) > 4) {
          return "Please enter a valid number of fluro vesssels.";
        }
        msg_seq++;
        userDetails['Number_of_vessels_fluro'] = int.parse(message);
        return "How is the blood flow to your heart?(normal/fixed defect/reversable defect)";
      case 11:
        if (!['normal', 'fixed defect', 'reversable defect'].contains(message.toLowerCase().trim())) {
          return "Please provide correct information.";
        }
        msg_seq++;
        userDetails['Thallium'] = message;
        return "Is your fasting blood sugar greater than 120?(yes/no)";
      case 12:
        if (!['yes', 'no'].contains(message.toLowerCase().trim())) {
          return "Please provide correct information.";
        }
        msg_seq++;
        userDetails['FBS_over_120'] = message;
        return "How was the slope of ST curve ?(horizontal slope/upsloping slope/downsloping slope)";
      case 13:
        if (!['horizontal slope', 'upsloping slope','downsloping slope'].contains(message.toLowerCase().trim())) {
          return "Please enter a valid slope.";
        }
        msg_seq++;
        userDetails['Slope_of_ST'] = message;
        _sendUserInput();
        return "Great . We are processing your details. Please wait for a moment.";

      default:
        return "Sorry, some unexpected error occured .Please try again";
    }
  }
  
  void  ListenForBP() {
    print("-------------Started listening for values-------------");
    final firebaseApp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://sign-main-default-rtdb.firebaseio.com/');
    DatabaseReference starCountRef = rtdb.ref('bp');
    StreamSubscription<DatabaseEvent>? listener = null;
    listener = starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data == null) return;
      msg_seq = 1;
      if (data is Map && data["result"] != null) {
        _addMessage(message_from_bot(
            "BP values recieved ${data["result"]}.\n What is your age ?"));
        userDetails['BP'] = int.parse((data["result"] as String).split(",")[0]);
        //userDetails['Max HR'] = int.parse((data["result"] as String).split(",")[2]);
      } else {
        msg_seq = -1;
        _addMessage(message_from_bot(
            "Error reading BP try entering manually.\nPlease enter your BP (systolic,diastolic) in mmHg"));
      }

      listener?.cancel();
      starCountRef.remove();
      print("-------------Ended listening for values-------------");
    });
  }


  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Messenger"),
        ),
        body: Background(
          child: Chat(
            messages: _messages,
            onSendPressed: _handleSendPressed,
            showUserAvatars: true,
            showUserNames: true,
            user: _user,
            theme: const DefaultChatTheme(
              seenIcon: Text(
                'read',
                style: TextStyle(
                  fontSize: 10.0,
                ),
              ),
            ),
          ),
        ),
      );
}




// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:uuid/uuid.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// void main() {
//   initializeDateFormatting().then((_) => runApp(const MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) => const MaterialApp(
//         home: ChatPage(),
//       );
// }

// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   String error="";
//   List<types.Message> _messages = [];
//   Map userDetails = {};
//   final _user = const types.User(
//     id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
//   );

//   final _bot = const types.User(
//     id: '82091008-a484-4a89-ae75-a22bf8d6f3bb',
//   );

//   int bot_msg_id = 100;
//   types.Message message_from_bot(String msg) {
//     bot_msg_id++;
//     return types.TextMessage(
//         id: '$bot_msg_id',
//         author: _bot,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         text: msg);
//   }


//   @override
//   void initState() {
//     super.initState();
//     _messages.insert(
//         0,
//         message_from_bot(
//             'Hello User, I am your disease prediction chatbot. Do you want to start the prediction?'));
//   }

//   Future<void> _sendUserInput() async {
//     try {
//       final response = await http.post(
//         Uri.parse("http://192.168.235.254:5000/input"),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(userDetails),
//       );

//       if (response.statusCode == 200) {
//         Map<String, dynamic> data = jsonDecode(response.body);
//         error=data.toString();
//         setState(() {});
//         print(data);
//         // print("hkjlkjkljk");
//         setState(() {
//           _messages.insert(
//               0,
//               message_from_bot(data['prediction'] == 1
//                   ? 'You have heart disease. Please consult a doctor.'
//                   : 'You do not have heart disease. Stay healthy!'));
//         });
//       } else {
//         _messages.insert(
//             0,
//             message_from_bot(
//                 'An unexpected error occurred. Please try again later'));
//       }
//     } catch (e) {
//       _messages.insert(0, message_from_bot('Unable to connect to server'));
//     }
//   }

//   void _addMessage(types.Message message) {
//     setState(() {
//       _messages.insert(0, message);
//     });
//   }

//   void _handleAttachmentPressed() {
//     showModalBottomSheet<void>(
//       context: context,
//       builder: (BuildContext context) => SafeArea(
//         child: SizedBox(
//           height: 144,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   // _handleImageSelection();
//                 },
//                 child: const Align(
//                   alignment: AlignmentDirectional.centerStart,
//                   child: Text('Photo'),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   // _handleFileSelection();
//                 },
//                 child: const Align(
//                   alignment: AlignmentDirectional.centerStart,
//                   child: Text('File'),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Align(
//                   alignment: AlignmentDirectional.centerStart,
//                   child: Text('Cancel'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleSendPressed(types.PartialText message) {
//     final textMessage = types.TextMessage(
//       author: _user,
//       createdAt: DateTime.now().millisecondsSinceEpoch,
//       id: const Uuid().v4(),
//       text: message.text,
//     );
//     _addMessage(textMessage);
//     (() async {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         _addMessage(message_from_bot(getResponse(message.text)));
//       });
//     })();
//   }

//   int msg_seq = 0;
//   String getResponse(String message) {
//     switch (msg_seq) {
//       case 0:
//         if (message.toLowerCase().trim() == 'yes') {
//           msg_seq++;
//           return 'Great! Let us start the prediction. Please provide the details. What is your age ?';
//         } else if (message.toLowerCase().trim() == 'no')
//           return 'Okay! Let me know if you want to start the prediction by sending me a message saying "Yes"';
//         else
//           return 'Please enter a valid response(Yes / No).';
//       case 1:
//         if (int.tryParse(message) == null) {
//           return "Please enter a valid age (in years).";
//         }
//         if (int.parse(message) < 0 || int.parse(message) > 150) {
//           return "Please enter a valid age (in years).";
//         }
//         msg_seq++;
//         userDetails['Age'] = int.parse(message);
//         return "What is your gender ?";
//       case 2:
//         msg_seq++;
//         userDetails['Sex'] = message;
//         return "Please describe your chest pain type ? (typical angina, atypical angina, non-anginal pain, asymptomatic)";
//       case 3:
//         msg_seq++;
//         userDetails['Chest_pain_type'] = message;
//         return "What is your current BP ?";
//       case 4:
//         msg_seq++;
//         userDetails['BP'] = int.parse(message);
//         return "What is your cholestrol level ?";
//       case 5:
//         msg_seq++;
//         userDetails['Cholesterol'] = int.parse(message);
//         return "What is your EKG result ?";
//       case 6:
//         msg_seq++;
//         userDetails['EKG_results'] = int.parse(message);
//         return "What is your max HR value ?";
//       case 7:
//         msg_seq++;
//         userDetails['Max HR'] = int.parse(message);
//         return "What is your exercise angina value ?";
//       case 8:
//         msg_seq++;
//         userDetails['Exercise_angina'] = int.parse(message);
//         return "What is your the slope of st ?";
//       case 9:
//         msg_seq++;
//         userDetails['Slope_of_ST'] = double.parse(message);
//         return "What is the number of fluro vessels in your blood ?";
//       case 10:
//         msg_seq++;
//         userDetails['Number_of_vessels_fluro'] = int.parse(message);
//         return "What is your thalium count?";
//       case 11:
//         msg_seq++;
//         userDetails['Thallium'] = int.parse(message);
//         return "What is your fasting blood sugar count?";
//       case 12:
//         msg_seq++;
//         userDetails['FBS_over_120'] = int.parse(message);
//         return "What is your ST depression ?";
//       case 13:
//         msg_seq++;
//         userDetails['ST_depression'] = int.parse(message);
//         _sendUserInput();
//         return "Great . We are processing your details. Please wait for a moment.";

//       default:
//         return "Sorry, some unexpected error occured .Please try again";
//     }
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: Text("Messenger"),),
//         body: Chat(
//           messages: _messages,
//           onSendPressed: _handleSendPressed,
//           showUserAvatars: true,
//           showUserNames: true,
//           user: _user,
//           theme: const DefaultChatTheme(
//             seenIcon: Text('read',
//                 style: TextStyle(
//                   fontSize: 10.0,
//                 )),
//           ),
//         ),
//       );
// }



// // class Background extends StatelessWidget {
// //   const Background({Key? key, required this.child}) : super(key: key);

// //   final Widget child;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.topRight,
// //           end: Alignment.bottomLeft,
// //           stops: [
// //             0.1,
// //             0.25,
// //             0.75,
// //             0.9,
// //           ],
// //           colors: [
// //             Color(0xffd2f6fc),
// //             Color(0xffd7f8e8),
// //             Color(0xfff0fff3),
// //             Color(0xff9df3c4),
// //           ],
// //         ),
// //       ),
// //       child: child,
// //     );
// //   }
// // }

