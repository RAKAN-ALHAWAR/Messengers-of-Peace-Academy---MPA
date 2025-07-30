import 'package:messengersofpeace/Data/data.dart';

class FormX {
  final String id;

  FormX({required this.id});

  Map<String, dynamic> toJson() {
    return {NameX.id: id};
  }
}
