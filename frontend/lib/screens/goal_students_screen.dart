import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';

class GoalStudentsScreen extends StatefulWidget {
  final String goalId;
  final String? classId;

  const GoalStudentsScreen({required this.goalId, this.classId});

  @override
  _GoalStudentsScreenState createState() => _GoalStudentsScreenState();
}

class _GoalStudentsScreenState extends State<GoalStudentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<GoalProvider>(context, listen: false)
          .fetchGoalStudents(widget.goalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Progress'),
      ),
      body: goalProvider.goalStudents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: goalProvider.goalStudents.length,
              itemBuilder: (context, index) {
                final student = goalProvider.goalStudents[index];
                return ListTile(
                  title: Text(student['username'] ?? 'Unknown'),
                  trailing: Icon(
                    student['is_completed'] == true
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: student['is_completed'] == true
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              },
            ),
    );
  }
}