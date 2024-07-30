import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/goal_provider.dart';
import '../providers/auth_provider.dart';
import 'goal_students_screen.dart';

class GoalsScreen extends StatefulWidget {
  final String? classId;

  GoalsScreen({this.classId});

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.userType == 'teacher' && widget.classId != null) {
        goalProvider.fetchTeacherClassGoals(widget.classId!);
      } else if (authProvider.userType == 'student') {
        goalProvider.fetchStudentGoals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return DefaultTabController(
      length: authProvider.userType == 'student' ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.classId != null ? 'Class Goals' : 'Goals'),
          bottom: authProvider.userType == 'student'
              ? TabBar(
                  tabs: [
                    Tab(text: 'Personal Goals'),
                    Tab(text: 'Class Goals'),
                  ],
                )
              : null,
        ),
        body: authProvider.userType == 'student'
            ? TabBarView(
                children: [
                  _buildGoalList(goalProvider.personalGoals, authProvider,
                      isPersonal: true),
                  _buildGoalList(goalProvider.classGoals, authProvider,
                      isPersonal: false),
                ],
              )
            : _buildGoalList(goalProvider.classGoals, authProvider,
                isPersonal: false),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddGoalDialog(
                isPersonal: authProvider.userType == 'student' &&
                    widget.classId == null,
                classId: widget.classId,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoalList(
      List<Map<String, dynamic>> goals, AuthProvider authProvider,
      {required bool isPersonal}) {
    return ListView.builder(
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final deadline = DateTime.parse(goal['deadline']);
        final isOverdue = goal['is_overdue'] ?? false;

        return ListTile(
          title: Text(goal['title']),
          subtitle: Text(
            'Deadline: ${DateFormat('MMM d, y HH:mm').format(deadline)}',
            style: TextStyle(color: isOverdue ? Colors.red : null),
          ),
          trailing: authProvider.userType == 'student'
              ? Checkbox(
                  value: goal['is_completed'],
                  onChanged: (bool? value) {
                    Provider.of<GoalProvider>(context, listen: false).updateGoal(
                      goal['id'].toString(),
                      {'is_completed': value},
                      isPersonal: isPersonal,
                    );
                  },
                )
              : Icon(Icons.arrow_forward_ios),
          onTap: () {
            if (authProvider.userType == 'teacher') {
              showDialog(
                context: context,
                builder: (context) =>
                    GoalActionDialog(goal: goal, classId: widget.classId),
              );
            } else {
              showDialog(
                context: context,
                builder: (context) => EditGoalDialog(goal: goal, isPersonal: isPersonal),
              );
            }
          },
        );
      },
    );
  }
}

class GoalActionDialog extends StatelessWidget {
  final Map<String, dynamic> goal;
  final String? classId;

  GoalActionDialog({required this.goal, this.classId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Goal Actions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            child: const Text('Edit Goal'),
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) =>
                    EditGoalDialog(goal: goal, isPersonal: false),
              );
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            child: Text('View Student Progress'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalStudentsScreen(
                      goalId: goal['id'].toString(), classId: classId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AddGoalDialog extends StatefulWidget {
  final bool isPersonal;
  final String? classId;

  AddGoalDialog({required this.isPersonal, this.classId});

  @override
  _AddGoalDialogState createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  DateTime _deadline = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isPersonal ? 'Add Personal Goal' : 'Add Class Goal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null,
              onSaved: (value) => _title = value!,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Select Date'),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _deadline = date);
                }
              },
            ),
            SizedBox(height: 8),
            ElevatedButton(
              child: Text('Select Time'),
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (time != null) {
                  setState(() => _time = time);
                }
              },
            ),
            SizedBox(height: 16),
            Text(
                'Selected: ${DateFormat('MMM d, y HH:mm').format(_deadline.add(Duration(hours: _time.hour, minutes: _time.minute)))}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Add'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final deadline = DateTime(
                _deadline.year,
                _deadline.month,
                _deadline.day,
                _time.hour,
                _time.minute,
              );
              final goal = {
                'title': _title,
                'deadline': deadline.toIso8601String(),
              };

              final goalProvider =
                  Provider.of<GoalProvider>(context, listen: false);
              if (widget.isPersonal) {
                goalProvider.addPersonalGoal(goal);
              } else {
                goalProvider.addClassGoal(widget.classId!, goal);
              }

              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

class EditGoalDialog extends StatefulWidget {
  final Map<String, dynamic> goal;
  final bool isPersonal;

  EditGoalDialog({required this.goal, required this.isPersonal});

  @override
  _EditGoalDialogState createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late DateTime _deadline;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _title = widget.goal['title'];
    _deadline = DateTime.parse(widget.goal['deadline']);
    _time = TimeOfDay.fromDateTime(_deadline);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Goal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _title,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null,
              onSaved: (value) => _title = value!,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Select Date'),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _deadline = date);
                }
              },
            ),
            SizedBox(height: 8),
            ElevatedButton(
              child: Text('Select Time'),
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (time != null) {
                  setState(() => _time = time);
                }
              },
            ),
            SizedBox(height: 16),
            Text(
                'Selected: ${DateFormat('MMM d, y HH:mm').format(_deadline.add(Duration(hours: _time.hour, minutes: _time.minute)))}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final deadline = DateTime(
                _deadline.year,
                _deadline.month,
                _deadline.day,
                _time.hour,
                _time.minute,
              );
              final updatedGoal = {
                ...widget.goal,
                'title': _title,
                'deadline': deadline.toIso8601String(),
              };
              Provider.of<GoalProvider>(context, listen: false).updateGoal(
                widget.goal['id'].toString(),
                updatedGoal,
                isPersonal: widget.isPersonal,
              );
              Navigator.of(context).pop();
            }
          },
        ),
        TextButton(
          child: const Text('Delete'),
          onPressed: () {
            Navigator.of(context).pop();
            Provider.of<GoalProvider>(context, listen: false).deleteGoal(
              widget.goal['id'].toString(),
              isPersonal: widget.isPersonal,
            );
          },
        ),
      ],
    );
  }
}
