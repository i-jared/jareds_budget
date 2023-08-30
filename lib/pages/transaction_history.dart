import 'package:budget/state/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});
  @override
  State<StatefulWidget> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final formatter = DateFormat('M/d');
  @override
  initState() {
    super.initState();
    context.read<HomeState>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    // m/d/y date formatter

    final state = context.watch<HomeState>();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('History'),
        ),
        body: state.transactions == null
            ? const Center(child: CircularProgressIndicator())
            : _buildTransactionList(context, state));
  }

  Widget _buildTransactionList(BuildContext context, HomeState state) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(flex: 3, child: Text('Description')),
            Expanded(flex: 2, child: Text('Category')),
            Expanded(child: Text('Amount')),
            Expanded(child: Text('Date', textAlign: TextAlign.end)),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              itemCount: state.transactions!.length,
              itemBuilder: (context, index) {
                return Row(children: [
                  Expanded(
                      flex: 3,
                      child: Text(state.transactions![index].description)),
                  Expanded(
                      flex: 2,
                      child: Text(categoryToString(
                          state.transactions![index].category))),
                  Expanded(
                      child: Text(
                    state.transactions![index].amount.toStringAsFixed(2),
                    textAlign: TextAlign.right,
                  )),
                  Expanded(
                      child: Text(
                    formatter.format(state.transactions![index].date),
                    textAlign: TextAlign.right,
                  )),
                ]);
              }),
        ),
      ],
    );
  }
}
