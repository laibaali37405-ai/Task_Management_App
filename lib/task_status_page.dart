import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:intl/intl.dart';

class TaskStatusPage extends StatelessWidget {
  final String statusTitle;

  const TaskStatusPage({super.key, required this.statusTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/assets2.png", fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),

                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('tasks')
                        .where(
                          'uid',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                        )
                        .where('status', isEqualTo: statusTitle)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No tasks in $statusTitle status!",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var task = docs[index];

                          return _buildTaskTile(task);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(QueryDocumentSnapshot task) {
    DateTime date = (task['dueDate'] as Timestamp).toDate();

    String formattedDate = DateFormat('dd MMM').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),

      child: Row(
        children: [
          Icon(
            statusTitle == "Complete" ? Icons.check_circle : Icons.sync,
            color: statusTitle == "Complete" ? Colors.green : Colors.orange,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,

                    decoration: statusTitle == "Complete"
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),

                Text(
                  "Due: $formattedDate",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // IN PROGRESS → REVIEW
          if (statusTitle == "In Progress")
            IconButton(
              icon: const Icon(Icons.rate_review, color: Colors.orange),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(task.id)
                    .update({'status': 'In Review'});
              },
            ),

          // REVIEW → COMPLETE
          if (statusTitle == "In Review")
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.green),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(task.id)
                    .update({'status': 'Complete'});
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.deepPurple,
            ),
            onPressed: () => Navigator.pop(context),
          ),

          Text(
            statusTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
