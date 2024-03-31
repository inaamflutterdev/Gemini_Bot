// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  ChatUser mySelf = ChatUser(id: '1', firstName: 'Inaam');
  ChatUser bot = ChatUser(id: '2', firstName: 'Inaam');

  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];
  final ourUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyAYhMtEqH0L_RBdsYH_q3FtBNYWaDu9Cf4';
  final header = {'Content-Type': 'application/json'};

  getdata(ChatMessage m) async {
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});

    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };

    await http
        .post(Uri.parse(ourUrl), headers: header, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        print(result['candidates'][0]['content']['parts'][0]['text']);

        ChatMessage m1 = ChatMessage(
            text: result['candidates'][0]['content']['parts'][0]['text'],
            user: bot,
            createdAt: DateTime.now());
        allMessages.insert(0, m1);
      } else {
        print('Error Occured');
      }
    }).catchError((e) {});
    typing.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: DashChat(
          typingUsers: typing,
          currentUser: mySelf,
          onSend: (ChatMessage m) {
            getdata(m);
          },
          messages: allMessages,
        ),
      ),
    );
  }
}
