class Himno {
  final int id;
  final int numero;
  final String titulo;
  final String contenido;
  int favorito; 
  final int idHimnario; 

  Himno({
    required this.id,
    required this.numero,
    required this.titulo,
    required this.contenido,
    this.favorito = 0,
    required this.idHimnario, 
  });

  factory Himno.fromMap(Map<String, dynamic> json) {
    return Himno(
      // .toInt() convierte tanto doubles como ints a enteros de Dart
      id: (json['ID'] as num?)?.toInt() ?? 0,
      numero: (json['NUMERO'] as num?)?.toInt() ?? 0,
      titulo: json['TITULO']?.toString() ?? "Sin título",
      contenido: json['CONTENIDO']?.toString() ?? "Sin contenido",
      favorito: (json['FAVORITO'] as num?)?.toInt() ?? 0,
      idHimnario: (json['ID_HIMNARIO'] as num?)?.toInt() ?? 1, 
    );
  }
}