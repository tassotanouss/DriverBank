import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';

class FirebaseBootstrapResult {
  FirebaseBootstrapResult({
    required this.isConfigured,
    this.errorMessage,
    this.technicalDetails,
  });

  final bool isConfigured;
  final String? errorMessage;
  final String? technicalDetails;

  static Future<FirebaseBootstrapResult> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      return FirebaseBootstrapResult(
        isConfigured: true,
      );
    } catch (e, stackTrace) {
      return FirebaseBootstrapResult(
        isConfigured: false,
        errorMessage:
            'Falta conectar este projeto ao seu projeto Firebase para a autenticação funcionar em produção.',
        technicalDetails: '$e\n\n$stackTrace',
      );
    }
  }
}