import 'package:budget/state/home.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => HomeState(),
        builder: (context, state) {
          return MaterialApp(
            title: 'Budget',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const MyHomePage(),
          );
        });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<HomeState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Budget'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                inputFormatters: [CurrencyTextInputFormatter(symbol: '\$')],
                keyboardType: TextInputType.number,
                controller: state.controller,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 40),
              DropdownButton<Category>(
                value: state.category,
                onChanged: (Category? newValue) {
                  state.category = newValue ?? state.category;
                },
                items: Category.values.map((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              TextField(
                  controller: state.descriptionController,
                  decoration: const InputDecoration(hintText: 'Description')),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: state.controller.text.isEmpty ? null : state.addTransaction,
        tooltip: 'Save',
        child: const Icon(Icons.save),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
