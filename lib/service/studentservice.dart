import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:tp70/entities/student.dart';

Future<List<dynamic>> getAllStudent() async {
  Response response =
      await http.get(Uri.parse("http://10.0.2.2:8081/etudiant/all"));
  return List<dynamic>.from(jsonDecode(response.body));
}

Future deleteStudent(int id) {
  return http
      .delete(Uri.parse("http://10.0.2.2:8081/etudiant/delete?id=${id}"));
}

Future addStudent(Student student) async {
  final response = await http.post(
    Uri.parse("http://10.0.2.2:8081/etudiant/add"),
    headers: {"Content-type": "application/json"},
    body: jsonEncode({
      "nom": student.nom,
      "prenom": student.prenom,
      "dateNais": DateFormat("yyyy-MM-dd").format(DateTime.parse(student.dateNais)),
      "classId": student.classId,
    }),
  );
  return response.body;
}

Future updateStudent(Student student) async {
  final response = await http.put(
    Uri.parse("http://10.0.2.2:8081/etudiant/update"),
    headers: {"Content-type": "application/json"},
    body: jsonEncode({
      "id": student.id,
      "nom": student.nom,
      "prenom": student.prenom,
      "dateNais": DateFormat("yyyy-MM-dd").format(DateTime.parse(student.dateNais)),
      "classId": student.classId,
    }),
  );
  return response.body;
}

Future<List<dynamic>> getAllClasses() async {
  final response = await http.get(Uri.parse("http://10.0.2.2:8081/classes"));
  print("Classes Response: ${response.body}"); // Debug response

  // Decode the JSON response and extract the 'classes' list from the '_embedded' field
  final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
  final List<dynamic> classes = decodedResponse['_embedded']['classes'];

  return classes; // Return the classes list
}



Future<List<dynamic>> fetchStudentsByClass(String? classId) async {
  final url = classId == null
      ? "http://10.0.2.2:8081/etudiant/all"
      : "http://10.0.2.2:8081/etudiant/byClass?classeId=$classId";
  final response = await http.get(Uri.parse(url));
  return List<dynamic>.from(jsonDecode(response.body));
}


