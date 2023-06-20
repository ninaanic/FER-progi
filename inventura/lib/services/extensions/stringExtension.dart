import 'package:inventura/services/enums/roleEnum.dart';

extension stringExt on String {
  Role get asRole => this == "Direktor"
      ? Role.DIRECTOR
      : this == "Šef skladišta"
          ? Role.MANAGER
          : Role.WORKER;
}
