import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/plant_disease.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  //DB and table name
  static const String tableName = 'diseases';
  static const String dbName = 'plant_diseases.db';

  Future<Database> get database async{
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
  Future<Database> _initDB() async{
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        treatment TEXT NOT NULL,
        imageUrl TEXT
      )
    ''');
    // Вставьте сюда начальные тестовые данные, используя INSERT
    _insertInitialData(db);
  }

  // Запрос: INSERT (вставка данных)
  Future<int> insertDisease(PlantDisease disease) async {
    Database db = await instance.database;
    return await db.insert(tableName, disease.toMap());
  }

  // Запрос: SELECT (получение всех данных)
  Future<List<PlantDisease>> getDiseases() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    // Преобразование Map в список объектов PlantDisease
    return List.generate(maps.length, (i) {
      return PlantDisease.fromMap(maps[i]);
    });
  }

  // Тестовые данные (Вы можете их расширить!)
  Future _insertInitialData(Database db) async {
    await db.insert(tableName, {
      'name': 'Мучнистая роса',
      'symptoms': 'Белый налет на листьях и стеблях, похожий на муку.',
      'treatment': 'Обработка фунгицидами, удаление пораженных частей.',
      'imageUrl': 'assets/images/powdery_mildew.jpg'
    });
    // Добавьте еще несколько болезней для теста!
  }
}