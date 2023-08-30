import 'dart:async';

import 'package:budget/data/transaction.dart';
import 'package:budget/extensions/timeofday.dart';
import 'package:flutter/material.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum Category {
  gas,
  grocery,
  restaurant,
  shopping,
  entertainment,
  travel,
  church,
  other,
}

String categoryToString(Category category) {
  switch (category) {
    case Category.gas:
      return 'Gas';
    case Category.grocery:
      return 'Grocery';
    case Category.restaurant:
      return 'Restaurant';
    case Category.shopping:
      return 'Shopping';
    case Category.entertainment:
      return 'Entertainment';
    case Category.travel:
      return 'Travel';
    case Category.church:
      return 'Church';
    case Category.other:
      return 'Other';
    default:
      return 'Other';
  }
}

Category stringToCategory(String index) {
  switch (index) {
    case 'Gas':
      return Category.gas;
    case 'Grocery':
      return Category.grocery;
    case 'Restaurant':
      return Category.restaurant;
    case 'Shopping':
      return Category.shopping;
    case 'Entertainment':
      return Category.entertainment;
    case 'Travel':
      return Category.travel;
    case 'Church':
      return Category.church;
    case 'Other':
      return Category.other;
    default:
      return Category.other;
  }
}

class HomeState extends ChangeNotifier {
  TextEditingController controller;
  TextEditingController descriptionController;
  Category _category;
  List<Transaction>? transactions;

  late StreamSubscription downloadProgressSub;
  var downloadCompleter = Completer<void>();

  TimeOfDay? _time;
  HomeState()
      : controller = TextEditingController(),
        descriptionController = TextEditingController(),
        _category = Category.restaurant {
    descriptionController.addListener(() => notifyListeners());
    controller.addListener(() => notifyListeners());
  }

// getters and setters for category
  Category get category => _category;
  set category(Category category) {
    _category = category;
    notifyListeners();
  }

  //getters and setters for time
  TimeOfDay? get time => _time;
  set time(TimeOfDay? time) {
    _time = time;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/budget.csv';
    if (!downloadCompleter.isCompleted) {
      await downloadFile(path);
    }
    final file = File(path);
    bool fileExists = await file.exists();

    if (!fileExists) {
      await file.create();
      await file.writeAsString('Description,Amount,Category,Datetime\n');
    }
    // Read existing content
    // Write the updated content back to the file
    // Append the new line
    String content = await file.readAsString();
    List<String> lines =
        content.split('\n').where((l) => l.isNotEmpty).skip(1).toList();
    transactions = lines.map<Transaction>((line) {
      var vals = line.split(',');
      return Transaction(
          description: vals[0],
          amount: double.parse(vals[1]),
          category: stringToCategory(vals[2]),
          date: DateTime.parse(vals[3]));
    }).toList();

    notifyListeners();
  }

  Future<void> addTransaction() async {
    late StreamSubscription uploadProgressSub;
    var uploadCompleter = Completer<void>();
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/budget.csv';

    double amount =
        double.parse(controller.text.replaceAll('\$', '').replaceAll(',', ''));
    String description = descriptionController.text;

    // use icloud_storage package to read a csv from iCloud Drive and create it if it doesn't exist
    await downloadFile(path);

    // Check if the file exists
    // If the file doesn't exist, create a new one and add headers
    final file = File(path);
    bool fileExists = await file.exists();

    if (!fileExists) {
      await file.create();
      await file.writeAsString('Description,Amount,Category,Datetime\n');
    }
    // Read existing content
    // Write the updated content back to the file
    // Append the new line
    String content = await file.readAsString();
    content +=
        '$description,${amount.toString()},${categoryToString(category)},${time == null ? DateTime.now().toIso8601String() : time!.toDateTime().toIso8601String()}\n';
    await file.writeAsString(content);

    // upload csv file to iCloud Drive
    try {
      await ICloudStorage.upload(
          containerId: 'iCloud.hugepuppy.budget',
          filePath: path,
          destinationRelativePath: 'Documents/budget.csv',
          onProgress: (p) {
            uploadProgressSub = p.listen(
              (val) {},
              onDone: () {
                uploadCompleter.complete();
              },
              onError: (err) {
                uploadCompleter.completeError(err);
              },
              cancelOnError: true,
            );
          });
    } catch (e) {
      uploadCompleter.complete();
    }

    await uploadCompleter.future;
    await file.delete();
    downloadProgressSub.cancel();
    uploadProgressSub.cancel();

    controller.clear();
    descriptionController.clear();
    _category = Category.restaurant;
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> downloadFile(
    String path,
  ) async {
    try {
      await ICloudStorage.download(
          containerId: 'iCloud.hugepuppy.budget',
          relativePath: 'Documents/budget.csv',
          destinationFilePath: path,
          onProgress: (p) {
            downloadProgressSub = p.listen(
              (val) {},
              onDone: () {
                downloadCompleter.complete();
              },
              onError: (err) {
                downloadCompleter.completeError(err);
              },
              cancelOnError: true,
            );
          });
    } catch (e) {
      downloadCompleter.complete();
    }
    await downloadCompleter.future;
  }
}
