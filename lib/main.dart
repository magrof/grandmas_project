import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

void main() async {
  // Plugin work initialize
  WidgetsFlutterBinding.ensureInitialized();

  try {
    camers = await availableCameras();
  } catch (e) {
    debugPrint("Ошибка камер: $e");
  }

  runApp(const PlantApp());
}

class PlantApp extends StatelessWidget {
  const PlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Database? _database;
  List<Map<String, dynamic>> _plants = [];
  final TextEditingController _controller = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initDb(); // Открываем БД сразу при запуске
  }


  // DB LOGIC (SQL)
  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'plants.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE plants(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)',
        );
      },
    );
    _refreshPlants();
  }

  // Read from DB
  Future<void> _refreshPlants() async {
    List<Map<String, dynamic>> data;
    if (_searchQuery.isEmpty) {
      data = await _database!.query('plants', orderBy: 'id DESC');
    } else{
      data = await _database!.query(
          'plants',
          where: 'name LIKE ?',
          whereArgs: ['%$_searchQuery%'],
          orderBy: 'id DESC',
    );
    }
    setState(() {
      _plants = data;
    });
  }

  // DB adding
  Future<void> _addPlant(String name) async {
    if (name.isEmpty) return;
    await _database!.insert('plants', {'name': name});
    _controller.clear(); // Очистить поле ввода
    _refreshPlants();   // Обновить список на экране
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои растения (БД SQLite)'),
        backgroundColor: Colors.green[100],
      ),
      body: Column(
        children: [
          // Text field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Введите название растения',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addPlant(_controller.text),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (value){
                  _searchQuery = value;
                  _refreshPlants();
                },
                decoration: const InputDecoration(
                  hintText: 'Найти в моём саду...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 0)
                ),
              ),
          ),
          const Divider(),
          // List from DB
          Expanded(
            child: _plants.isEmpty
                ? const Center(child: Text('Список пуст. Добавьте растение!'))
                : ListView.builder(
              itemCount: _plants.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.local_florist, color: Colors.green),
                  title: Text(_plants[index]['name']),
                  subtitle: Text('ID в базе: ${_plants[index]['id']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _database!.delete('plants', where: 'id = ?', whereArgs: [_plants[index]['id']]);
                      _refreshPlants();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      //Opening camera button
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            if (cameras.isNotEmpty){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PlantCameraScreen(camera: cameras.first),
    ),
    );
    } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Камера не найдена')),
              );
            }
    },
        child: const Icon(Icons.camera_alt),
    ),
    );
  }
}

class PlantCameraScreen extends StatefulWidget{
  final CameraDescription camera;
  const PlantCameraScreen({super.key, required this.camera});

  @override
  State<PlantCameraScreen> createState() => _PlantCameraScreenState();
}
class _PlantCameraScreenState extends State<PlantCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState (){
    super.initState();
        _controller = CameraController(widget.camera, ResolutionPreset.medium);
        _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose (){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text ('Сфотографируй лист')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        try {
          await _initializeControllerFuture;
          final image = await _controller.takePicture();
          debugPrint("Фото сохранено: ${image.path}");
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Фото сделано!')),
          );
        } catch (e) {
          debugPrint(e.toString());
        }
      },
        child: const Icon(Icons.camera),
      ),
    );
  }
}

