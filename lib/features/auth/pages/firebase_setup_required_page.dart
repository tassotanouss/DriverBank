import 'package:flutter/material.dart';

import '../../../core/widgets/form_section_card.dart';

class FirebaseSetupRequiredPage extends StatelessWidget {
  const FirebaseSetupRequiredPage({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('DriveProfit')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          FormSectionCard(
            title: 'Autenticação pronta para Firebase',
            subtitle:
                'O app já foi preparado para cadastro, login, reset de senha e sessão persistente.',
            icon: Icons.lock_open_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Falta conectar este projeto ao seu projeto Firebase para a autenticação funcionar em produção.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text('Passos pendentes:', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('1. Criar um projeto no Firebase Console.'),
                const Text(
                  '2. Ativar Email/Password em Authentication > Sign-in method.',
                ),
                const Text(
                  '3. Baixar e adicionar `google-services.json` em `android/app/`.',
                ),
                const Text(
                  '4. Baixar e adicionar `GoogleService-Info.plist` no projeto iOS, se for publicar no iPhone.',
                ),
                const Text(
                  '5. Trocar os identificadores padrão `com.example.app` por IDs reais do seu app.',
                ),
                if (errorMessage != null &&
                    errorMessage!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Detalhe técnico detectado:',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(errorMessage!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
