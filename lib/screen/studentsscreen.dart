import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:tp70/entities/student.dart';
import 'package:tp70/service/studentservice.dart';
import 'package:tp70/template/navbar.dart';
import '../template/dialog/studentdialog.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  String? selectedClass; // Selected class ID
  List<dynamic> classes = []; // List to store all classes
  List<dynamic> students = []; // List to store all students
  bool isLoadingClasses = true;  // Loading state for classes
  bool isLoadingStudents = true; // Loading state for students

  @override
  void initState() {
    super.initState();
    fetchClasses(); // Fetch all classes
    fetchStudents(); // Fetch all students initially (no filter)
  }

  // Fetch all classes from the backend
  Future<void> fetchClasses() async {
    try {
      classes = await getAllClasses(); // Fetch the classes from backend
      setState(() {
        isLoadingClasses = false; // Set loading state to false after classes are fetched
      });
    } catch (error) {
      setState(() {
        isLoadingClasses = false;
      });
      print("Error fetching classes: $error");
    }
  }

  // Fetch students based on the selected class (if any)
  Future<void> fetchStudents() async {
    setState(() {
      isLoadingStudents = true; // Set loading state to true before fetching students
    });

    try {
      // If a class is selected, fetch students for that class; else fetch all students
      students = await fetchStudentsByClass(selectedClass); // Use the fetch function that takes class ID
      setState(() {
        isLoadingStudents = false; // Set loading state to false after students are fetched
      });
    } catch (error) {
      setState(() {
        isLoadingStudents = false;
      });
      print("Error fetching students: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar('Etudiant'),
      body: Column(
        children: [
          // Dropdown to select a class
          isLoadingClasses
              ? CircularProgressIndicator() // Loading indicator if classes are loading
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: InputDecoration(
                labelText: "Select Class",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.purpleAccent,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              hint: Text("Select Class"),
              items: classes.map<DropdownMenuItem<String>>((classItem) {
                return DropdownMenuItem<String>(
                  value: classItem['codClass']?.toString() ?? '', // Handle null class ID
                  child: Text(
                    classItem['nomClass'] ?? 'Unknown', // Display class name
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClass = value?.isEmpty ?? true ? null : value;
                  fetchStudents(); // Fetch students based on the selected class
                });
              },
            ),
          ),
          isLoadingStudents
              ? Expanded(child: Center(child: CircularProgressIndicator())) // Loading indicator if students are loading
              : Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: students.length,
              itemBuilder: (BuildContext context, int index) {
                var student = students[index];
                return Slidable(
                  key: Key(student['id'].toString()),
                  startActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddStudentDialog(
                                notifyParent: fetchStudents,
                                student: Student(
                                  student['dateNais'],
                                  student['nom'],
                                  student['prenom'],
                                  student['id'],
                                ),
                              );
                            },
                          );
                        },
                        backgroundColor: Color(0xFF21B7CA),
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    dismissible: DismissiblePane(onDismissed: () async {
                      await deleteStudent(student['id']); // Call delete API
                      fetchStudents(); // Refresh student list after deletion
                    }),
                    children: [Container()],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text("Nom et Prénom : "),
                                Text(
                                  student['nom'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 2.0),
                                Text(student['prenom']),
                              ],
                            ),
                            Text(
                              'Date de Naissance : ' + DateFormat("dd-MM-yyyy").format(DateTime.parse(student['dateNais'])),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purpleAccent,
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddStudentDialog(
                notifyParent: fetchStudents,
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
