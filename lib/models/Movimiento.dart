import 'package:hive/hive.dart';

class Movimiento extends HiveObject {
  final String id;
  final String nombre;
  final double cantidad;
  final DateTime fecha;
  final bool esIngreso;
  final String categoria;        // ← nuevo campo

  Movimiento({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.fecha,
    required this.esIngreso,
    required this.categoria,     // ← nuevo
  });
}

class MovimientoAdapter extends TypeAdapter<Movimiento> {
  @override
  final int typeId = 0;

 @override
Movimiento read(BinaryReader reader) {
  final numOfFields = reader.readByte();
  final fields = <int, dynamic>{
    for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
  };
  return Movimiento(
    id:         fields[0] as String,
    nombre:     fields[1] as String,
    cantidad:   fields[2] as double,
    fecha:      fields[3] as DateTime,
    esIngreso:  fields[4] as bool,
    // Si no hay campo 5, ponemos 'General'
    categoria:  fields.containsKey(5) ? fields[5] as String : 'General',
  );
  }

 @override
void write(BinaryWriter writer, Movimiento obj) {
  writer
    ..writeByte(6)
    ..writeByte(0)..write(obj.id)
    ..writeByte(1)..write(obj.nombre)
    ..writeByte(2)..write(obj.cantidad)
    ..writeByte(3)..write(obj.fecha)
    ..writeByte(4)..write(obj.esIngreso)
    ..writeByte(5)..write(obj.categoria);
}
}
