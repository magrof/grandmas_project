class PlantDisease {
  final int? id;
  final String name; //Name of sickness
  final String symptoms; //Symptoms
  final String treatment; //Recovery treatment
  final String imageUrl; //URL of image


  PlantDisease({
    this.id,
    required this.name,
    required this.symptoms,
    required this.treatment,
    required this.imageUrl,
  });
  //Object to MAP method
  Map<String, dynamic> toMap (){
    return {
      'id': id,
      'name': name,
      'symptoms': symptoms,
      'treatment': treatment,
      'imageUrl': imageUrl,
    };
  }
  factory
      PlantDisease.fromMap(Map<String, dynamic> map){
    return PlantDisease(
      id: map['id'],
      name: map['name'],
      symptoms: map['symptoms'],
      treatment: map['treatment'],
      imageUrl: map['imageUrl'],
    );
  }
}