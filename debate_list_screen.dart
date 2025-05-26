import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebateListScreen extends StatelessWidget {
  final _topicController = TextEditingController();

  void _createDebate(BuildContext context) async {
    await FirebaseFirestore.instance.collection('debates').add({
      'topic': _topicController.text,
      'proUserId': '',
      'conUserId': '',
      'status': 'waiting',
    });
    _topicController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debates')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _topicController,
                    decoration: InputDecoration(hintText: 'New Debate Topic'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _createDebate(context),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('debates').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['topic']),
                      subtitle: Text('Status: ${doc['status']}'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}