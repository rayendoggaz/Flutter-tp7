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
  print(student.dateNais);
  Response response =
      await http.post(Uri.parse("http://10.0.2.2:8081/etudiant/add"),
          headers: {"Content-type": "Application/json"},
          body: jsonEncode(<String, String>{
            "nom": student.nom,
            "prenom": student.prenom,
            "dateNais": DateFormat("yyyy-MM-dd")
                .format(DateTime.parse(student.dateNais))
          }));
  return response.body;
}

Future updateStudent(Student student) async {
  Response response =
      await http.put(Uri.parse("http://10.0.2.2:8081/etudiant/update"),
          headers: {"Content-type": "Application/json"},
          body: jsonEncode(<String, dynamic>{
            "id": student.id,
            "nom": student.nom,
            "prenom": student.prenom,
            "dateNais": DateFormat("yyyy-MM-dd")
                .format(DateTime.parse(student.dateNais))
          }));
  return response.body;
}

Future<List<dynamic>> fetchStudentsByClass(String? classId) async {
  final url = classId == null
      ? "http://10.0.2.2:8081/etudiant/all"
      : "http://10.0.2.2:8081/etudiant/byClass?classeId=$classId";
  final response = await http.get(Uri.parse(url));
  return List<dynamic>.from(jsonDecode(response.body));
}

Future<List<dynamic>> getAllClasses() async {
  final url = "http://10.0.2.2:8081/classes"; // Correct URL for all classes
  try {
    final response = await http.get(Uri.parse(url));
    print("API Call URL: $url");
    print("API Response Status Code: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      // Decode the response body
      final Map<String, dynamic> data = jsonDecode(response.body);
      // Access the 'classes' list from the '_embedded' field
      final List<dynamic> classes = data["_embedded"]["classes"];
      print("Fetched Classes: $classes");
      return classes;
    } else {
      print("Error: Received status code ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("Exception: $e");
    return [];
  }
}
