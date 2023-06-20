import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventura/back/director.dart';
import 'package:inventura/back/person.dart';
import 'package:inventura/back/manager.dart';
import 'package:inventura/back/worker.dart';
import 'package:inventura/database/databaseFunctions.dart';
import 'package:inventura/services/enums/roleEnum.dart';
import 'package:inventura/services/exceptions/directorException.dart';
import 'package:inventura/services/extensions/roleExtension.dart';
import 'package:inventura/services/extensions/stringExtension.dart';

class AuthService {
  final FirebaseAuth _auth;
  Role? role;

  AuthService(this._auth);

  Stream<Person?> get authStateChanges => _auth.authStateChanges().map((user) => getPerson(user));

  Person? getPerson(User? user) {
    if (user == null) return null;
    if (this.role == null) this.role = user.displayName!.asRole;
    switch (this.role) {
      case Role.DIRECTOR:
        return Director(user.uid);
      case Role.MANAGER:
        return Manager(user.uid);
      default:
        return Worker(user.uid);
    }
  }

  Future<String> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "OK";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> signUp(String email, String password, String firstName, String lastName, Role role) async {
    try {
      if (role == Role.DIRECTOR && await DB.directorId() != null) {
        throw DirectorException();
      }
      this.role = role;
      User? user = (await _auth.createUserWithEmailAndPassword(email: email, password: password)).user;
      await user!.updateDisplayName(role.asString);
      await Person.createUser(user.uid, email, firstName, lastName, role);
      return "OK";
    } on FirebaseAuthException catch (e) {
      this.role = null;
      return e.message!;
    } catch (e) {
      this.role = null;
      return e.toString();
    }
  }

  Future<String> signOut() async {
    try {
      await _auth.signOut();
      role = null;
      return "OK";
    } on FirebaseAuthException catch (e) {
      return e.message!;
    } catch (e) {
      return e.toString();
    }
  }
}
