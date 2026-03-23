import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  const AuthService();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseAuth? get _authOrNull {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  User? get currentUserOrNull => _authOrNull?.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null && displayName.trim().isNotEmpty) {
      await user.updateDisplayName(displayName.trim());
      await user.reload();
    }

    return credential;
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = currentUserOrNull;
    if (user == null) {
      return;
    }

    await user.updateDisplayName(displayName.trim());
    await user.reload();
  }

  Future<void> signOut() async {
    final auth = _authOrNull;
    if (auth == null) {
      return;
    }

    await auth.signOut();
  }
}

String mapAuthErrorMessage({
  required FirebaseAuthException exception,
  required String Function(String key, {Map<String, String> params}) translate,
}) {
  switch (exception.code) {
    case 'email-already-in-use':
      return translate('Esse e-mail já está em uso por outra conta.');
    case 'invalid-email':
      return translate('O e-mail informado é inválido.');
    case 'invalid-credential':
      return translate('E-mail ou senha inválidos.');
    case 'operation-not-allowed':
      return translate(
        'O provedor de login por e-mail ainda não foi ativado no Firebase.',
      );
    case 'too-many-requests':
      return translate(
        'Muitas tentativas seguidas. Aguarde alguns minutos e tente novamente.',
      );
    case 'user-disabled':
      return translate('Esta conta foi desativada.');
    case 'user-not-found':
      return translate('Não encontramos uma conta com esse e-mail.');
    case 'weak-password':
      return translate(
        'A senha está fraca demais. Use pelo menos 8 caracteres.',
      );
    case 'wrong-password':
      return translate('A senha informada está incorreta.');
    case 'network-request-failed':
      return translate(
        'Não foi possível conectar. Verifique sua internet e tente novamente.',
      );
    default:
      return translate(
        'Não foi possível concluir a autenticação agora. Tente novamente.',
      );
  }
}
