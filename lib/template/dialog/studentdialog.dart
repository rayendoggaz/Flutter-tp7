import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../entities/student.dart';
import '../../service/studentservice.dart';

class AddStudentDialog extends StatefulWidget {
  final Student? student; // Nullable to differentiate between add/update
  final Function? notifyParent; // Callback to refresh parent UI

  const AddStudentDialog({Key? key, this.student, this.notifyParent}) : super(key: key);

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  String title = "Ajouter Etudiant";
  bool modif = false;

  TextEditingController nomCtrl = TextEditingController();
  TextEditingController prenomCtrl = TextEditingController();
  TextEditingController dateCtrl = TextEditingController();

  int? idStudent; // Used for updates
  int? selectedClassId; // Changed to int instead of String
  List<dynamic> classes = []; // List of classes

  @override
  void initState() {
    super.initState();
    fetchClasses();

    if (widget.student != null) {
      modif = true;
      title = "Modifier Etudiant";
      nomCtrl.text = widget.student!.nom;
      prenomCtrl.text = widget.student!.prenom;
      dateCtrl.text = DateFormat("yyyy-MM-dd").format(DateTime.parse(widget.student!.dateNais));
      idStudent = widget.student!.id;
      selectedClassId = int.tryParse(widget.student!.classId.toString()); // Ensure this is an integer
    }
  }

  Future<void> fetchClasses() async {
    try {
      final response = await getAllClasses();
      if (response is List) {
        classes = response; // Assign the list directly
      } else {
        print("Unexpected response format: $response");
        classes = []; // Fallback to an empty list
      }
    } catch (error) {
      print("Error fetching classes: $error");
      classes = []; // Handle network issues
    }
    setState(() {}); // Refresh UI after updating classes
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomCtrl,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: prenomCtrl,
              decoration: const InputDecoration(labelText: "Prenom"),
            ),
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(labelText: "Date de Naissance"),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    dateCtrl.text = DateFormat("yyyy-MM-dd").format(pickedDate);
                  });
                }
              },
            ),
            DropdownButtonFormField<int>(
              value: selectedClassId,
              decoration: const InputDecoration(labelText: "Class"),
              items: classes.map<DropdownMenuItem<int>>((classItem) {
                return DropdownMenuItem<int>(
                  value: int.tryParse(classItem['codClass'].toString()), // Parse as int
                  child: Text(classItem['nomClass']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClassId = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (!modif) {
              await addStudent(Student(
                dateCtrl.text,
                nomCtrl.text,
                prenomCtrl.text,
                classId: selectedClassId,
              ));
            } else {
              await updateStudent(Student(
                dateCtrl.text,
                nomCtrl.text,
                prenomCtrl.text,
                id: idStudent,
                classId: selectedClassId,
              ));
            }
            widget.notifyParent?.call();
            Navigator.pop(context);
          },
          child: Text(modif ? "Modifier" : "Ajouter"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Annuler"),
        ),
      ],
    );
  }
}
