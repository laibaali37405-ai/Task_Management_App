import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'todo_list_page.dart';
import 'task_status_page.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    String initial = user?.email?.substring(0, 1).toUpperCase() ?? "U";

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/images/assets2.png", fit: BoxFit.cover),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurple,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // HEADER
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi ${user?.email?.split('@')[0] ?? 'User'},",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const Text(
                            "Welcome back!",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.deepPurple,
                          size: 30,
                        ),
                        onPressed: () => FirebaseAuth.instance.signOut().then(
                          (_) => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // STATUS CARDS
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      // TO DO
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('tasks')
                            .where('uid', isEqualTo: user?.uid)
                            .where('status', isEqualTo: 'To-do')
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              int count = snapshot.hasData
                                  ? snapshot.data!.docs.length
                                  : 0;

                              return _buildStatusCard(
                                "To do list",
                                "$count tasks",
                                const Color(0xFFB39DDB).withOpacity(0.9),
                                Icons.list_alt_rounded,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TodoListPage(),
                                    ),
                                  );
                                },
                              );
                            },
                      ),

                      // IN PROGRESS
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('tasks')
                            .where('uid', isEqualTo: user?.uid)
                            .where('status', isEqualTo: 'In Progress')
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              int count = snapshot.hasData
                                  ? snapshot.data!.docs.length
                                  : 0;

                              return _buildStatusCard(
                                "In progress",
                                "$count tasks",
                                const Color(0xFFFFF59D).withOpacity(0.9),
                                Icons.sync,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TaskStatusPage(
                                            statusTitle: "In Progress",
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                      ),

                      // IN REVIEW
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('tasks')
                            .where('uid', isEqualTo: user?.uid)
                            .where('status', isEqualTo: 'In Review')
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              int count = snapshot.hasData
                                  ? snapshot.data!.docs.length
                                  : 0;

                              return _buildStatusCard(
                                "In review",
                                "$count tasks",
                                const Color(0xFFF48FB1).withOpacity(0.9),
                                Icons.rate_review_outlined,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TaskStatusPage(
                                            statusTitle: "In Review",
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                      ),

                      // COMPLETE
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('tasks')
                            .where('uid', isEqualTo: user?.uid)
                            .where('status', isEqualTo: 'Complete')
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              int count = snapshot.hasData
                                  ? snapshot.data!.docs.length
                                  : 0;

                              return _buildStatusCard(
                                "Complete",
                                "$count tasks",
                                const Color(0xFFA5D6A7).withOpacity(0.9),
                                Icons.check_circle_outline,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TaskStatusPage(
                                            statusTitle: "Complete",
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Analytics",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // GRAPH BUTTON
                  Material(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.1),

                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),

                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              backgroundColor: Colors.transparent,

                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('tasks')
                                    .where('uid', isEqualTo: user?.uid)
                                    .snapshots(),

                                builder: (context, snapshot) {
                                  int todo = 0;
                                  int progress = 0;
                                  int review = 0;
                                  int complete = 0;

                                  if (snapshot.hasData) {
                                    for (var doc in snapshot.data!.docs) {
                                      String status = doc['status'];

                                      if (status == 'To-do') {
                                        todo++;
                                      } else if (status == 'In Progress') {
                                        progress++;
                                      } else if (status == 'In Review') {
                                        review++;
                                      } else if (status == 'Complete') {
                                        complete++;
                                      }
                                    }
                                  }

                                  return Container(
                                    padding: const EdgeInsets.all(20),

                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),

                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        const Text(
                                          "Task Analytics",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 25),

                                        SizedBox(
                                          height: 300,

                                          child: BarChart(
                                            BarChartData(
                                              alignment:
                                                  BarChartAlignment.spaceAround,

                                              maxY: 10,

                                              gridData: const FlGridData(
                                                show: false,
                                              ),

                                              borderData: FlBorderData(
                                                show: false,
                                              ),

                                              titlesData: FlTitlesData(
                                                topTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),

                                                rightTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),

                                                leftTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                  ),
                                                ),

                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,

                                                    getTitlesWidget:
                                                        (value, meta) {
                                                          switch (value
                                                              .toInt()) {
                                                            case 0:
                                                              return const Text(
                                                                "Todo",
                                                              );

                                                            case 1:
                                                              return const Text(
                                                                "Progress",
                                                              );

                                                            case 2:
                                                              return const Text(
                                                                "Review",
                                                              );

                                                            case 3:
                                                              return const Text(
                                                                "Done",
                                                              );
                                                          }

                                                          return const Text("");
                                                        },
                                                  ),
                                                ),
                                              ),

                                              barGroups: [
                                                BarChartGroupData(
                                                  x: 0,

                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: todo.toDouble(),

                                                      color: Colors.deepPurple,

                                                      width: 22,

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ],
                                                ),

                                                BarChartGroupData(
                                                  x: 1,

                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: progress.toDouble(),

                                                      color: Colors.orange,

                                                      width: 22,

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ],
                                                ),

                                                BarChartGroupData(
                                                  x: 2,

                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: review.toDouble(),

                                                      color: Colors.pink,

                                                      width: 22,

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ],
                                                ),

                                                BarChartGroupData(
                                                  x: 3,

                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: complete.toDouble(),

                                                      color: Colors.green,

                                                      width: 22,

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },

                      child: Container(
                        width: double.infinity,
                        height: 250,
                        padding: const EdgeInsets.all(10),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),

                          child: Image.asset(
                            "assets/images/graph.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String count,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(25),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Container(
                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),

                  shape: BoxShape.circle,
                ),

                child: Icon(icon, color: Colors.black87, size: 22),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,

                      fontSize: 16,

                      color: Colors.black87,
                    ),
                  ),

                  Text(
                    count,

                    style: const TextStyle(
                      fontSize: 13,

                      color: Colors.black54,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
