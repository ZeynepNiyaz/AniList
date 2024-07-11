import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(AniListApp());
}

class AniListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniList',
      theme: ThemeData(primaryColor: const Color.fromARGB(255, 101, 148, 237)),
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// -------------------- Welcome Page --------------------
class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void navigateToCategory(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryPage(contentType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF40E0D0), // Turkuaz arka plan
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AniList',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => navigateToCategory(context, 'Anime'),
                  child: Text('Anime'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => navigateToCategory(context, 'Manga'),
                  child: Text('Manga'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => navigateToCategory(context, 'Manwha'),
                  child: Text('Manwha'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- Category Page --------------------
class CategoryPage extends StatefulWidget {
  final String contentType;

  CategoryPage({required this.contentType});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<String> getCategoryButtons() {
    if (widget.contentType == 'Anime') {
      return ['İzleyeceğim', 'İzliyorum', 'İzledim', 'Yarım bıraktım'];
    } else {
      return ['Okuyacağım', 'Okuyorum', 'Okudum', 'Yarım bıraktım'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = getCategoryButtons();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.contentType} Kategorileri')),
      body: Container(
        color: const Color(0xFF40E0D0), // Turkuaz arka plan
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListPage(
                            contentType: widget.contentType,
                            category: category,
                          ),
                        ),
                      );
                    },
                    child: Text(category),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// -------------------- List Page --------------------
class ListPage extends StatefulWidget {
  final String contentType;
  final String category;

  ListPage({required this.contentType, required this.category});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Map<String, String>> items = [];
  bool showInput = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  int? editingIndex;

  String get prefsKey => '${widget.contentType}_${widget.category}';

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItems = prefs.getStringList(prefsKey) ?? [];
    setState(() {
      items = savedItems.map((item) {
        final parts = item.split('|');
        return {'name': parts[0], 'note': parts.length > 1 ? parts[1] : ''};
      }).toList();
    });
  }

  Future<void> saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItems = items
        .map((item) => '${item['name']}|${item['note'] ?? ''}')
        .toList();
    await prefs.setStringList(prefsKey, savedItems);
  }

  void addItem() {
    final name = _nameController.text.trim();
    final note = _noteController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        if (editingIndex != null) {
          items[editingIndex!] = {'name': name, 'note': note};
          editingIndex = null;
        } else {
          items.insert(0, {'name': name, 'note': note});
        }
        _nameController.clear();
        _noteController.clear();
        showInput = false;
      });
      saveItems();
    }
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
      saveItems();
    });
  }

  void editItem(int index) {
    _nameController.text = items[index]['name']!;
    _noteController.text = items[index]['note']!;
    setState(() {
      showInput = true;
      editingIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.contentType} - ${widget.category}')),
      body: Container(
        color: const Color(0xFF40E0D0), // Turkuaz arka plan
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (showInput) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'İsim gir',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Not gir (isteğe bağlı)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: addItem,
                  child: Text(editingIndex != null ? 'Kaydet' : '+ Ekle'),
                ),
              ],
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item['name']!),
                      subtitle: item['note']!.isNotEmpty
                          ? Text(
                              'Not: ${item['note']!}',
                              style: TextStyle(fontSize: 12),
                            )
                          : null,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            deleteItem(index);
                          } else if (value == 'edit') {
                            editItem(index);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                          PopupMenuItem(value: 'delete', child: Text('Sil')),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showInput = !showInput;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
