import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

class Auth {
  Future<FirebaseUser> handleSignInEmail(String email, String password) async {
    var user =
        await auth.signInWithEmailAndPassword(email: email, password: password);

    assert(user != null);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await auth.currentUser();
    assert(user.uid == currentUser.uid);

    print('signInEmail succeeded: $user');

    return user;
  }

  Future<FirebaseUser> handleSignUp(email, password) async {
    var user = await auth.createUserWithEmailAndPassword(
        email: email, password: password);

    assert(user != null);
    assert(await user.getIdToken() != null);

    return user;
  }

  Future<FirebaseUser> handleSignInAnonymously() async {
    var user = await auth.signInAnonymously();
    assert(user != null);
    assert(await user.getIdToken() != null);

    return user;
  }

  Future<FirebaseUser> getUser() async {
    var user = await auth.currentUser();
    return user;
  }

  Future<bool> logout() async {
    await auth.signOut();
    return true;
  }
}
