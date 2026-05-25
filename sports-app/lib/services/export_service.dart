import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/player.dart';
import '../models/payment.dart';
import '../models/division.dart';
import '../models/activity.dart';
import '../models/match.dart';

class ExportService {

  // Exporter les donn des joueurs en Excel
  Future<File> exportPlayersToExcel(List<Player> players, {String? fileName}) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Players';

    // En-t
    sheet.getRangeByIndex(1, 1).setText('ID');
    sheet.getRangeByIndex(1, 2).setText('Name');
    sheet.getRangeByIndex(1, 3).setText('Position');
    sheet.getRangeByIndex(1, 4).setText('Age');
    sheet.getRangeByIndex(1, 5).setText('Goals');
    sheet.getRangeByIndex(1, 6).setText('Assists');
    sheet.getRangeByIndex(1, 7).setText('Matches');
    sheet.getRangeByIndex(1, 8).setText('Rating');
    sheet.getRangeByIndex(1, 9).setText('Division');
    sheet.getRangeByIndex(1, 10).setText('Phone');
    sheet.getRangeByIndex(1, 11).setText('Email');

    // Donn
    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      sheet.getRangeByIndex(i + 2, 1).setNumber(player.id?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 2, 2).setText(player.nom ?? '');
      sheet.getRangeByIndex(i + 2, 3).setText(player.position ?? '');
      sheet.getRangeByIndex(i + 2, 4).setNumber(player.age?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 2, 5).setNumber(player.goals?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 2, 6).setNumber(player.assists?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 2, 7).setNumber(player.matches?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 2, 8).setNumber(player.rating ?? 0);
      sheet.getRangeByIndex(i + 2, 9).setText(player.divisionName ?? '');
      sheet.getRangeByIndex(i + 2, 10).setText(player.tel ?? '');
      sheet.getRangeByIndex(i + 2, 11).setText(player.email ?? '');
    }

    // Mise en forme
    final Range headerRange = sheet.getRangeByName('A1:K1');
    headerRange.cellStyle.backColor = '#2ECC71';
    headerRange.cellStyle.fontColor = '#FFFFFF';
    headerRange.cellStyle.bold = true;

    // Auto-fit les colonnes
    for (int i = 1; i <= 11; i++) {
      sheet.autoFitColumn(i);
    }

    // Sauvegarder le fichier
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/${fileName ?? 'players_${DateTime.now().millisecondsSinceEpoch}.xlsx'}';
    final file = File(path);
    await file.writeAsBytes(bytes);

    return file;
  }

  // Exporter les paiements en Excel
  Future<File> exportPaymentsToExcel(List<Payment> payments, {String? fileName}) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Payments';

    // En-t
    sheet.getRangeByIndex(1, 1).setText('ID');
    sheet.getRangeByIndex(1, 2).setText('Month');
    sheet.getRangeByIndex(1, 3).setText('Amount (DT)');
    sheet.getRangeByIndex(1, 4).setText('Status');
    sheet.getRangeByIndex(1, 5).setText('Player ID');
    sheet.getRangeByIndex(1, 6).setText('Parent ID');
    sheet.getRangeByIndex(1, 7).setText('Payment Date');

    // Donn
    for (int i = 0; i < payments.length; i++) {
      final payment = payments[i];
      sheet.getRangeByIndex(i + 2, 1).setNumber(payment.id?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 2, 2).setText(DateFormat('MMM yyyy').format(payment.mois));
      sheet.getRangeByIndex(i + 2, 3).setNumber(payment.montant);
      sheet.getRangeByIndex(i + 2, 4).setText(payment.isPaid ? 'Paid' : 'Unpaid');
      sheet.getRangeByIndex(i + 2, 5).setNumber(payment.playerId?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 2, 6).setNumber(payment.parentId?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 2, 7).setText(DateFormat('dd/MM/yyyy').format(payment.mois));
    }

    // Mise en forme
    final Range headerRange = sheet.getRangeByName('A1:G1');
    headerRange.cellStyle.backColor = '#3498DB';
    headerRange.cellStyle.fontColor = '#FFFFFF';
    headerRange.cellStyle.bold = true;

    // Formater la colonne montant
    final Range amountRange = sheet.getRangeByName('C2:C${payments.length + 1}');
    amountRange.numberFormat = '#,##0.00 "DT"';

    // Auto-fit
    for (int i = 1; i <= 7; i++) {
      sheet.autoFitColumn(i);
    }

    // Sauvegarder
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/${fileName ?? 'payments_${DateTime.now().millisecondsSinceEpoch}.xlsx'}';
    final file = File(path);
    await file.writeAsBytes(bytes);

    return file;
  }

  // Exporter les statistiques en PDF (simul - dans un vrai projet on utiliserait syncfusion_flutter_pdf)
  Future<File> exportStatisticsToPDF({
    required Map<String, dynamic> stats,
    required String title,
  }) async {
    // Pour l'instant, on cr un simple fichier texte
    // Dans un projet r on utiliserait syncfusion_flutter_pdf pour g des PDF

    String content = '''
    FOOTBALL ACADEMY STATISTICS REPORT
    ==================================
    Title: $title
    Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}

    SUMMARY
    -------
    ''';

    stats.forEach((key, value) {
      content += '${key.replaceAll('_', ' ').toUpperCase()}: $value\n';
    });

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/stats_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File(path);
    await file.writeAsString(content);

    return file;
  }

  // Exporter le rapport mensuel
  Future<File> exportMonthlyReport({
    required List<Payment> payments,
    required List<Activity> activities,
    required List<MatchModel> matches,
    required DateTime month,
  }) async {
    final Workbook workbook = Workbook();

    // Feuille 1: Paiements
    final Worksheet paymentsSheet = workbook.worksheets[0];
    paymentsSheet.name = 'Payments ${DateFormat('MMM yyyy').format(month)}';

    paymentsSheet.getRangeByIndex(1, 1).setText('Monthly Payments Report');
    paymentsSheet.getRangeByIndex(1, 1).cellStyle.fontSize = 16;
    paymentsSheet.getRangeByIndex(1, 1).cellStyle.bold = true;

    final double totalRevenue = payments.where((p) => p.isPaid).fold(0.0, (sum, p) => sum + p.montant);
    final double pendingRevenue = payments.where((p) => !p.isPaid).fold(0.0, (sum, p) => sum + p.montant);

    paymentsSheet.getRangeByIndex(3, 1).setText('Total Paid:');
    paymentsSheet.getRangeByIndex(3, 2).setNumber(totalRevenue);
    paymentsSheet.getRangeByIndex(4, 1).setText('Pending:');
    paymentsSheet.getRangeByIndex(4, 2).setNumber(pendingRevenue);
    paymentsSheet.getRangeByIndex(5, 1).setText('Total Players:');
    paymentsSheet.getRangeByIndex(5, 2).setNumber(payments.length.toDouble());

    // Feuille 2: Activit
    final Worksheet activitiesSheet = workbook.worksheets.add();
    activitiesSheet.name = 'Activities';

    activitiesSheet.getRangeByIndex(1, 1).setText('Activity');
    activitiesSheet.getRangeByIndex(1, 2).setText('Date');
    activitiesSheet.getRangeByIndex(1, 3).setText('Location');

    for (int i = 0; i < activities.length; i++) {
      final activity = activities[i];
      activitiesSheet.getRangeByIndex(i + 2, 1).setText(activity.titre);
      activitiesSheet.getRangeByIndex(i + 2, 2).setText(activity.date);
      activitiesSheet.getRangeByIndex(i + 2, 3).setText(activity.lieu ?? '');
    }

    // Feuille 3: Matchs
    final Worksheet matchesSheet = workbook.worksheets.add();
    matchesSheet.name = 'Matches';

    matchesSheet.getRangeByIndex(1, 1).setText('Opponent');
    matchesSheet.getRangeByIndex(1, 2).setText('Date');
    matchesSheet.getRangeByIndex(1, 3).setText('Result');
    matchesSheet.getRangeByIndex(1, 4).setText('Score');

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      matchesSheet.getRangeByIndex(i + 2, 1).setText(match.opponent ?? '');
      matchesSheet.getRangeByIndex(i + 2, 2).setText(match.date);
      matchesSheet.getRangeByIndex(i + 2, 3).setText(match.result ?? '');
      matchesSheet.getRangeByIndex(i + 2, 4).setText(match.score ?? '');
    }

    // Sauvegarder
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/monthly_report_${DateFormat('MMM_yyyy').format(month)}.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes);

    return file;
  }

  // Fonction pour partager un fichier
  Future<void> shareFile(File file, BuildContext context, String subject) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject,
        text: 'Sports Academy Export',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing file: $e')),
      );
    }
  }

  // G un rapport de performance des joueurs
  Future<File> generatePlayerPerformanceReport(List<Player> players) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Player Performance';

    // En-t
    sheet.getRangeByIndex(1, 1).setText('Player Performance Report');
    sheet.getRangeByIndex(1, 1).cellStyle.fontSize = 18;
    sheet.getRangeByIndex(1, 1).cellStyle.bold = true;

    sheet.getRangeByIndex(3, 1).setText('Rank');
    sheet.getRangeByIndex(3, 2).setText('Player Name');
    sheet.getRangeByIndex(3, 3).setText('Goals');
    sheet.getRangeByIndex(3, 4).setText('Assists');
    sheet.getRangeByIndex(3, 5).setText('Matches');
    sheet.getRangeByIndex(3, 6).setText('Rating');
    sheet.getRangeByIndex(3, 7).setText('Performance Score');

    // Trier les joueurs par performance
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) {
        final scoreA = (a.goals ?? 0) * 2 + (a.assists ?? 0) * 1.5 + (a.matches ?? 0) * 0.5;
        final scoreB = (b.goals ?? 0) * 2 + (b.assists ?? 0) * 1.5 + (b.matches ?? 0) * 0.5;
        return scoreB.compareTo(scoreA);
      });

    // Donn
    for (int i = 0; i < sortedPlayers.length; i++) {
      final player = sortedPlayers[i];
      final performanceScore = (player.goals ?? 0) * 2 + (player.assists ?? 0) * 1.5 + (player.matches ?? 0) * 0.5;

      sheet.getRangeByIndex(i + 4, 1).setNumber((i + 1).toDouble());
      sheet.getRangeByIndex(i + 4, 2).setText(player.nom ?? '');
      sheet.getRangeByIndex(i + 4, 3).setNumber(player.goals?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 4, 4).setNumber(player.assists?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 4, 5).setNumber(player.matches?.toDouble() ?? 0);
      sheet.getRangeByIndex(i + 4, 6).setNumber(player.rating ?? 0);
      sheet.getRangeByIndex(i + 4, 7).setNumber(performanceScore);
      if (i < 3) {
        final Range rowRange = sheet.getRangeByIndex(i + 4, 1, i + 4, 7);
        rowRange.cellStyle.backColor = i == 0 ? '#FFD700' : i == 1 ? '#C0C0C0' : '#CD7F32';
      }
    }

    // Mise en forme
    final Range headerRange = sheet.getRangeByName('A3:G3');
    headerRange.cellStyle.backColor = '#2C3E50';
    headerRange.cellStyle.fontColor = '#FFFFFF';
    headerRange.cellStyle.bold = true;

    // R
    final int totalGoals = sortedPlayers.fold(0, (sum, p) => sum + (p.goals ?? 0));
    final int totalAssists = sortedPlayers.fold(0, (sum, p) => sum + (p.assists ?? 0));
    final int totalMatches = sortedPlayers.fold(0, (sum, p) => sum + (p.matches ?? 0));

    final int summaryRow = sortedPlayers.length + 6;
    sheet.getRangeByIndex(summaryRow, 1).setText('TOTAL');
    sheet.getRangeByIndex(summaryRow, 3).setNumber(totalGoals.toDouble());
    sheet.getRangeByIndex(summaryRow, 4).setNumber(totalAssists.toDouble());
    sheet.getRangeByIndex(summaryRow, 5).setNumber(totalMatches.toDouble());

    final Range totalRange = sheet.getRangeByIndex(summaryRow, 1, summaryRow, 7);
    totalRange.cellStyle.backColor = '#27AE60';
    totalRange.cellStyle.fontColor = '#FFFFFF';
    totalRange.cellStyle.bold = true;

    // Auto-fit
    for (int i = 1; i <= 7; i++) {
      sheet.autoFitColumn(i);
    }

    // Sauvegarder
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/player_performance_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes);

    return file;
  }
}


