import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(StudentDebateApp());
}

class StudentDebateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Debate',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DebateScreen(),
    );
  }
}

class DebateScreen extends StatefulWidget {
  @override
  _DebateScreenState createState() => _DebateScreenState();
}

class _DebateScreenState extends State<DebateScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  String? _selectedQuestionId;
  String? _selectedQuestionText;

  void _addQuestion(String text) async {
    if (text.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('questions').add({
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _questionController.clear();
  }

  void _addComment(String questionId, String text) async {
    if (text.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection('questions')
        .doc(questionId)
        .collection('comments')
        .add({
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Debate App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Raise a Question',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _addQuestion(_questionController.text),
                ),
              ),
            ),
            Divider(height: 30),
            Text("Questions", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('questions')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  final questions = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final doc = questions[index];
                      return ListTile(
                        title: Text(doc['text']),
                        trailing: Icon(Icons.question_answer),
                        onTap: () {
                          setState(() {
                            _selectedQuestionId = doc.id;
                            _selectedQuestionText = doc['text'];
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            if (_selectedQuestionId != null) ...[
              Divider(height: 30),
              Text(
                'Question: $_selectedQuestionText',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Add a Comment',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () =>
                        _addComment(_selectedQuestionId!, _commentController.text),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('questions')
                      .doc(_selectedQuestionId)
                      .collection('comments')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return Center(child: CircularProgressIndicator());

                    final comments = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          title: Text(comment['text']),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
