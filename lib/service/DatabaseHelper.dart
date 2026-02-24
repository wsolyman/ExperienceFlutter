import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Notification {
  final int? id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;
  final String? category;

  Notification({
    this.id,
    required this.title,
    required this.body,
    required this.data,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data.toString(), // Convert Map to String
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'category': category,
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    // Parse data string back to Map
    Map<String, dynamic> dataMap = {};
    try {
      if (map['data'] != null) {
        // Remove curly braces and split by comma
        String dataString = map['data'].toString();
        dataString = dataString.replaceAll('{', '').replaceAll('}', '');
        var pairs = dataString.split(',');
        for (var pair in pairs) {
          var keyValue = pair.split(':');
          if (keyValue.length == 2) {
            String key = keyValue[0].trim();
            String value = keyValue[1].trim();
            dataMap[key] = value;
          }
        }
      }
    } catch (e) {
      print('Error parsing data: $e');
    }

    return Notification(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      data: dataMap,
      imageUrl: map['imageUrl'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] == 1,
      category: map['category'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notifications.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        data TEXT,
        imageUrl TEXT,
        timestamp TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        category TEXT
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_timestamp ON notifications(timestamp DESC)
    ''');
    await db.execute('''
      CREATE INDEX idx_isRead ON notifications(isRead)
    ''');
  }

  // Insert notification
  Future<int> insertNotification(Notification notification) async {
    Database db = await database;
    return await db.insert('notifications', notification.toMap());
  }

  // Get all notifications
  Future<List<Notification>> getAllNotifications() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) {
      return Notification.fromMap(maps[i]);
    });
  }

  // Get unread notifications count
  Future<int> getUnreadCount() async {
    Database db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM notifications WHERE isRead = 0')
    );
    return count ?? 0;
  }

  // Mark as read
  Future<void> markAsRead(int id) async {
    Database db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    Database db = await database;
    await db.update(
      'notifications',
      {'isRead': 1},
    );
  }

  // Delete notification
  Future<void> deleteNotification(int id) async {
    Database db = await database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    Database db = await database;
    await db.delete('notifications');
  }
}