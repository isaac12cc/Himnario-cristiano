import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/himno.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  _initDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "db_himnario.db");

    var exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
      
      ByteData data = await rootBundle.load(join("assets", "db_himnario.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(
      path,
      version: 3, // Subimos a versión 3 para las Listas
      onUpgrade: (db, oldVersion, newVersion) async {
        // Mantenemos la lógica de Favoritos
        if (oldVersion < 2) {
          try {
            await db.execute("ALTER TABLE himnos ADD COLUMN FAVORITO INTEGER DEFAULT 0;");
          } catch (e) { print("Error v2: $e"); }
        }

        // NUEVA VERSIÓN 3: Tablas para Listas Personalizadas
        if (oldVersion < 3) {
          // Tabla de cabecera de las listas
          await db.execute('''
            CREATE TABLE listas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              fecha_creacion TEXT NOT NULL
            );
          ''');

          // Tabla intermedia para la relación muchos a muchos
          await db.execute('''
            CREATE TABLE lista_himnos (
              id_lista INTEGER,
              id_himno INTEGER,
              PRIMARY KEY (id_lista, id_himno),
              FOREIGN KEY (id_lista) REFERENCES listas (id) ON DELETE CASCADE,
              FOREIGN KEY (id_himno) REFERENCES himnos (ID) ON DELETE CASCADE
            );
          ''');
        }
      },
    );
  }

  // --- MÉTODOS DE HIMNOS ---

  Future<List<Himno>> getHimnos({int? idHimnarioFilter}) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps;
    if (idHimnarioFilter != null) {
      maps = await dbClient.query('himnos', where: 'ID_HIMNARIO = ?', whereArgs: [idHimnarioFilter], orderBy: 'NUMERO ASC');
    } else {
      maps = await dbClient.query('himnos', orderBy: 'NUMERO ASC');
    }
    return List.generate(maps.length, (i) => Himno.fromMap(maps[i]));
  }

  Future<List<Himno>> buscarHimnos(String query) async {
  final dbClient = await db;
  
  if (query.isEmpty) {
    return getHimnos();
  }

  String queryClean = _normalizarTexto(query.toLowerCase().trim());

  try {
    // Usamos rawQuery para tener control total del SQL y los REPLACE
    // IMPORTANTE: Asegúrate que tu columna se llama 'CONTENIDO' o 'LETRA'
    // En este ejemplo usaré 'CONTENIDO' que es común en estos himnarios
    final List<Map<String, dynamic>> maps = await dbClient.rawQuery('''
      SELECT * FROM himnos 
      WHERE (
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(TITULO), 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u') LIKE ? 
        OR NUMERO = ? 
        OR REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LOWER(CONTENIDO), 'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u') LIKE ?
      )
      ORDER BY NUMERO ASC
    ''', ['%$queryClean%', queryClean, '%$queryClean%']);

    return List.generate(maps.length, (i) => Himno.fromMap(maps[i]));
  } catch (e) {

    print("Error en búsqueda inteligente: $e");
    
    final List<Map<String, dynamic>> mapsFallback = await dbClient.query(
      'himnos',
      where: "TITULO LIKE ? OR NUMERO = ?",
      whereArgs: ['%$query%', query],
      orderBy: 'NUMERO ASC',
    );
    return List.generate(mapsFallback.length, (i) => Himno.fromMap(mapsFallback[i]));
  }
}

String _normalizarTexto(String texto) {
  var conAcentos = 'áéíóúÁÉÍÓÚüÜ';
  var sinAcentos = 'aeiouAEIOUuU';
  for (int i = 0; i < conAcentos.length; i++) {
    texto = texto.replaceAll(conAcentos[i], sinAcentos[i]);
  }
  return texto;
}

  Future<int> actualizarFavorito(int id, int valor) async {
    final dbClient = await db;
    return await dbClient.update('himnos', {'FAVORITO': valor}, where: 'ID = ?', whereArgs: [id]);
  }

  Future<List<Himno>> getFavoritos() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('himnos', where: 'FAVORITO = 1', orderBy: 'NUMERO ASC');
    return List.generate(maps.length, (i) => Himno.fromMap(maps[i]));
  }

  // --- NUEVOS MÉTODOS PARA GESTIÓN DE LISTAS ---

  // Obtener todas las carpetas de listas
  Future<List<Map<String, dynamic>>> getListas() async {
    final dbClient = await db;
    return await dbClient.query('listas', orderBy: 'nombre ASC');
  }

  // Crear una nueva lista (Carpeta)
  Future<int> crearLista(String nombre) async {
    final dbClient = await db;
    return await dbClient.insert('listas', {
      'nombre': nombre,
      'fecha_creacion': DateTime.now().toIso8601String(),
    });
  }

  // Eliminar una lista
  Future<int> eliminarLista(int idLista) async {
    final dbClient = await db;
    return await dbClient.delete('listas', where: 'id = ?', whereArgs: [idLista]);
  }

  // Agregar un himno a una lista (Evita duplicados con conflictAlgorithm)
  Future<int> agregarHimnoALista(int idLista, int idHimno) async {
    final dbClient = await db;
    return await dbClient.insert(
      'lista_himnos', 
      {'id_lista': idLista, 'id_himno': idHimno},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Quitar un himno de una lista específica
  Future<int> quitarHimnoDeLista(int idLista, int idHimno) async {
    final dbClient = await db;
    return await dbClient.delete(
      'lista_himnos', 
      where: 'id_lista = ? AND id_himno = ?', 
      whereArgs: [idLista, idHimno]
    );
  }

  // Obtener los himnos de una lista específica
  Future<List<Himno>> getHimnosDeLista(int idLista) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.rawQuery('''
      SELECT h.* FROM himnos h
      INNER JOIN lista_himnos lh ON h.ID = lh.id_himno
      WHERE lh.id_lista = ?
      ORDER BY h.NUMERO ASC
    ''', [idLista]);
    
    return List.generate(maps.length, (i) => Himno.fromMap(maps[i]));
  }
}