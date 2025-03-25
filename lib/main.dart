import 'package:flutter/material.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExpenseTracker(),
    );
  }
}

class ExpenseTracker extends StatefulWidget {
  @override
  _ExpenseTrackerState createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  List<Map<String, String>> expenses = [];
  double balance = 0.0;

  void _setBalance() {
    if (_balanceController.text.isNotEmpty) {
      setState(() {
        balance = balance + double.parse(_balanceController.text);
      });
      _balanceController.clear();
    }
  }

  void _addExpense() {
    if (_titleController.text.isNotEmpty && _amountController.text.isNotEmpty) {
      double expenseAmount = double.parse(_amountController.text);
      if (expenseAmount <= balance) {
        setState(() {
          expenses.add({
            'title': _titleController.text,
            'amount': _amountController.text,
          });
          balance -= expenseAmount;
        });
        _titleController.clear();
        _amountController.clear();
      } else {
        _showErrorDialog("Insufficient balance!");
      }
    }
  }

  void _editExpense(int index) {
    _titleController.text = expenses[index]['title']!;
    _amountController.text = expenses[index]['amount']!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double oldAmount = double.parse(expenses[index]['amount']!);
                double newAmount = double.parse(_amountController.text);
                if (newAmount - oldAmount <= balance) {
                  setState(() {
                    balance -= (newAmount - oldAmount);
                    expenses[index] = {
                      'title': _titleController.text,
                      'amount': _amountController.text,
                    };
                  });
                  _titleController.clear();
                  _amountController.clear();
                  Navigator.pop(context);
                } else {
                  _showErrorDialog("Insufficient balance!");
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(int index) {
    setState(() {
      balance += double.parse(expenses[index]['amount']!);
      expenses.removeAt(index);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4, // Opsional: untuk efek bayangan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  16,
                ), // Menambahkan padding agar lebih rapi
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _balanceController,
                      decoration: InputDecoration(labelText: 'Add Balance'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(onPressed: _setBalance, child: Text('Add')),
                    SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addExpense,
                      child: Text('Add Expense'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Pastikan ukuran menyesuaikan konten
                    children: [
                      Text(
                        'Remaining Balance: IDR ${balance.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ), // Tambahkan ruang antara teks dan daftar
                      Expanded(
                        child: ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              color: Colors.lightBlue[200],
                              child: ListTile(
                                title: Text(expenses[index]['title']!),
                                subtitle: Text(
                                  'Amount: IDR${expenses[index]['amount']}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => _editExpense(index),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _deleteExpense(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
