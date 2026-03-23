import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
    Locale('es', 'ES'),
  ];

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context.');
    return localizations!;
  }

  static String dateLocaleOf(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'en':
        return 'en_US';
      case 'es':
        return 'es_ES';
      default:
        return 'pt_BR';
    }
  }

  static String languageLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Português';
    }
  }

  String text(String original, {Map<String, String>? params}) {
    var value = _translations[locale.languageCode]?[original] ?? original;

    if (params != null) {
      params.forEach((placeholder, replacement) {
        value = value.replaceAll('{$placeholder}', replacement);
      });
    }

    return value;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'Idioma do aplicativo': 'App language',
      'Escolha o idioma usado em todas as telas do app.':
          'Choose the language used across the app.',
      'Você pode trocar o idioma antes de entrar.':
          'You can change the language before signing in.',
      'Criar conta': 'Create account',
      'Entrar': 'Sign in',
      'Entrar agora': 'Sign in now',
      'Já tem conta?': 'Already have an account?',
      'Ainda não tem conta?': "Don't have an account yet?",
      'Bem-vindo ao DriveProfit': 'Welcome to DriveProfit',
      'Preencha seus dados de acesso e deixe o cadastro pronto para uso no app.':
          'Fill in your access details and leave your account ready to use in the app.',
      'Nome completo': 'Full name',
      'Como você gostaria de ser identificado no app':
          'How you would like to be identified in the app',
      'E-mail de acesso': 'Access email',
      'nome@exemplo.com': 'name@example.com',
      'Esse e-mail será usado para entrar na conta.':
          'This email will be used to sign in.',
      'Celular com DDD': 'Phone number',
      'Use um número que você acompanhe com frequência.':
          'Use a number you check often.',
      'Como você se identifica': 'How do you identify yourself',
      'Campo usado apenas para personalização do perfil.':
          'Used only for profile personalization.',
      'Feminino': 'Female',
      'Masculino': 'Male',
      'Prefiro não informar': 'Prefer not to say',
      'Data de nascimento': 'Birth date',
      'DD/MM/AAAA': 'DD/MM/YYYY',
      'Segurança da conta': 'Account security',
      'Use uma senha forte para proteger seus dados e evitar acessos indevidos.':
          'Use a strong password to protect your data and avoid unauthorized access.',
      'Senha': 'Password',
      'Crie uma senha forte': 'Create a strong password',
      'Mínimo de 8 caracteres com letras, número e símbolo.':
          'At least 8 characters with letters, number, and symbol.',
      'Confirmação da senha': 'Confirm password',
      'Repita a senha criada acima': 'Repeat the password created above',
      'Criar conta e entrar': 'Create account and sign in',
      'Revise os campos obrigatórios': 'Review the required fields',
      'Algumas informações estão faltando ou precisam ser corrigidas antes de criar a conta.':
          'Some information is missing or needs to be corrected before creating the account.',
      'Cadastro duplicado': 'Duplicate registration',
      'Já existe uma conta cadastrada com esse e-mail neste aparelho. Entre com sua conta atual para continuar.':
          'There is already an account registered with this email on this device. Sign in with your current account to continue.',
      'Senhas diferentes': 'Passwords do not match',
      'A confirmação precisa ser igual à senha informada acima.':
          'The confirmation must match the password entered above.',
      'Conta criada com sucesso.': 'Account created successfully.',
      'Acesse sua conta': 'Access your account',
      'Use o mesmo e-mail e a mesma senha informados no cadastro para continuar.':
          'Use the same email and password entered during registration to continue.',
      'Digite o e-mail usado no cadastro.':
          'Enter the email used during sign-up.',
      'Sua senha de acesso': 'Your access password',
      'Entrar no aplicativo': 'Sign in to the app',
      'Revise seus dados': 'Review your information',
      'Confira o e-mail e a senha antes de continuar.':
          'Check your email and password before continuing.',
      'Conta ainda não cadastrada': 'Account not registered yet',
      'Crie sua conta primeiro para liberar o acesso ao aplicativo.':
          'Create your account first to unlock access to the app.',
      'Acesso não autorizado': 'Access denied',
      'O e-mail ou a senha informados não correspondem ao cadastro salvo.':
          'The email or password entered does not match the saved account.',
      'Login realizado com sucesso.': 'Signed in successfully.',
      'Dashboard': 'Dashboard',
      'Lançamentos': 'Entries',
      'Relatórios': 'Reports',
      'Metas': 'Goals',
      'Perfil': 'Profile',
      'Perfil e configurações': 'Profile and settings',
      'Motorista DriveProfit': 'DriveProfit driver',
      'Organize seus dados de acesso e suas preferências principais em um só lugar.':
          'Organize your access details and main preferences in one place.',
      'Dados da conta': 'Account information',
      'Essas informações ajudam a identificar o usuário e deixam o app mais pronto para uso comercial.':
          'This information helps identify the user and prepares the app for business use.',
      'Nome': 'Name',
      'Como você quer aparecer no app': 'How you want to appear in the app',
      'E-mail': 'Email',
      'Celular': 'Phone number',
      '(11) 99999-9999': '(555) 123-4567',
      'Moeda': 'Currency',
      'Define a preferência monetária salva para o perfil.':
          'Defines the currency preference saved for the profile.',
      'Data de início de uso': 'Start date',
      'Ainda não registrada': 'Not registered yet',
      'Salvar configurações': 'Save settings',
      'Informe o nome do usuário.': 'Enter the user name.',
      'Informe um celular para contato.': 'Enter a phone number for contact.',
      'Digite um número válido com DDD.':
          'Enter a valid phone number with area code.',
      'Confira nome, e-mail e celular antes de salvar as configurações.':
          'Check name, email, and phone number before saving settings.',
      'Configurações salvas': 'Settings saved',
      'Seu perfil foi atualizado com sucesso neste aparelho.':
          'Your profile was updated successfully on this device.',
      'Perfil atualizado com sucesso.': 'Profile updated successfully.',
      'Real brasileiro': 'Brazilian real',
      'Dolar americano': 'US dollar',
      'Euro': 'Euro',
      'Custos fixos': 'Fixed costs',
      'O app continua com a configuração detalhada na tela própria, mas você consegue acompanhar o resumo daqui.':
          'The app keeps the detailed setup on its own screen, but you can follow the summary from here.',
      'Total mensal: {value}': 'Monthly total: {value}',
      'Custo diário estimado: {value}':
          'Estimated daily cost: {value}',
      'Editar custos fixos': 'Edit fixed costs',
      'Sair da conta': 'Sign out',
      'Encerrar a sessão neste aparelho.': 'End the session on this device.',
      'Informe um e-mail para continuar.': 'Enter an email to continue.',
      'Digite um e-mail válido.': 'Enter a valid email.',
      'Crie uma senha para proteger sua conta.':
          'Create a password to protect your account.',
      'Use pelo menos 8 caracteres.': 'Use at least 8 characters.',
      'Inclua ao menos uma letra maiúscula.':
          'Include at least one uppercase letter.',
      'Inclua ao menos uma letra minúscula.':
          'Include at least one lowercase letter.',
      'Inclua ao menos um número.': 'Include at least one number.',
      'Inclua ao menos um caractere especial.':
          'Include at least one special character.',
      'Não use espaços na senha.': 'Do not use spaces in the password.',
      'Informe um valor para continuar.': 'Enter a value to continue.',
      'Digite um número válido.': 'Enter a valid number.',
      'Use um valor igual ou maior que zero.':
          'Use a value greater than or equal to zero.',
      'Preencha este campo.': 'Fill in this field.',
      'Digite um número inteiro válido.': 'Enter a valid whole number.',
      'Informe quanto tempo você trabalhou.':
          'Enter how long you worked.',
      'Use um horário válido no formato hh:mm.':
          'Use a valid time in hh:mm format.',
      'Meta: {value}': 'Goal: {value}',
      'Arrecadado: {value}': 'Collected: {value}',
      'Falta: {value}': 'Remaining: {value}',
      '{value}% da meta': '{value}% of the goal',
      'Meta batida': 'Goal reached',
      'Meta ainda não atingida': 'Goal not reached yet',
      'Custos fixos restantes no mês': 'Fixed costs remaining this month',
      '{covered} de {total} já cobertos':
          '{covered} of {total} already covered',
      'Média diária necessária neste mês: {value}':
          'Required daily average this month: {value}',
      'Ainda não há lançamentos suficientes para mostrar o gráfico.':
          'There are not enough entries yet to show the chart.',
      'Lucro dos últimos 7 dias': 'Profit from the last 7 days',
      'Custo fixo diário': 'Daily fixed cost',
      'Baseado em {days} dias no mês atual':
          'Based on {days} days in the current month',
      'Faturamento': 'Revenue',
      'Lucro': 'Profit',
      'KM rodados': 'Kilometers driven',
      'Horas': 'Hours',
      'Corridas': 'Trips',
      'Meta diária': 'Daily goal',
      'Meta semanal': 'Weekly goal',
      'Meta mensal': 'Monthly goal',
      'Resumo mensal': 'Monthly summary',
      'Faturamento Mensal': 'Monthly revenue',
      'Despesas Mensais': 'Monthly expenses',
      'Lucro Mensal': 'Monthly profit',
      'Lucro diário médio': 'Average daily profit',
      'Últimos 7 dias': 'Last 7 days',
      'Acompanhe seu desempenho': 'Track your performance',
      'DIA': 'DAY',
      'SEMANA': 'WEEK',
      'MÊS': 'MONTH',
      'Selecionar dia: {date}': 'Select day: {date}',
      'Semana: {start} até {end}': 'Week: {start} to {end}',
      'Selecionar mês: {month}': 'Select month: {month}',
      'Ainda não há dados suficientes para o gráfico.':
          'There is not enough data yet for the chart.',
      'Lucro acumulado': 'Accumulated profit',
      'FATURAMENTO': 'REVENUE',
      'DESPESAS TOTAIS': 'TOTAL EXPENSES',
      'LUCRO LÍQUIDO': 'NET PROFIT',
      'MÉDIA/DIA': 'AVERAGE/DAY',
      'HORAS': 'HOURS',
      'COMBUSTÍVEL': 'FUEL',
      'POR HORA': 'PER HOUR',
      'DIAS TRABALHADOS': 'DAYS WORKED',
      'Metas recalculadas': 'Goals recalculated',
      'Usamos a meta mensal como base para estimar seus valores diários e semanais.':
          'We used the monthly goal as the basis to estimate your daily and weekly values.',
      'Usamos a meta semanal como referência para preencher os demais períodos.':
          'We used the weekly goal as the reference to fill the other periods.',
      'Usamos a meta diária como base para projetar sua semana e seu mês.':
          'We used the daily goal as the basis to project your week and month.',
      'Valor inválido': 'Invalid value',
      'Informe ao menos uma meta válida para salvar. Não use números negativos.':
          'Enter at least one valid goal to save. Do not use negative numbers.',
      'Nenhuma meta definida': 'No goal defined',
      'Preencha um valor de meta antes de salvar.':
          'Enter a goal value before saving.',
      'Metas atualizadas': 'Goals updated',
      'Metas salvas': 'Goals saved',
      'Seus objetivos financeiros foram registrados com sucesso.':
          'Your financial goals were saved successfully.',
      'Metas atualizadas com sucesso.': 'Goals updated successfully.',
      'Metas salvas com sucesso.': 'Goals saved successfully.',
      'Planejamento de ganhos': 'Income planning',
      'Preencha apenas uma meta base. O app recalcula os outros períodos automaticamente.':
          'Fill in just one base goal. The app recalculates the other periods automatically.',
      'Ex.: 250,00': 'E.g.: 250.00',
      'Ex.: 1.750,00': 'E.g.: 1,750.00',
      'Ex.: 8.000,00': 'E.g.: 8,000.00',
      'Resumo das metas': 'Goals summary',
      'Os valores abaixo mostram como suas metas ficaram distribuídas.':
          'The values below show how your goals were distributed.',
      'Atualizar metas': 'Update goals',
      'Salvar metas': 'Save goals',
      'Nenhum custo informado': 'No cost informed',
      'Preencha pelo menos um valor antes de salvar.':
          'Enter at least one value before saving.',
      'Existem campos para revisar': 'There are fields to review',
      'Preencha ao menos um custo com valor válido para salvar sua configuração.':
          'Enter at least one cost with a valid value to save your settings.',
      'Custos atualizados': 'Costs updated',
      'Custos salvos': 'Costs saved',
      'Seus custos fixos foram registrados e já podem ser usados nos cálculos diários.':
          'Your fixed costs were saved and can already be used in daily calculations.',
      'Custos fixos atualizados com sucesso.':
          'Fixed costs updated successfully.',
      'Custos fixos salvos com sucesso.': 'Fixed costs saved successfully.',
      'Informe um valor para este campo.':
          'Enter a value for this field.',
      'Veja quanto seus custos recorrentes representam no mês e no dia.':
          'See how much your recurring costs represent in the month and per day.',
      'TOTAL MENSAL': 'MONTHLY TOTAL',
      'CUSTO DIÁRIO': 'DAILY COST',
      'DIAS DO MÊS': 'DAYS IN MONTH',
      'Despesas recorrentes': 'Recurring expenses',
      'Preencha apenas o que realmente faz parte da sua rotina mensal. Os totais são atualizados em tempo real.':
          'Fill in only what truly belongs to your monthly routine. Totals are updated in real time.',
      'Parcela do carro': 'Car installment',
      'Ex.: 1.450,00': 'E.g.: 1,450.00',
      'Inclua aqui financiamentos ou leasing do veículo.':
          'Include vehicle financing or leasing here.',
      'Seguro do veículo': 'Vehicle insurance',
      'Ex.: 320,00': 'E.g.: 320.00',
      'Valor médio mensal do seguro.':
          'Average monthly insurance value.',
      'IPVA provisionado': 'Reserved vehicle tax',
      'Ex.: 180,00': 'E.g.: 180.00',
      'Use o valor mensal reservado para o imposto.':
          'Use the monthly value set aside for the tax.',
      'Reserva para manutenção': 'Maintenance reserve',
      'Considere revisões, pneus e pequenos reparos.':
          'Consider maintenance, tires, and small repairs.',
      'Outros': 'Other',
      'Ex.: 90,00': 'E.g.: 90.00',
      'Inclua qualquer outro gasto mensal recorrente que não se encaixe nas categorias acima.':
          'Include any other recurring monthly expense that does not fit the categories above.',
      'Atualizar custos fixos': 'Update fixed costs',
      'Salvar custos fixos': 'Save fixed costs',
      'Existem dados para revisar': 'There is information to review',
      'Confira os campos destacados. Corrija os formatos inválidos antes de salvar.':
          'Check the highlighted fields. Fix invalid formats before saving.',
      'Dados incoerentes no lançamento': 'Inconsistent entry data',
      'KM inicial salvo': 'Starting odometer saved',
      'Lançamento atualizado': 'Entry updated',
      'Lançamento salvo': 'Entry saved',
      'O KM inicial de {date} foi registrado. Você pode voltar depois para completar o restante do dia.':
          'The starting odometer for {date} was saved. You can come back later to complete the rest of the day.',
      'O lançamento de {date} foi atualizado.':
          'The entry for {date} was updated.',
      'O resultado de hoje foi registrado. Custo fixo aplicado: {value}.':
          'Today\'s result was saved. Applied fixed cost: {value}.',
      'Lançamento de {date} atualizado com sucesso.':
          'Entry for {date} updated successfully.',
      'KM inicial salvo com sucesso.':
          'Starting odometer saved successfully.',
      'Lançamento atualizado com sucesso.':
          'Entry updated successfully.',
      'Lançamento salvo com sucesso.': 'Entry saved successfully.',
      'Excluir lançamento': 'Delete entry',
      'Deseja excluir o lançamento de {date}? Essa ação não poderá ser desfeita.':
          'Do you want to delete the entry from {date}? This action cannot be undone.',
      'Cancelar': 'Cancel',
      'Excluir': 'Delete',
      'Lançamento excluído': 'Entry deleted',
      'O lançamento de {date} foi removido do histórico.':
          'The entry from {date} was removed from the history.',
      'Lançamento de {date} excluído com sucesso.':
          'Entry from {date} deleted successfully.',
      'Informe o KM inicial antes do KM final.':
          'Enter the starting odometer before the ending odometer.',
      'O KM final não pode ser menor que o KM inicial.':
          'The ending odometer cannot be lower than the starting odometer.',
      'Preencha o restante do dia ou salve apenas o KM inicial sem informar outros campos.':
          'Complete the rest of the day or save only the starting odometer without filling other fields.',
      'Informe o KM inicial do dia ou registre uma movimentação válida antes de salvar.':
          'Enter the starting odometer for the day or record a valid activity before saving.',
      'Informe o KM inicial antes de salvar o KM final.':
          'Enter the starting odometer before saving the ending odometer.',
      'Se houve faturamento no dia, informe ao menos uma corrida.':
          'If there was revenue during the day, enter at least one trip.',
      'Corridas registradas precisam ter faturamento correspondente.':
          'Recorded trips must have matching revenue.',
      'Se houve corridas, o KM rodado precisa ser maior que zero.':
          'If there were trips, the kilometers driven must be greater than zero.',
      'Se houve movimentação no dia, informe um tempo trabalhado maior que 00:00.':
          'If there was activity during the day, enter worked time greater than 00:00.',
      'Registro parcial salvo com o KM inicial.':
          'Partial record saved with the starting odometer.',
      'Faturamento: {value}': 'Revenue: {value}',
      'KM rodado: {value} km': 'Kilometers driven: {value} km',
      'Odômetro: {start} até {end}':
          'Odometer: {start} to {end}',
      'Corridas: {value}': 'Trips: {value}',
      'Horas trabalhadas: {value}': 'Hours worked: {value}',
      'Combustível: {value}': 'Fuel: {value}',
      'Extras: {value}': 'Extras: {value}',
      'Custo fixo aplicado: {value}': 'Applied fixed cost: {value}',
      'Lucro: {value}': 'Profit: {value}',
      'Prejuízo: {value}': 'Loss: {value}',
      'Você está editando o lançamento de {date}. Salve novamente para aplicar as alterações.':
          'You are editing the entry from {date}. Save again to apply the changes.',
      'Você está editando o lançamento de {date}. Revise os campos de KM antes de salvar, porque registros antigos não guardavam o odômetro inicial e final.':
          'You are editing the entry from {date}. Review the odometer fields before saving because older records did not store the starting and ending odometer.',
      'Modo de edição': 'Edit mode',
      'Editar': 'Edit',
      'Salvar alterações de {date}': 'Save changes for {date}',
      'Atualizar lançamento de hoje': 'Update today\'s entry',
      'Salvar lançamento de hoje': 'Save today\'s entry',
      'Editar lançamento': 'Edit entry',
      'Resultado do dia': 'Day result',
      'Ajuste um lançamento antigo sem perder a data original do registro.':
          'Adjust an older entry without losing its original date.',
      'Preencha os dados do turno para salvar o desempenho do dia com mais contexto.':
          'Fill in the shift data to save the day\'s performance with more context.',
      'Editando: {date}': 'Editing: {date}',
      'Cancelar edição': 'Cancel editing',
      'Faturamento bruto do dia': 'Gross revenue for the day',
      'Ex.: 400,00': 'E.g.: 400.00',
      'Valor total recebido antes de descontar custos.':
          'Total amount received before deducting costs.',
      'KM inicial do veículo': 'Starting vehicle odometer',
      'Ex.: 45.000': 'E.g.: 45,000',
      'Você pode salvar só este campo no início do dia e completar o restante depois.':
          'You can save just this field at the start of the day and complete the rest later.',
      'KM final do veículo': 'Ending vehicle odometer',
      'Ex.: 45.120': 'E.g.: 45,120',
      'Odômetro ao encerrar o dia.': 'Odometer at the end of the day.',
      'Quantidade de corridas': 'Number of trips',
      'Ex.: 15': 'E.g.: 15',
      'Informe o total de viagens concluídas no dia.':
          'Enter the total number of trips completed during the day.',
      'Tempo trabalhado': 'Worked time',
      'Ex.: 08:30': 'E.g.: 08:30',
      'Use o formato hh:mm.': 'Use the hh:mm format.',
      'Combustível gasto no dia': 'Fuel spent during the day',
      'Ex.: 120,50': 'E.g.: 120.50',
      'Some os abastecimentos do período.':
          'Sum the refueling costs for the period.',
      'Despesas extras do dia': 'Extra expenses for the day',
      'Ex.: 15,00': 'E.g.: 15.00',
      'Inclua pedágio, lavagem ou outras despesas variáveis.':
          'Include tolls, car wash, or other variable expenses.',
      'Resumo calculado': 'Calculated summary',
      'Depois de salvar, você vê imediatamente o impacto no lucro do dia.':
          'After saving, you immediately see the impact on the day\'s profit.',
      'Custo fixo diário base': 'Base daily fixed cost',
      'KM rodado no dia': 'Kilometers driven during the day',
      'Lucro do dia': 'Profit for the day',
      'Prejuízo do dia': 'Loss for the day',
      'Histórico de lançamentos': 'Entry history',
      'Consulte os dias anteriores, edite registros antigos e exclua o que não fizer mais sentido.':
          'Check previous days, edit older records, and delete what no longer makes sense.',
      'Nenhum lançamento salvo ainda.': 'No entries saved yet.',
    },
    'es': {
      'Idioma do aplicativo': 'Idioma de la app',
      'Escolha o idioma usado em todas as telas do app.':
          'Elige el idioma usado en todas las pantallas de la app.',
      'Você pode trocar o idioma antes de entrar.':
          'Puedes cambiar el idioma antes de iniciar sesión.',
      'Criar conta': 'Crear cuenta',
      'Entrar': 'Iniciar sesión',
      'Entrar agora': 'Entrar ahora',
      'Já tem conta?': '¿Ya tienes cuenta?',
      'Ainda não tem conta?': '¿Todavía no tienes cuenta?',
      'Bem-vindo ao DriveProfit': 'Bienvenido a DriveProfit',
      'Preencha seus dados de acesso e deixe o cadastro pronto para uso no app.':
          'Completa tus datos de acceso y deja tu registro listo para usar en la app.',
      'Nome completo': 'Nombre completo',
      'Como você gostaria de ser identificado no app':
          'Cómo te gustaría aparecer en la app',
      'E-mail de acesso': 'Correo de acceso',
      'nome@exemplo.com': 'nombre@ejemplo.com',
      'Esse e-mail será usado para entrar na conta.':
          'Este correo se usará para iniciar sesión.',
      'Celular com DDD': 'Teléfono',
      'Use um número que você acompanhe com frequência.':
          'Usa un número que revises con frecuencia.',
      'Como você se identifica': 'Cómo te identificas',
      'Campo usado apenas para personalização do perfil.':
          'Campo usado solo para personalizar el perfil.',
      'Feminino': 'Femenino',
      'Masculino': 'Masculino',
      'Prefiro não informar': 'Prefiero no informar',
      'Data de nascimento': 'Fecha de nacimiento',
      'DD/MM/AAAA': 'DD/MM/AAAA',
      'Segurança da conta': 'Seguridad de la cuenta',
      'Use uma senha forte para proteger seus dados e evitar acessos indevidos.':
          'Usa una contraseña segura para proteger tus datos y evitar accesos no autorizados.',
      'Senha': 'Contraseña',
      'Crie uma senha forte': 'Crea una contraseña segura',
      'Mínimo de 8 caracteres com letras, número e símbolo.':
          'Mínimo 8 caracteres con letras, número y símbolo.',
      'Confirmação da senha': 'Confirmar contraseña',
      'Repita a senha criada acima': 'Repite la contraseña creada arriba',
      'Criar conta e entrar': 'Crear cuenta e ingresar',
      'Revise os campos obrigatórios': 'Revisa los campos obligatorios',
      'Algumas informações estão faltando ou precisam ser corrigidas antes de criar a conta.':
          'Falta información o algunos datos deben corregirse antes de crear la cuenta.',
      'Cadastro duplicado': 'Registro duplicado',
      'Já existe uma conta cadastrada com esse e-mail neste aparelho. Entre com sua conta atual para continuar.':
          'Ya existe una cuenta registrada con este correo en este dispositivo. Inicia sesión con tu cuenta actual para continuar.',
      'Senhas diferentes': 'Contraseñas diferentes',
      'A confirmação precisa ser igual à senha informada acima.':
          'La confirmación debe coincidir con la contraseña ingresada arriba.',
      'Conta criada com sucesso.': 'Cuenta creada con éxito.',
      'Acesse sua conta': 'Accede a tu cuenta',
      'Use o mesmo e-mail e a mesma senha informados no cadastro para continuar.':
          'Usa el mismo correo y la misma contraseña informados durante el registro para continuar.',
      'Digite o e-mail usado no cadastro.':
          'Ingresa el correo usado en el registro.',
      'Sua senha de acesso': 'Tu contraseña de acceso',
      'Entrar no aplicativo': 'Entrar en la aplicación',
      'Revise seus dados': 'Revisa tus datos',
      'Confira o e-mail e a senha antes de continuar.':
          'Verifica el correo y la contraseña antes de continuar.',
      'Conta ainda não cadastrada': 'Cuenta aún no registrada',
      'Crie sua conta primeiro para liberar o acesso ao aplicativo.':
          'Primero crea tu cuenta para liberar el acceso a la aplicación.',
      'Acesso não autorizado': 'Acceso no autorizado',
      'O e-mail ou a senha informados não correspondem ao cadastro salvo.':
          'El correo o la contraseña ingresados no coinciden con el registro guardado.',
      'Login realizado com sucesso.': 'Inicio de sesión realizado con éxito.',
      'Dashboard': 'Panel',
      'Lançamentos': 'Registros',
      'Relatórios': 'Reportes',
      'Metas': 'Metas',
      'Perfil': 'Perfil',
      'Perfil e configurações': 'Perfil y configuraciones',
      'Motorista DriveProfit': 'Conductor DriveProfit',
      'Organize seus dados de acesso e suas preferências principais em um só lugar.':
          'Organiza tus datos de acceso y tus preferencias principales en un solo lugar.',
      'Dados da conta': 'Datos de la cuenta',
      'Essas informações ajudam a identificar o usuário e deixam o app mais pronto para uso comercial.':
          'Esta información ayuda a identificar al usuario y deja la app más lista para uso comercial.',
      'Nome': 'Nombre',
      'Como você quer aparecer no app': 'Cómo quieres aparecer en la app',
      'E-mail': 'Correo',
      'Celular': 'Teléfono',
      '(11) 99999-9999': '(11) 99999-9999',
      'Moeda': 'Moneda',
      'Define a preferência monetária salva para o perfil.':
          'Define la preferencia monetaria guardada para el perfil.',
      'Data de início de uso': 'Fecha de inicio de uso',
      'Ainda não registrada': 'Aún no registrada',
      'Salvar configurações': 'Guardar configuraciones',
      'Informe o nome do usuário.': 'Ingresa el nombre del usuario.',
      'Informe um celular para contato.': 'Ingresa un teléfono de contacto.',
      'Digite um número válido com DDD.':
          'Ingresa un número válido con código de área.',
      'Confira nome, e-mail e celular antes de salvar as configurações.':
          'Verifica nombre, correo y teléfono antes de guardar las configuraciones.',
      'Configurações salvas': 'Configuraciones guardadas',
      'Seu perfil foi atualizado com sucesso neste aparelho.':
          'Tu perfil fue actualizado con éxito en este dispositivo.',
      'Perfil atualizado com sucesso.': 'Perfil actualizado con éxito.',
      'Real brasileiro': 'Real brasileño',
      'Dolar americano': 'Dólar estadounidense',
      'Euro': 'Euro',
      'Custos fixos': 'Costos fijos',
      'O app continua com a configuração detalhada na tela própria, mas você consegue acompanhar o resumo daqui.':
          'La app mantiene la configuración detallada en su propia pantalla, pero puedes seguir el resumen desde aquí.',
      'Total mensal: {value}': 'Total mensual: {value}',
      'Custo diário estimado: {value}':
          'Costo diario estimado: {value}',
      'Editar custos fixos': 'Editar costos fijos',
      'Sair da conta': 'Cerrar sesión',
      'Encerrar a sessão neste aparelho.':
          'Cerrar la sesión en este dispositivo.',
      'Informe um e-mail para continuar.':
          'Ingresa un correo para continuar.',
      'Digite um e-mail válido.': 'Ingresa un correo válido.',
      'Crie uma senha para proteger sua conta.':
          'Crea una contraseña para proteger tu cuenta.',
      'Use pelo menos 8 caracteres.':
          'Usa al menos 8 caracteres.',
      'Inclua ao menos uma letra maiúscula.':
          'Incluye al menos una letra mayúscula.',
      'Inclua ao menos uma letra minúscula.':
          'Incluye al menos una letra minúscula.',
      'Inclua ao menos um número.':
          'Incluye al menos un número.',
      'Inclua ao menos um caractere especial.':
          'Incluye al menos un carácter especial.',
      'Não use espaços na senha.':
          'No uses espacios en la contraseña.',
      'Informe um valor para continuar.':
          'Ingresa un valor para continuar.',
      'Digite um número válido.': 'Ingresa un número válido.',
      'Use um valor igual ou maior que zero.':
          'Usa un valor igual o mayor que cero.',
      'Preencha este campo.': 'Completa este campo.',
      'Digite um número inteiro válido.':
          'Ingresa un número entero válido.',
      'Informe quanto tempo você trabalhou.':
          'Informa cuánto tiempo trabajaste.',
      'Use um horário válido no formato hh:mm.':
          'Usa un horario válido en formato hh:mm.',
      'Meta: {value}': 'Meta: {value}',
      'Arrecadado: {value}': 'Recaudado: {value}',
      'Falta: {value}': 'Falta: {value}',
      '{value}% da meta': '{value}% de la meta',
      'Meta batida': 'Meta alcanzada',
      'Meta ainda não atingida': 'Meta aún no alcanzada',
      'Custos fixos restantes no mês': 'Costos fijos restantes del mes',
      '{covered} de {total} já cobertos':
          '{covered} de {total} ya cubiertos',
      'Média diária necessária neste mês: {value}':
          'Promedio diario necesario este mes: {value}',
      'Ainda não há lançamentos suficientes para mostrar o gráfico.':
          'Todavía no hay registros suficientes para mostrar el gráfico.',
      'Lucro dos últimos 7 dias': 'Ganancia de los últimos 7 días',
      'Custo fixo diário': 'Costo fijo diario',
      'Baseado em {days} dias no mês atual':
          'Basado en {days} días del mes actual',
      'Faturamento': 'Facturación',
      'Lucro': 'Ganancia',
      'KM rodados': 'KM recorridos',
      'Horas': 'Horas',
      'Corridas': 'Viajes',
      'Meta diária': 'Meta diaria',
      'Meta semanal': 'Meta semanal',
      'Meta mensal': 'Meta mensual',
      'Resumo mensal': 'Resumen mensual',
      'Faturamento Mensal': 'Facturación mensual',
      'Despesas Mensais': 'Gastos mensuales',
      'Lucro Mensal': 'Ganancia mensual',
      'Lucro diário médio': 'Ganancia diaria promedio',
      'Últimos 7 dias': 'Últimos 7 días',
      'Acompanhe seu desempenho': 'Sigue tu desempeño',
      'DIA': 'DÍA',
      'SEMANA': 'SEMANA',
      'MÊS': 'MES',
      'Selecionar dia: {date}': 'Seleccionar día: {date}',
      'Semana: {start} até {end}': 'Semana: {start} hasta {end}',
      'Selecionar mês: {month}': 'Seleccionar mes: {month}',
      'Ainda não há dados suficientes para o gráfico.':
          'Todavía no hay datos suficientes para el gráfico.',
      'Lucro acumulado': 'Ganancia acumulada',
      'FATURAMENTO': 'FACTURACIÓN',
      'DESPESAS TOTAIS': 'GASTOS TOTALES',
      'LUCRO LÍQUIDO': 'GANANCIA NETA',
      'MÉDIA/DIA': 'PROMEDIO/DÍA',
      'HORAS': 'HORAS',
      'COMBUSTÍVEL': 'COMBUSTIBLE',
      'POR HORA': 'POR HORA',
      'DIAS TRABALHADOS': 'DÍAS TRABAJADOS',
      'Metas recalculadas': 'Metas recalculadas',
      'Usamos a meta mensal como base para estimar seus valores diários e semanais.':
          'Usamos la meta mensual como base para estimar tus valores diarios y semanales.',
      'Usamos a meta semanal como referência para preencher os demais períodos.':
          'Usamos la meta semanal como referencia para completar los demás períodos.',
      'Usamos a meta diária como base para projetar sua semana e seu mês.':
          'Usamos la meta diaria como base para proyectar tu semana y tu mes.',
      'Valor inválido': 'Valor inválido',
      'Informe ao menos uma meta válida para salvar. Não use números negativos.':
          'Ingresa al menos una meta válida para guardar. No uses números negativos.',
      'Nenhuma meta definida': 'Ninguna meta definida',
      'Preencha um valor de meta antes de salvar.':
          'Completa un valor de meta antes de guardar.',
      'Metas atualizadas': 'Metas actualizadas',
      'Metas salvas': 'Metas guardadas',
      'Seus objetivos financeiros foram registrados com sucesso.':
          'Tus objetivos financieros fueron guardados con éxito.',
      'Metas atualizadas com sucesso.': 'Metas actualizadas con éxito.',
      'Metas salvas com sucesso.': 'Metas guardadas con éxito.',
      'Planejamento de ganhos': 'Planificación de ganancias',
      'Preencha apenas uma meta base. O app recalcula os outros períodos automaticamente.':
          'Completa solo una meta base. La app recalcula los otros períodos automáticamente.',
      'Ex.: 250,00': 'Ej.: 250,00',
      'Ex.: 1.750,00': 'Ej.: 1.750,00',
      'Ex.: 8.000,00': 'Ej.: 8.000,00',
      'Resumo das metas': 'Resumen de metas',
      'Os valores abaixo mostram como suas metas ficaram distribuídas.':
          'Los valores abajo muestran cómo quedaron distribuidas tus metas.',
      'Atualizar metas': 'Actualizar metas',
      'Salvar metas': 'Guardar metas',
      'Nenhum custo informado': 'Ningún costo informado',
      'Preencha pelo menos um valor antes de salvar.':
          'Completa al menos un valor antes de guardar.',
      'Existem campos para revisar': 'Hay campos para revisar',
      'Preencha ao menos um custo com valor válido para salvar sua configuração.':
          'Completa al menos un costo con valor válido para guardar tu configuración.',
      'Custos atualizados': 'Costos actualizados',
      'Custos salvos': 'Costos guardados',
      'Seus custos fixos foram registrados e já podem ser usados nos cálculos diários.':
          'Tus costos fijos fueron guardados y ya pueden usarse en los cálculos diarios.',
      'Custos fixos atualizados com sucesso.':
          'Costos fijos actualizados con éxito.',
      'Custos fixos salvos com sucesso.': 'Costos fijos guardados con éxito.',
      'Informe um valor para este campo.':
          'Ingresa un valor para este campo.',
      'Veja quanto seus custos recorrentes representam no mês e no dia.':
          'Mira cuánto representan tus costos recurrentes en el mes y en el día.',
      'TOTAL MENSAL': 'TOTAL MENSUAL',
      'CUSTO DIÁRIO': 'COSTO DIARIO',
      'DIAS DO MÊS': 'DÍAS DEL MES',
      'Despesas recorrentes': 'Gastos recurrentes',
      'Preencha apenas o que realmente faz parte da sua rotina mensal. Os totais são atualizados em tempo real.':
          'Completa solo lo que realmente forma parte de tu rutina mensual. Los totales se actualizan en tiempo real.',
      'Parcela do carro': 'Cuota del auto',
      'Ex.: 1.450,00': 'Ej.: 1.450,00',
      'Inclua aqui financiamentos ou leasing do veículo.':
          'Incluye aquí financiaciones o leasing del vehículo.',
      'Seguro do veículo': 'Seguro del vehículo',
      'Ex.: 320,00': 'Ej.: 320,00',
      'Valor médio mensal do seguro.':
          'Valor promedio mensual del seguro.',
      'IPVA provisionado': 'IPVA provisionado',
      'Ex.: 180,00': 'Ej.: 180,00',
      'Use o valor mensal reservado para o imposto.':
          'Usa el valor mensual reservado para el impuesto.',
      'Reserva para manutenção': 'Reserva para mantenimiento',
      'Considere revisões, pneus e pequenos reparos.':
          'Considera revisiones, neumáticos y pequeñas reparaciones.',
      'Outros': 'Otros',
      'Ex.: 90,00': 'Ej.: 90,00',
      'Inclua qualquer outro gasto mensal recorrente que não se encaixe nas categorias acima.':
          'Incluye cualquier otro gasto mensual recurrente que no encaje en las categorías anteriores.',
      'Atualizar custos fixos': 'Actualizar costos fijos',
      'Salvar custos fixos': 'Guardar costos fijos',
      'Existem dados para revisar': 'Hay datos para revisar',
      'Confira os campos destacados. Corrija os formatos inválidos antes de salvar.':
          'Revisa los campos destacados. Corrige los formatos inválidos antes de guardar.',
      'Dados incoerentes no lançamento': 'Datos inconsistentes en el registro',
      'KM inicial salvo': 'KM inicial guardado',
      'Lançamento atualizado': 'Registro actualizado',
      'Lançamento salvo': 'Registro guardado',
      'O KM inicial de {date} foi registrado. Você pode voltar depois para completar o restante do dia.':
          'El KM inicial de {date} fue registrado. Puedes volver después para completar el resto del día.',
      'O lançamento de {date} foi atualizado.':
          'El registro de {date} fue actualizado.',
      'O resultado de hoje foi registrado. Custo fixo aplicado: {value}.':
          'El resultado de hoy fue registrado. Costo fijo aplicado: {value}.',
      'Lançamento de {date} atualizado com sucesso.':
          'Registro de {date} actualizado con éxito.',
      'KM inicial salvo com sucesso.': 'KM inicial guardado con éxito.',
      'Lançamento atualizado com sucesso.':
          'Registro actualizado con éxito.',
      'Lançamento salvo com sucesso.': 'Registro guardado con éxito.',
      'Excluir lançamento': 'Eliminar registro',
      'Deseja excluir o lançamento de {date}? Essa ação não poderá ser desfeita.':
          '¿Deseas eliminar el registro de {date}? Esta acción no se podrá deshacer.',
      'Cancelar': 'Cancelar',
      'Excluir': 'Eliminar',
      'Lançamento excluído': 'Registro eliminado',
      'O lançamento de {date} foi removido do histórico.':
          'El registro de {date} fue eliminado del historial.',
      'Lançamento de {date} excluído com sucesso.':
          'Registro de {date} eliminado con éxito.',
      'Informe o KM inicial antes do KM final.':
          'Ingresa el KM inicial antes del KM final.',
      'O KM final não pode ser menor que o KM inicial.':
          'El KM final no puede ser menor que el KM inicial.',
      'Preencha o restante do dia ou salve apenas o KM inicial sem informar outros campos.':
          'Completa el resto del día o guarda solo el KM inicial sin informar otros campos.',
      'Informe o KM inicial do dia ou registre uma movimentação válida antes de salvar.':
          'Ingresa el KM inicial del día o registra un movimiento válido antes de guardar.',
      'Informe o KM inicial antes de salvar o KM final.':
          'Ingresa el KM inicial antes de guardar el KM final.',
      'Se houve faturamento no dia, informe ao menos uma corrida.':
          'Si hubo facturación en el día, informa al menos un viaje.',
      'Corridas registradas precisam ter faturamento correspondente.':
          'Los viajes registrados deben tener una facturación correspondiente.',
      'Se houve corridas, o KM rodado precisa ser maior que zero.':
          'Si hubo viajes, el KM recorrido debe ser mayor que cero.',
      'Se houve movimentação no dia, informe um tempo trabalhado maior que 00:00.':
          'Si hubo movimiento en el día, informa un tiempo trabajado mayor que 00:00.',
      'Registro parcial salvo com o KM inicial.':
          'Registro parcial guardado con el KM inicial.',
      'Faturamento: {value}': 'Facturación: {value}',
      'KM rodado: {value} km': 'KM recorridos: {value} km',
      'Odômetro: {start} até {end}':
          'Odómetro: {start} hasta {end}',
      'Corridas: {value}': 'Viajes: {value}',
      'Horas trabalhadas: {value}': 'Horas trabajadas: {value}',
      'Combustível: {value}': 'Combustible: {value}',
      'Extras: {value}': 'Extras: {value}',
      'Custo fixo aplicado: {value}': 'Costo fijo aplicado: {value}',
      'Lucro: {value}': 'Ganancia: {value}',
      'Prejuízo: {value}': 'Pérdida: {value}',
      'Você está editando o lançamento de {date}. Salve novamente para aplicar as alterações.':
          'Estás editando el registro de {date}. Guarda nuevamente para aplicar los cambios.',
      'Você está editando o lançamento de {date}. Revise os campos de KM antes de salvar, porque registros antigos não guardavam o odômetro inicial e final.':
          'Estás editando el registro de {date}. Revisa los campos de KM antes de guardar, porque los registros antiguos no guardaban el odómetro inicial y final.',
      'Modo de edição': 'Modo de edición',
      'Editar': 'Editar',
      'Salvar alterações de {date}':
          'Guardar cambios de {date}',
      'Atualizar lançamento de hoje': 'Actualizar registro de hoy',
      'Salvar lançamento de hoje': 'Guardar registro de hoy',
      'Editar lançamento': 'Editar registro',
      'Resultado do dia': 'Resultado del día',
      'Ajuste um lançamento antigo sem perder a data original do registro.':
          'Ajusta un registro antiguo sin perder la fecha original.',
      'Preencha os dados do turno para salvar o desempenho do dia com mais contexto.':
          'Completa los datos del turno para guardar el rendimiento del día con más contexto.',
      'Editando: {date}': 'Editando: {date}',
      'Cancelar edição': 'Cancelar edición',
      'Faturamento bruto do dia': 'Facturación bruta del día',
      'Ex.: 400,00': 'Ej.: 400,00',
      'Valor total recebido antes de descontar custos.':
          'Valor total recibido antes de descontar costos.',
      'KM inicial do veículo': 'KM inicial del vehículo',
      'Ex.: 45.000': 'Ej.: 45.000',
      'Você pode salvar só este campo no início do dia e completar o restante depois.':
          'Puedes guardar solo este campo al inicio del día y completar el resto después.',
      'KM final do veículo': 'KM final del vehículo',
      'Ex.: 45.120': 'Ej.: 45.120',
      'Odômetro ao encerrar o dia.':
          'Odómetro al finalizar el día.',
      'Quantidade de corridas': 'Cantidad de viajes',
      'Ex.: 15': 'Ej.: 15',
      'Informe o total de viagens concluídas no dia.':
          'Informa el total de viajes completados en el día.',
      'Tempo trabalhado': 'Tiempo trabajado',
      'Ex.: 08:30': 'Ej.: 08:30',
      'Use o formato hh:mm.': 'Usa el formato hh:mm.',
      'Combustível gasto no dia': 'Combustible gastado en el día',
      'Ex.: 120,50': 'Ej.: 120,50',
      'Some os abastecimentos do período.':
          'Suma los abastecimientos del período.',
      'Despesas extras do dia': 'Gastos extra del día',
      'Ex.: 15,00': 'Ej.: 15,00',
      'Inclua pedágio, lavagem ou outras despesas variáveis.':
          'Incluye peajes, lavado u otros gastos variables.',
      'Resumo calculado': 'Resumen calculado',
      'Depois de salvar, você vê imediatamente o impacto no lucro do dia.':
          'Después de guardar, ves inmediatamente el impacto en la ganancia del día.',
      'Custo fixo diário base': 'Costo fijo diario base',
      'KM rodado no dia': 'KM recorridos en el día',
      'Lucro do dia': 'Ganancia del día',
      'Prejuízo do dia': 'Pérdida del día',
      'Histórico de lançamentos': 'Historial de registros',
      'Consulte os dias anteriores, edite registros antigos e exclua o que não fizer mais sentido.':
          'Consulta los días anteriores, edita registros antiguos y elimina lo que ya no tenga sentido.',
      'Nenhum lançamento salvo ainda.':
          'Todavía no hay registros guardados.',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
