class Student {
  String dateNais;
  String nom;
  String prenom;
  int? id; // Nullable for new students
  int? classId; // Nullable to allow no class assignment initially

  Student(this.dateNais, this.nom, this.prenom, {this.id, this.classId});
}
