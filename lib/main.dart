import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent)),
      home: const LazyLoadingList(),
    );
  }
}

class LazyLoadingList extends StatefulWidget {
  const LazyLoadingList({super.key});

  @override
  LazyLoadingListState createState() => LazyLoadingListState();
}

class LazyLoadingListState extends State<LazyLoadingList> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreData();
    }
  }

  Future<void> _fetchMoreData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    for (int i = ContactBook.itemsFetched;
        i < ContactBook.itemsFetched + ContactBook.step;
        i++) {
      ContactBook().add(
        lst: ContactBook().csvTable[i],
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            labelText: 'Enter your text',
            prefixIcon: Icon(Icons.sports_football),
            border: OutlineInputBorder(),
          ),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: ValueListenableBuilder(
          valueListenable: ContactBook(),
          builder: (context, contacts, child) {
            return Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  itemCount: contacts.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == contacts.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final contact = contacts[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        isThreeLine: false,
                        subtitle: Text(
                          " ${contact[4]} `${contact[5]}",
                          style: TextStyle(overflow: TextOverflow.fade),
                        ),
                        title: Text(
                          "${contact[1]} vs ${contact[2]} ${contact[0]} ",
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                        trailing: Wrap(
                          children: [
                            // penalty
                            IconButton(
                              icon: "${contact[7]}" == 'TRUE'
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                              onPressed: () {},
                              padding: EdgeInsets.all(0),
                              tooltip: "penalty",
                            ),
                            //own goal
                            IconButton(
                              icon: "${contact[6]}" == 'TRUE'
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                              onPressed: () {},
                              padding: EdgeInsets.all(0),
                              tooltip: "own goal",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (_isLoading)
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          }),
    );
  }
}

class ContactBook extends ValueNotifier<List<dynamic>> {
  static int itemsFetched = 1;
  static int step = 30;
  late List<dynamic> csvTable;
  Future<void> _fetchContacts() async {
    await Future.delayed(const Duration(seconds: 2));
    final data = await rootBundle.loadString('assets/scores.csv');
    csvTable =
        const CsvToListConverter(fieldDelimiter: ',', eol: '\n').convert(data);
    final fetchedData = getCsvSub(itemsFetched, itemsFetched + step);
    itemsFetched += step;
    value = [...value, ...fetchedData];
    notifyListeners();
  }

  ContactBook._sharedInstance() : super([]) {
    _fetchContacts();
  }
  static final ContactBook _instance = ContactBook._sharedInstance();
  factory ContactBook() => _instance;

  int get length => value.length;
  List<dynamic> getCsvSub(int a, int b) => csvTable.sublist(a, b);

  void add({required dynamic lst}) {
    value.add(lst);
    notifyListeners();
  }

  void remove({required int index}) {
    if (index < value.length) {
      value.remove(value[index]);
      notifyListeners();
    }
  }
}
