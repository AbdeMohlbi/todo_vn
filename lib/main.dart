import 'dart:math' show Random;

import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const AppScreen(),
      routes: {
        '/new_contact': (context) => const newContactView(),
        // '/':
      },
    );
  }
}

class Contact {
  final int id;
  final String name;

  Contact({required this.name}) : id = Random().nextInt(5);
}

class ContactBook extends ValueNotifier<List<Contact>> {
  ContactBook._sharedInstance()
      : super([
          Contact(name: 'Foo bar'),
          Contact(name: 'Foo bar'),
          Contact(name: 'Foo bar'),
          Contact(name: 'Foo bar'),
          Contact(name: 'Foo bar'),
          Contact(name: 'Foo bar'),
        ]);

  static final ContactBook _shared = ContactBook._sharedInstance();

  factory ContactBook() => _shared;

  int get length => value.length;

  void add({required Contact contact}) {
    value.add(contact);
    notifyListeners();
  }

  void remove({required Contact contact}) {
    if (value.contains(contact)) {
      value.remove(contact);
      notifyListeners();
    }
  }

  Contact? contact({required int index}) =>
      value.length > index ? value[index] : null;
}

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  AppScreenState createState() => AppScreenState();
}

class AppScreenState extends State<AppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("test"),
      ),
      body: ValueListenableBuilder(
        valueListenable: ContactBook(),
        builder: (contact, value, child) {
          final contacts = value;
          return ListView.separated(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Dismissible(
                resizeDuration: Duration(milliseconds: 500),
                onDismissed: (direction) {
                  SnackBar snc = SnackBar(content: Text("wtf"));
                  ScaffoldMessenger.of(context).showSnackBar(snc);
                  setState(() {
                    contacts.remove(contact);
                  });
                },
                key: ValueKey(contact.id),
                child: Material(
                  color: Colors.white,
                  elevation: 6,
                  child: ListTile(
                    title: Text(contact.name),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/new_contact');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/*

class AppScreenState extends State<AppScreen> {
  void _addTodo() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.add),
          title: const Text('New To-Do'),
          scrollable: true,
          alignment: Alignment.center,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: titleController,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: "to-do title", counterText: "title"),
              ),
              TextField(
                  maxLines: null,
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      hintText: "to-do description",
                      counterText: "description")),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: const Text('Add'),
                onPressed: () async {
                  await DatabaseHelper.addNote(
                      (titleController.text, descriptionController.text));

                  setState(() {
                    // provider
                  });
                  context.mounted ? Navigator.of(context).pop() : null;
                })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        extendBody: false,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.space_dashboard_outlined,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.done_all_outlined,
                    color: Colors.orange,
                  )),
              const Spacer(),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                  )),
            ],
          ),
          backgroundColor: Colors.black,
          elevation: 20,
        ),
        body: const TodoListScreen(),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.orange,
          onPressed: _addTodo,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ));
  }
}

 */
class newContactView extends StatefulWidget {
  const newContactView({super.key});

  @override
  State<newContactView> createState() => _newContactViewState();
}

class _newContactViewState extends State<newContactView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("add a new contact"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration:
                const InputDecoration(hintText: "enter a new name here"),
          ),
          TextButton(
              onPressed: () {
                final contact = Contact(name: _controller.text);
                ContactBook().add(contact: contact);
                Navigator.of(context).pop();
              },
              child: const Text("add contact"))
        ],
      ),
    );
  }
}
