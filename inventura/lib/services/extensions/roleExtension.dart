import 'package:inventura/services/enums/roleEnum.dart';

extension roleExtension on Role {
  String get asString => this == Role.DIRECTOR
      ? "Direktor"
      : this == Role.MANAGER
          ? "Šef skladišta"
          : "Skladištar";
}
