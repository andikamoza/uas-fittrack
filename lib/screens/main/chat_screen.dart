import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? selectedCoach;
  String? selectedCoachId;

  final List<Map<String, String>> coaches = [
    {
      'id': 'coach_anna',
      'name': 'Coach Anna',
      'gender': 'Female',
      'avatar': 'assets/images/female_coach.png'
    },
    {
      'id': 'coach_ben',
      'name': 'Coach Ben',
      'gender': 'Male',
      'avatar': 'assets/images/male_coach.png'
    },
  ];

  final TextEditingController _controller = TextEditingController();

  void sendMessage() async {
    if (_controller.text.trim().isEmpty || selectedCoachId == null) return;

    final messageText = _controller.text.trim();
    _controller.clear();

    final messagesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('chats')
        .doc(selectedCoachId)
        .collection('messages');

    await messagesRef.add({
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'sender': user!.uid,
    });

    Future.delayed(const Duration(seconds: 1), () async {
      String replyText = getAutoReply(messageText);
      await messagesRef.add({
        'text': replyText,
        'timestamp': FieldValue.serverTimestamp(),
        'sender': selectedCoachId,
      });
    });
  }

  String getAutoReply(String userMessage) {
    userMessage = userMessage.toLowerCase();
    if (userMessage.contains('hello') || userMessage.contains('hi')) {
      return 'Hi there! How can I help you today?';
    } else if (userMessage.contains('diet')) {
      return 'I recommend a balanced diet. Would you like a sample meal plan?';
    } else if (userMessage.contains('workout')) {
      return 'Let’s get moving! I have a few exercises for you.';
    } else {
      return 'Thank you for your message! I will get back to you shortly.';
    }
  }

  Stream<QuerySnapshot> getMessagesStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('chats')
        .doc(selectedCoachId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Widget buildCoachList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select Your Coach",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coaches.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final coach = coaches[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCoach = coach['name'];
                    selectedCoachId = coach['id'];
                  });
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(coach['avatar']!),
                        radius: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(coach['name']!,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(coach['gender']!,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildChatMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: getMessagesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final isMe = data['sender'] == user!.uid;

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue[100] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(data['text'] ?? ''),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
              const InputDecoration(hintText: 'Type a message...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }

  Widget buildChatHeader() {
    final coach = coaches.firstWhere((c) => c['id'] == selectedCoachId);
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue[50],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                selectedCoach = null;
                selectedCoachId = null;
              });
            },
          ),
          CircleAvatar(
            backgroundImage: AssetImage(coach['avatar']!),
            radius: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(coach['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Ask about: diet, workout',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Chat Coach", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: selectedCoach == null
            ? buildCoachList()
            : Column(
          children: [
            buildChatHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: buildChatMessages(),
              ),
            ),
            const SizedBox(height: 8),
            buildMessageInput(),
          ],
        ),
      ),
    );
  }
}
