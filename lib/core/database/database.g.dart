// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClientesTable extends Clientes with TableInfo<$ClientesTable, Cliente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombresMeta =
      const VerificationMeta('nombres');
  @override
  late final GeneratedColumn<String> nombres = GeneratedColumn<String>(
      'nombres', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _apellidosMeta =
      const VerificationMeta('apellidos');
  @override
  late final GeneratedColumn<String> apellidos = GeneratedColumn<String>(
      'apellidos', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tipoDocumentoMeta =
      const VerificationMeta('tipoDocumento');
  @override
  late final GeneratedColumn<String> tipoDocumento = GeneratedColumn<String>(
      'tipo_documento', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 2, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _numeroDocumentoMeta =
      const VerificationMeta('numeroDocumento');
  @override
  late final GeneratedColumn<String> numeroDocumento = GeneratedColumn<String>(
      'numero_documento', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 5, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _telefonoMeta =
      const VerificationMeta('telefono');
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
      'telefono', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 7, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _direccionMeta =
      const VerificationMeta('direccion');
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
      'direccion', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _referenciaMeta =
      const VerificationMeta('referencia');
  @override
  late final GeneratedColumn<String> referencia = GeneratedColumn<String>(
      'referencia', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
      'activo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activo" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _fechaRegistroMeta =
      const VerificationMeta('fechaRegistro');
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>('fecha_registro', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _fechaActualizacionMeta =
      const VerificationMeta('fechaActualizacion');
  @override
  late final GeneratedColumn<DateTime> fechaActualizacion =
      GeneratedColumn<DateTime>('fecha_actualizacion', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nombres,
        apellidos,
        tipoDocumento,
        numeroDocumento,
        telefono,
        email,
        direccion,
        referencia,
        observaciones,
        activo,
        fechaRegistro,
        fechaActualizacion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(Insertable<Cliente> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombres')) {
      context.handle(_nombresMeta,
          nombres.isAcceptableOrUnknown(data['nombres']!, _nombresMeta));
    } else if (isInserting) {
      context.missing(_nombresMeta);
    }
    if (data.containsKey('apellidos')) {
      context.handle(_apellidosMeta,
          apellidos.isAcceptableOrUnknown(data['apellidos']!, _apellidosMeta));
    } else if (isInserting) {
      context.missing(_apellidosMeta);
    }
    if (data.containsKey('tipo_documento')) {
      context.handle(
          _tipoDocumentoMeta,
          tipoDocumento.isAcceptableOrUnknown(
              data['tipo_documento']!, _tipoDocumentoMeta));
    } else if (isInserting) {
      context.missing(_tipoDocumentoMeta);
    }
    if (data.containsKey('numero_documento')) {
      context.handle(
          _numeroDocumentoMeta,
          numeroDocumento.isAcceptableOrUnknown(
              data['numero_documento']!, _numeroDocumentoMeta));
    } else if (isInserting) {
      context.missing(_numeroDocumentoMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(_telefonoMeta,
          telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta));
    } else if (isInserting) {
      context.missing(_telefonoMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('direccion')) {
      context.handle(_direccionMeta,
          direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta));
    } else if (isInserting) {
      context.missing(_direccionMeta);
    }
    if (data.containsKey('referencia')) {
      context.handle(
          _referenciaMeta,
          referencia.isAcceptableOrUnknown(
              data['referencia']!, _referenciaMeta));
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    if (data.containsKey('activo')) {
      context.handle(_activoMeta,
          activo.isAcceptableOrUnknown(data['activo']!, _activoMeta));
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
          _fechaRegistroMeta,
          fechaRegistro.isAcceptableOrUnknown(
              data['fecha_registro']!, _fechaRegistroMeta));
    }
    if (data.containsKey('fecha_actualizacion')) {
      context.handle(
          _fechaActualizacionMeta,
          fechaActualizacion.isAcceptableOrUnknown(
              data['fecha_actualizacion']!, _fechaActualizacionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cliente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cliente(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombres: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombres'])!,
      apellidos: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}apellidos'])!,
      tipoDocumento: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_documento'])!,
      numeroDocumento: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}numero_documento'])!,
      telefono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefono'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      direccion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direccion'])!,
      referencia: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}referencia']),
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
      activo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activo'])!,
      fechaRegistro: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_registro'])!,
      fechaActualizacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_actualizacion']),
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class Cliente extends DataClass implements Insertable<Cliente> {
  final int id;
  final String nombres;
  final String apellidos;
  final String tipoDocumento;
  final String numeroDocumento;
  final String telefono;
  final String? email;
  final String direccion;
  final String? referencia;
  final String? observaciones;
  final bool activo;
  final DateTime fechaRegistro;
  final DateTime? fechaActualizacion;
  const Cliente(
      {required this.id,
      required this.nombres,
      required this.apellidos,
      required this.tipoDocumento,
      required this.numeroDocumento,
      required this.telefono,
      this.email,
      required this.direccion,
      this.referencia,
      this.observaciones,
      required this.activo,
      required this.fechaRegistro,
      this.fechaActualizacion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombres'] = Variable<String>(nombres);
    map['apellidos'] = Variable<String>(apellidos);
    map['tipo_documento'] = Variable<String>(tipoDocumento);
    map['numero_documento'] = Variable<String>(numeroDocumento);
    map['telefono'] = Variable<String>(telefono);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['direccion'] = Variable<String>(direccion);
    if (!nullToAbsent || referencia != null) {
      map['referencia'] = Variable<String>(referencia);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['activo'] = Variable<bool>(activo);
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    if (!nullToAbsent || fechaActualizacion != null) {
      map['fecha_actualizacion'] = Variable<DateTime>(fechaActualizacion);
    }
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      nombres: Value(nombres),
      apellidos: Value(apellidos),
      tipoDocumento: Value(tipoDocumento),
      numeroDocumento: Value(numeroDocumento),
      telefono: Value(telefono),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      direccion: Value(direccion),
      referencia: referencia == null && nullToAbsent
          ? const Value.absent()
          : Value(referencia),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      activo: Value(activo),
      fechaRegistro: Value(fechaRegistro),
      fechaActualizacion: fechaActualizacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaActualizacion),
    );
  }

  factory Cliente.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cliente(
      id: serializer.fromJson<int>(json['id']),
      nombres: serializer.fromJson<String>(json['nombres']),
      apellidos: serializer.fromJson<String>(json['apellidos']),
      tipoDocumento: serializer.fromJson<String>(json['tipoDocumento']),
      numeroDocumento: serializer.fromJson<String>(json['numeroDocumento']),
      telefono: serializer.fromJson<String>(json['telefono']),
      email: serializer.fromJson<String?>(json['email']),
      direccion: serializer.fromJson<String>(json['direccion']),
      referencia: serializer.fromJson<String?>(json['referencia']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      activo: serializer.fromJson<bool>(json['activo']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
      fechaActualizacion:
          serializer.fromJson<DateTime?>(json['fechaActualizacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombres': serializer.toJson<String>(nombres),
      'apellidos': serializer.toJson<String>(apellidos),
      'tipoDocumento': serializer.toJson<String>(tipoDocumento),
      'numeroDocumento': serializer.toJson<String>(numeroDocumento),
      'telefono': serializer.toJson<String>(telefono),
      'email': serializer.toJson<String?>(email),
      'direccion': serializer.toJson<String>(direccion),
      'referencia': serializer.toJson<String?>(referencia),
      'observaciones': serializer.toJson<String?>(observaciones),
      'activo': serializer.toJson<bool>(activo),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
      'fechaActualizacion': serializer.toJson<DateTime?>(fechaActualizacion),
    };
  }

  Cliente copyWith(
          {int? id,
          String? nombres,
          String? apellidos,
          String? tipoDocumento,
          String? numeroDocumento,
          String? telefono,
          Value<String?> email = const Value.absent(),
          String? direccion,
          Value<String?> referencia = const Value.absent(),
          Value<String?> observaciones = const Value.absent(),
          bool? activo,
          DateTime? fechaRegistro,
          Value<DateTime?> fechaActualizacion = const Value.absent()}) =>
      Cliente(
        id: id ?? this.id,
        nombres: nombres ?? this.nombres,
        apellidos: apellidos ?? this.apellidos,
        tipoDocumento: tipoDocumento ?? this.tipoDocumento,
        numeroDocumento: numeroDocumento ?? this.numeroDocumento,
        telefono: telefono ?? this.telefono,
        email: email.present ? email.value : this.email,
        direccion: direccion ?? this.direccion,
        referencia: referencia.present ? referencia.value : this.referencia,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
        activo: activo ?? this.activo,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
        fechaActualizacion: fechaActualizacion.present
            ? fechaActualizacion.value
            : this.fechaActualizacion,
      );
  Cliente copyWithCompanion(ClientesCompanion data) {
    return Cliente(
      id: data.id.present ? data.id.value : this.id,
      nombres: data.nombres.present ? data.nombres.value : this.nombres,
      apellidos: data.apellidos.present ? data.apellidos.value : this.apellidos,
      tipoDocumento: data.tipoDocumento.present
          ? data.tipoDocumento.value
          : this.tipoDocumento,
      numeroDocumento: data.numeroDocumento.present
          ? data.numeroDocumento.value
          : this.numeroDocumento,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      email: data.email.present ? data.email.value : this.email,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      referencia:
          data.referencia.present ? data.referencia.value : this.referencia,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      activo: data.activo.present ? data.activo.value : this.activo,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
      fechaActualizacion: data.fechaActualizacion.present
          ? data.fechaActualizacion.value
          : this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cliente(')
          ..write('id: $id, ')
          ..write('nombres: $nombres, ')
          ..write('apellidos: $apellidos, ')
          ..write('tipoDocumento: $tipoDocumento, ')
          ..write('numeroDocumento: $numeroDocumento, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('direccion: $direccion, ')
          ..write('referencia: $referencia, ')
          ..write('observaciones: $observaciones, ')
          ..write('activo: $activo, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('fechaActualizacion: $fechaActualizacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      nombres,
      apellidos,
      tipoDocumento,
      numeroDocumento,
      telefono,
      email,
      direccion,
      referencia,
      observaciones,
      activo,
      fechaRegistro,
      fechaActualizacion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cliente &&
          other.id == this.id &&
          other.nombres == this.nombres &&
          other.apellidos == this.apellidos &&
          other.tipoDocumento == this.tipoDocumento &&
          other.numeroDocumento == this.numeroDocumento &&
          other.telefono == this.telefono &&
          other.email == this.email &&
          other.direccion == this.direccion &&
          other.referencia == this.referencia &&
          other.observaciones == this.observaciones &&
          other.activo == this.activo &&
          other.fechaRegistro == this.fechaRegistro &&
          other.fechaActualizacion == this.fechaActualizacion);
}

class ClientesCompanion extends UpdateCompanion<Cliente> {
  final Value<int> id;
  final Value<String> nombres;
  final Value<String> apellidos;
  final Value<String> tipoDocumento;
  final Value<String> numeroDocumento;
  final Value<String> telefono;
  final Value<String?> email;
  final Value<String> direccion;
  final Value<String?> referencia;
  final Value<String?> observaciones;
  final Value<bool> activo;
  final Value<DateTime> fechaRegistro;
  final Value<DateTime?> fechaActualizacion;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.nombres = const Value.absent(),
    this.apellidos = const Value.absent(),
    this.tipoDocumento = const Value.absent(),
    this.numeroDocumento = const Value.absent(),
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.direccion = const Value.absent(),
    this.referencia = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.activo = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
    this.fechaActualizacion = const Value.absent(),
  });
  ClientesCompanion.insert({
    this.id = const Value.absent(),
    required String nombres,
    required String apellidos,
    required String tipoDocumento,
    required String numeroDocumento,
    required String telefono,
    this.email = const Value.absent(),
    required String direccion,
    this.referencia = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.activo = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
    this.fechaActualizacion = const Value.absent(),
  })  : nombres = Value(nombres),
        apellidos = Value(apellidos),
        tipoDocumento = Value(tipoDocumento),
        numeroDocumento = Value(numeroDocumento),
        telefono = Value(telefono),
        direccion = Value(direccion);
  static Insertable<Cliente> custom({
    Expression<int>? id,
    Expression<String>? nombres,
    Expression<String>? apellidos,
    Expression<String>? tipoDocumento,
    Expression<String>? numeroDocumento,
    Expression<String>? telefono,
    Expression<String>? email,
    Expression<String>? direccion,
    Expression<String>? referencia,
    Expression<String>? observaciones,
    Expression<bool>? activo,
    Expression<DateTime>? fechaRegistro,
    Expression<DateTime>? fechaActualizacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombres != null) 'nombres': nombres,
      if (apellidos != null) 'apellidos': apellidos,
      if (tipoDocumento != null) 'tipo_documento': tipoDocumento,
      if (numeroDocumento != null) 'numero_documento': numeroDocumento,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      if (direccion != null) 'direccion': direccion,
      if (referencia != null) 'referencia': referencia,
      if (observaciones != null) 'observaciones': observaciones,
      if (activo != null) 'activo': activo,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
      if (fechaActualizacion != null) 'fecha_actualizacion': fechaActualizacion,
    });
  }

  ClientesCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombres,
      Value<String>? apellidos,
      Value<String>? tipoDocumento,
      Value<String>? numeroDocumento,
      Value<String>? telefono,
      Value<String?>? email,
      Value<String>? direccion,
      Value<String?>? referencia,
      Value<String?>? observaciones,
      Value<bool>? activo,
      Value<DateTime>? fechaRegistro,
      Value<DateTime?>? fechaActualizacion}) {
    return ClientesCompanion(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      referencia: referencia ?? this.referencia,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombres.present) {
      map['nombres'] = Variable<String>(nombres.value);
    }
    if (apellidos.present) {
      map['apellidos'] = Variable<String>(apellidos.value);
    }
    if (tipoDocumento.present) {
      map['tipo_documento'] = Variable<String>(tipoDocumento.value);
    }
    if (numeroDocumento.present) {
      map['numero_documento'] = Variable<String>(numeroDocumento.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (referencia.present) {
      map['referencia'] = Variable<String>(referencia.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    if (fechaActualizacion.present) {
      map['fecha_actualizacion'] = Variable<DateTime>(fechaActualizacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('nombres: $nombres, ')
          ..write('apellidos: $apellidos, ')
          ..write('tipoDocumento: $tipoDocumento, ')
          ..write('numeroDocumento: $numeroDocumento, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('direccion: $direccion, ')
          ..write('referencia: $referencia, ')
          ..write('observaciones: $observaciones, ')
          ..write('activo: $activo, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('fechaActualizacion: $fechaActualizacion')
          ..write(')'))
        .toString();
  }
}

class $CajasTable extends Cajas with TableInfo<$CajasTable, Caja> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CajasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
      'nombre', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _saldoInicialMeta =
      const VerificationMeta('saldoInicial');
  @override
  late final GeneratedColumn<double> saldoInicial = GeneratedColumn<double>(
      'saldo_inicial', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _saldoActualMeta =
      const VerificationMeta('saldoActual');
  @override
  late final GeneratedColumn<double> saldoActual = GeneratedColumn<double>(
      'saldo_actual', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _activaMeta = const VerificationMeta('activa');
  @override
  late final GeneratedColumn<bool> activa = GeneratedColumn<bool>(
      'activa', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activa" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _fechaCreacionMeta =
      const VerificationMeta('fechaCreacion');
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>('fecha_creacion', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _fechaActualizacionMeta =
      const VerificationMeta('fechaActualizacion');
  @override
  late final GeneratedColumn<DateTime> fechaActualizacion =
      GeneratedColumn<DateTime>('fecha_actualizacion', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nombre,
        tipo,
        descripcion,
        saldoInicial,
        saldoActual,
        activa,
        fechaCreacion,
        fechaActualizacion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cajas';
  @override
  VerificationContext validateIntegrity(Insertable<Caja> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(_nombreMeta,
          nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    }
    if (data.containsKey('saldo_inicial')) {
      context.handle(
          _saldoInicialMeta,
          saldoInicial.isAcceptableOrUnknown(
              data['saldo_inicial']!, _saldoInicialMeta));
    }
    if (data.containsKey('saldo_actual')) {
      context.handle(
          _saldoActualMeta,
          saldoActual.isAcceptableOrUnknown(
              data['saldo_actual']!, _saldoActualMeta));
    }
    if (data.containsKey('activa')) {
      context.handle(_activaMeta,
          activa.isAcceptableOrUnknown(data['activa']!, _activaMeta));
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
          _fechaCreacionMeta,
          fechaCreacion.isAcceptableOrUnknown(
              data['fecha_creacion']!, _fechaCreacionMeta));
    }
    if (data.containsKey('fecha_actualizacion')) {
      context.handle(
          _fechaActualizacionMeta,
          fechaActualizacion.isAcceptableOrUnknown(
              data['fecha_actualizacion']!, _fechaActualizacionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Caja map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Caja(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nombre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      saldoInicial: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}saldo_inicial'])!,
      saldoActual: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}saldo_actual'])!,
      activa: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activa'])!,
      fechaCreacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_creacion'])!,
      fechaActualizacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_actualizacion']),
    );
  }

  @override
  $CajasTable createAlias(String alias) {
    return $CajasTable(attachedDatabase, alias);
  }
}

class Caja extends DataClass implements Insertable<Caja> {
  final int id;
  final String nombre;
  final String tipo;
  final String? descripcion;
  final double saldoInicial;
  final double saldoActual;
  final bool activa;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  const Caja(
      {required this.id,
      required this.nombre,
      required this.tipo,
      this.descripcion,
      required this.saldoInicial,
      required this.saldoActual,
      required this.activa,
      required this.fechaCreacion,
      this.fechaActualizacion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['saldo_inicial'] = Variable<double>(saldoInicial);
    map['saldo_actual'] = Variable<double>(saldoActual);
    map['activa'] = Variable<bool>(activa);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    if (!nullToAbsent || fechaActualizacion != null) {
      map['fecha_actualizacion'] = Variable<DateTime>(fechaActualizacion);
    }
    return map;
  }

  CajasCompanion toCompanion(bool nullToAbsent) {
    return CajasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      tipo: Value(tipo),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      saldoInicial: Value(saldoInicial),
      saldoActual: Value(saldoActual),
      activa: Value(activa),
      fechaCreacion: Value(fechaCreacion),
      fechaActualizacion: fechaActualizacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaActualizacion),
    );
  }

  factory Caja.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Caja(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      tipo: serializer.fromJson<String>(json['tipo']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      saldoInicial: serializer.fromJson<double>(json['saldoInicial']),
      saldoActual: serializer.fromJson<double>(json['saldoActual']),
      activa: serializer.fromJson<bool>(json['activa']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
      fechaActualizacion:
          serializer.fromJson<DateTime?>(json['fechaActualizacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'tipo': serializer.toJson<String>(tipo),
      'descripcion': serializer.toJson<String?>(descripcion),
      'saldoInicial': serializer.toJson<double>(saldoInicial),
      'saldoActual': serializer.toJson<double>(saldoActual),
      'activa': serializer.toJson<bool>(activa),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
      'fechaActualizacion': serializer.toJson<DateTime?>(fechaActualizacion),
    };
  }

  Caja copyWith(
          {int? id,
          String? nombre,
          String? tipo,
          Value<String?> descripcion = const Value.absent(),
          double? saldoInicial,
          double? saldoActual,
          bool? activa,
          DateTime? fechaCreacion,
          Value<DateTime?> fechaActualizacion = const Value.absent()}) =>
      Caja(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        tipo: tipo ?? this.tipo,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        saldoInicial: saldoInicial ?? this.saldoInicial,
        saldoActual: saldoActual ?? this.saldoActual,
        activa: activa ?? this.activa,
        fechaCreacion: fechaCreacion ?? this.fechaCreacion,
        fechaActualizacion: fechaActualizacion.present
            ? fechaActualizacion.value
            : this.fechaActualizacion,
      );
  Caja copyWithCompanion(CajasCompanion data) {
    return Caja(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      saldoInicial: data.saldoInicial.present
          ? data.saldoInicial.value
          : this.saldoInicial,
      saldoActual:
          data.saldoActual.present ? data.saldoActual.value : this.saldoActual,
      activa: data.activa.present ? data.activa.value : this.activa,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
      fechaActualizacion: data.fechaActualizacion.present
          ? data.fechaActualizacion.value
          : this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Caja(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('descripcion: $descripcion, ')
          ..write('saldoInicial: $saldoInicial, ')
          ..write('saldoActual: $saldoActual, ')
          ..write('activa: $activa, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaActualizacion: $fechaActualizacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, tipo, descripcion, saldoInicial,
      saldoActual, activa, fechaCreacion, fechaActualizacion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Caja &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.tipo == this.tipo &&
          other.descripcion == this.descripcion &&
          other.saldoInicial == this.saldoInicial &&
          other.saldoActual == this.saldoActual &&
          other.activa == this.activa &&
          other.fechaCreacion == this.fechaCreacion &&
          other.fechaActualizacion == this.fechaActualizacion);
}

class CajasCompanion extends UpdateCompanion<Caja> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> tipo;
  final Value<String?> descripcion;
  final Value<double> saldoInicial;
  final Value<double> saldoActual;
  final Value<bool> activa;
  final Value<DateTime> fechaCreacion;
  final Value<DateTime?> fechaActualizacion;
  const CajasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.tipo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.saldoInicial = const Value.absent(),
    this.saldoActual = const Value.absent(),
    this.activa = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaActualizacion = const Value.absent(),
  });
  CajasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required String tipo,
    this.descripcion = const Value.absent(),
    this.saldoInicial = const Value.absent(),
    this.saldoActual = const Value.absent(),
    this.activa = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaActualizacion = const Value.absent(),
  })  : nombre = Value(nombre),
        tipo = Value(tipo);
  static Insertable<Caja> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? tipo,
    Expression<String>? descripcion,
    Expression<double>? saldoInicial,
    Expression<double>? saldoActual,
    Expression<bool>? activa,
    Expression<DateTime>? fechaCreacion,
    Expression<DateTime>? fechaActualizacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (tipo != null) 'tipo': tipo,
      if (descripcion != null) 'descripcion': descripcion,
      if (saldoInicial != null) 'saldo_inicial': saldoInicial,
      if (saldoActual != null) 'saldo_actual': saldoActual,
      if (activa != null) 'activa': activa,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      if (fechaActualizacion != null) 'fecha_actualizacion': fechaActualizacion,
    });
  }

  CajasCompanion copyWith(
      {Value<int>? id,
      Value<String>? nombre,
      Value<String>? tipo,
      Value<String?>? descripcion,
      Value<double>? saldoInicial,
      Value<double>? saldoActual,
      Value<bool>? activa,
      Value<DateTime>? fechaCreacion,
      Value<DateTime?>? fechaActualizacion}) {
    return CajasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      saldoInicial: saldoInicial ?? this.saldoInicial,
      saldoActual: saldoActual ?? this.saldoActual,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (saldoInicial.present) {
      map['saldo_inicial'] = Variable<double>(saldoInicial.value);
    }
    if (saldoActual.present) {
      map['saldo_actual'] = Variable<double>(saldoActual.value);
    }
    if (activa.present) {
      map['activa'] = Variable<bool>(activa.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    if (fechaActualizacion.present) {
      map['fecha_actualizacion'] = Variable<DateTime>(fechaActualizacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CajasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('tipo: $tipo, ')
          ..write('descripcion: $descripcion, ')
          ..write('saldoInicial: $saldoInicial, ')
          ..write('saldoActual: $saldoActual, ')
          ..write('activa: $activa, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaActualizacion: $fechaActualizacion')
          ..write(')'))
        .toString();
  }
}

class $PrestamosTable extends Prestamos
    with TableInfo<$PrestamosTable, Prestamo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrestamosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
      'codigo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _clienteIdMeta =
      const VerificationMeta('clienteId');
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
      'cliente_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES clientes (id)'));
  static const VerificationMeta _cajaIdMeta = const VerificationMeta('cajaId');
  @override
  late final GeneratedColumn<int> cajaId = GeneratedColumn<int>(
      'caja_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES cajas (id)'));
  static const VerificationMeta _montoOriginalMeta =
      const VerificationMeta('montoOriginal');
  @override
  late final GeneratedColumn<double> montoOriginal = GeneratedColumn<double>(
      'monto_original', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _montoTotalMeta =
      const VerificationMeta('montoTotal');
  @override
  late final GeneratedColumn<double> montoTotal = GeneratedColumn<double>(
      'monto_total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _saldoPendienteMeta =
      const VerificationMeta('saldoPendiente');
  @override
  late final GeneratedColumn<double> saldoPendiente = GeneratedColumn<double>(
      'saldo_pendiente', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tasaInteresMeta =
      const VerificationMeta('tasaInteres');
  @override
  late final GeneratedColumn<double> tasaInteres = GeneratedColumn<double>(
      'tasa_interes', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tipoInteresMeta =
      const VerificationMeta('tipoInteres');
  @override
  late final GeneratedColumn<String> tipoInteres = GeneratedColumn<String>(
      'tipo_interes', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _plazoMesesMeta =
      const VerificationMeta('plazoMeses');
  @override
  late final GeneratedColumn<int> plazoMeses = GeneratedColumn<int>(
      'plazo_meses', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cuotaMensualMeta =
      const VerificationMeta('cuotaMensual');
  @override
  late final GeneratedColumn<double> cuotaMensual = GeneratedColumn<double>(
      'cuota_mensual', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fechaInicioMeta =
      const VerificationMeta('fechaInicio');
  @override
  late final GeneratedColumn<DateTime> fechaInicio = GeneratedColumn<DateTime>(
      'fecha_inicio', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fechaVencimientoMeta =
      const VerificationMeta('fechaVencimiento');
  @override
  late final GeneratedColumn<DateTime> fechaVencimiento =
      GeneratedColumn<DateTime>('fecha_vencimiento', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaRegistroMeta =
      const VerificationMeta('fechaRegistro');
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>('fecha_registro', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _fechaActualizacionMeta =
      const VerificationMeta('fechaActualizacion');
  @override
  late final GeneratedColumn<DateTime> fechaActualizacion =
      GeneratedColumn<DateTime>('fecha_actualizacion', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        codigo,
        clienteId,
        cajaId,
        montoOriginal,
        montoTotal,
        saldoPendiente,
        tasaInteres,
        tipoInteres,
        plazoMeses,
        cuotaMensual,
        fechaInicio,
        fechaVencimiento,
        estado,
        observaciones,
        fechaRegistro,
        fechaActualizacion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prestamos';
  @override
  VerificationContext validateIntegrity(Insertable<Prestamo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo')) {
      context.handle(_codigoMeta,
          codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta));
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('cliente_id')) {
      context.handle(_clienteIdMeta,
          clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta));
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('caja_id')) {
      context.handle(_cajaIdMeta,
          cajaId.isAcceptableOrUnknown(data['caja_id']!, _cajaIdMeta));
    } else if (isInserting) {
      context.missing(_cajaIdMeta);
    }
    if (data.containsKey('monto_original')) {
      context.handle(
          _montoOriginalMeta,
          montoOriginal.isAcceptableOrUnknown(
              data['monto_original']!, _montoOriginalMeta));
    } else if (isInserting) {
      context.missing(_montoOriginalMeta);
    }
    if (data.containsKey('monto_total')) {
      context.handle(
          _montoTotalMeta,
          montoTotal.isAcceptableOrUnknown(
              data['monto_total']!, _montoTotalMeta));
    } else if (isInserting) {
      context.missing(_montoTotalMeta);
    }
    if (data.containsKey('saldo_pendiente')) {
      context.handle(
          _saldoPendienteMeta,
          saldoPendiente.isAcceptableOrUnknown(
              data['saldo_pendiente']!, _saldoPendienteMeta));
    } else if (isInserting) {
      context.missing(_saldoPendienteMeta);
    }
    if (data.containsKey('tasa_interes')) {
      context.handle(
          _tasaInteresMeta,
          tasaInteres.isAcceptableOrUnknown(
              data['tasa_interes']!, _tasaInteresMeta));
    } else if (isInserting) {
      context.missing(_tasaInteresMeta);
    }
    if (data.containsKey('tipo_interes')) {
      context.handle(
          _tipoInteresMeta,
          tipoInteres.isAcceptableOrUnknown(
              data['tipo_interes']!, _tipoInteresMeta));
    } else if (isInserting) {
      context.missing(_tipoInteresMeta);
    }
    if (data.containsKey('plazo_meses')) {
      context.handle(
          _plazoMesesMeta,
          plazoMeses.isAcceptableOrUnknown(
              data['plazo_meses']!, _plazoMesesMeta));
    } else if (isInserting) {
      context.missing(_plazoMesesMeta);
    }
    if (data.containsKey('cuota_mensual')) {
      context.handle(
          _cuotaMensualMeta,
          cuotaMensual.isAcceptableOrUnknown(
              data['cuota_mensual']!, _cuotaMensualMeta));
    } else if (isInserting) {
      context.missing(_cuotaMensualMeta);
    }
    if (data.containsKey('fecha_inicio')) {
      context.handle(
          _fechaInicioMeta,
          fechaInicio.isAcceptableOrUnknown(
              data['fecha_inicio']!, _fechaInicioMeta));
    } else if (isInserting) {
      context.missing(_fechaInicioMeta);
    }
    if (data.containsKey('fecha_vencimiento')) {
      context.handle(
          _fechaVencimientoMeta,
          fechaVencimiento.isAcceptableOrUnknown(
              data['fecha_vencimiento']!, _fechaVencimientoMeta));
    } else if (isInserting) {
      context.missing(_fechaVencimientoMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
          _fechaRegistroMeta,
          fechaRegistro.isAcceptableOrUnknown(
              data['fecha_registro']!, _fechaRegistroMeta));
    }
    if (data.containsKey('fecha_actualizacion')) {
      context.handle(
          _fechaActualizacionMeta,
          fechaActualizacion.isAcceptableOrUnknown(
              data['fecha_actualizacion']!, _fechaActualizacionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Prestamo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prestamo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      codigo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}codigo'])!,
      clienteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cliente_id'])!,
      cajaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}caja_id'])!,
      montoOriginal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_original'])!,
      montoTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_total'])!,
      saldoPendiente: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}saldo_pendiente'])!,
      tasaInteres: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tasa_interes'])!,
      tipoInteres: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_interes'])!,
      plazoMeses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plazo_meses'])!,
      cuotaMensual: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cuota_mensual'])!,
      fechaInicio: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha_inicio'])!,
      fechaVencimiento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_vencimiento'])!,
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
      fechaRegistro: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_registro'])!,
      fechaActualizacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_actualizacion']),
    );
  }

  @override
  $PrestamosTable createAlias(String alias) {
    return $PrestamosTable(attachedDatabase, alias);
  }
}

class Prestamo extends DataClass implements Insertable<Prestamo> {
  final int id;
  final String codigo;
  final int clienteId;
  final int cajaId;
  final double montoOriginal;
  final double montoTotal;
  final double saldoPendiente;
  final double tasaInteres;
  final String tipoInteres;
  final int plazoMeses;
  final double cuotaMensual;
  final DateTime fechaInicio;
  final DateTime fechaVencimiento;
  final String estado;
  final String? observaciones;
  final DateTime fechaRegistro;
  final DateTime? fechaActualizacion;
  const Prestamo(
      {required this.id,
      required this.codigo,
      required this.clienteId,
      required this.cajaId,
      required this.montoOriginal,
      required this.montoTotal,
      required this.saldoPendiente,
      required this.tasaInteres,
      required this.tipoInteres,
      required this.plazoMeses,
      required this.cuotaMensual,
      required this.fechaInicio,
      required this.fechaVencimiento,
      required this.estado,
      this.observaciones,
      required this.fechaRegistro,
      this.fechaActualizacion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo'] = Variable<String>(codigo);
    map['cliente_id'] = Variable<int>(clienteId);
    map['caja_id'] = Variable<int>(cajaId);
    map['monto_original'] = Variable<double>(montoOriginal);
    map['monto_total'] = Variable<double>(montoTotal);
    map['saldo_pendiente'] = Variable<double>(saldoPendiente);
    map['tasa_interes'] = Variable<double>(tasaInteres);
    map['tipo_interes'] = Variable<String>(tipoInteres);
    map['plazo_meses'] = Variable<int>(plazoMeses);
    map['cuota_mensual'] = Variable<double>(cuotaMensual);
    map['fecha_inicio'] = Variable<DateTime>(fechaInicio);
    map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    if (!nullToAbsent || fechaActualizacion != null) {
      map['fecha_actualizacion'] = Variable<DateTime>(fechaActualizacion);
    }
    return map;
  }

  PrestamosCompanion toCompanion(bool nullToAbsent) {
    return PrestamosCompanion(
      id: Value(id),
      codigo: Value(codigo),
      clienteId: Value(clienteId),
      cajaId: Value(cajaId),
      montoOriginal: Value(montoOriginal),
      montoTotal: Value(montoTotal),
      saldoPendiente: Value(saldoPendiente),
      tasaInteres: Value(tasaInteres),
      tipoInteres: Value(tipoInteres),
      plazoMeses: Value(plazoMeses),
      cuotaMensual: Value(cuotaMensual),
      fechaInicio: Value(fechaInicio),
      fechaVencimiento: Value(fechaVencimiento),
      estado: Value(estado),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      fechaRegistro: Value(fechaRegistro),
      fechaActualizacion: fechaActualizacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaActualizacion),
    );
  }

  factory Prestamo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prestamo(
      id: serializer.fromJson<int>(json['id']),
      codigo: serializer.fromJson<String>(json['codigo']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      cajaId: serializer.fromJson<int>(json['cajaId']),
      montoOriginal: serializer.fromJson<double>(json['montoOriginal']),
      montoTotal: serializer.fromJson<double>(json['montoTotal']),
      saldoPendiente: serializer.fromJson<double>(json['saldoPendiente']),
      tasaInteres: serializer.fromJson<double>(json['tasaInteres']),
      tipoInteres: serializer.fromJson<String>(json['tipoInteres']),
      plazoMeses: serializer.fromJson<int>(json['plazoMeses']),
      cuotaMensual: serializer.fromJson<double>(json['cuotaMensual']),
      fechaInicio: serializer.fromJson<DateTime>(json['fechaInicio']),
      fechaVencimiento: serializer.fromJson<DateTime>(json['fechaVencimiento']),
      estado: serializer.fromJson<String>(json['estado']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
      fechaActualizacion:
          serializer.fromJson<DateTime?>(json['fechaActualizacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigo': serializer.toJson<String>(codigo),
      'clienteId': serializer.toJson<int>(clienteId),
      'cajaId': serializer.toJson<int>(cajaId),
      'montoOriginal': serializer.toJson<double>(montoOriginal),
      'montoTotal': serializer.toJson<double>(montoTotal),
      'saldoPendiente': serializer.toJson<double>(saldoPendiente),
      'tasaInteres': serializer.toJson<double>(tasaInteres),
      'tipoInteres': serializer.toJson<String>(tipoInteres),
      'plazoMeses': serializer.toJson<int>(plazoMeses),
      'cuotaMensual': serializer.toJson<double>(cuotaMensual),
      'fechaInicio': serializer.toJson<DateTime>(fechaInicio),
      'fechaVencimiento': serializer.toJson<DateTime>(fechaVencimiento),
      'estado': serializer.toJson<String>(estado),
      'observaciones': serializer.toJson<String?>(observaciones),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
      'fechaActualizacion': serializer.toJson<DateTime?>(fechaActualizacion),
    };
  }

  Prestamo copyWith(
          {int? id,
          String? codigo,
          int? clienteId,
          int? cajaId,
          double? montoOriginal,
          double? montoTotal,
          double? saldoPendiente,
          double? tasaInteres,
          String? tipoInteres,
          int? plazoMeses,
          double? cuotaMensual,
          DateTime? fechaInicio,
          DateTime? fechaVencimiento,
          String? estado,
          Value<String?> observaciones = const Value.absent(),
          DateTime? fechaRegistro,
          Value<DateTime?> fechaActualizacion = const Value.absent()}) =>
      Prestamo(
        id: id ?? this.id,
        codigo: codigo ?? this.codigo,
        clienteId: clienteId ?? this.clienteId,
        cajaId: cajaId ?? this.cajaId,
        montoOriginal: montoOriginal ?? this.montoOriginal,
        montoTotal: montoTotal ?? this.montoTotal,
        saldoPendiente: saldoPendiente ?? this.saldoPendiente,
        tasaInteres: tasaInteres ?? this.tasaInteres,
        tipoInteres: tipoInteres ?? this.tipoInteres,
        plazoMeses: plazoMeses ?? this.plazoMeses,
        cuotaMensual: cuotaMensual ?? this.cuotaMensual,
        fechaInicio: fechaInicio ?? this.fechaInicio,
        fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
        estado: estado ?? this.estado,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
        fechaActualizacion: fechaActualizacion.present
            ? fechaActualizacion.value
            : this.fechaActualizacion,
      );
  Prestamo copyWithCompanion(PrestamosCompanion data) {
    return Prestamo(
      id: data.id.present ? data.id.value : this.id,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      cajaId: data.cajaId.present ? data.cajaId.value : this.cajaId,
      montoOriginal: data.montoOriginal.present
          ? data.montoOriginal.value
          : this.montoOriginal,
      montoTotal:
          data.montoTotal.present ? data.montoTotal.value : this.montoTotal,
      saldoPendiente: data.saldoPendiente.present
          ? data.saldoPendiente.value
          : this.saldoPendiente,
      tasaInteres:
          data.tasaInteres.present ? data.tasaInteres.value : this.tasaInteres,
      tipoInteres:
          data.tipoInteres.present ? data.tipoInteres.value : this.tipoInteres,
      plazoMeses:
          data.plazoMeses.present ? data.plazoMeses.value : this.plazoMeses,
      cuotaMensual: data.cuotaMensual.present
          ? data.cuotaMensual.value
          : this.cuotaMensual,
      fechaInicio:
          data.fechaInicio.present ? data.fechaInicio.value : this.fechaInicio,
      fechaVencimiento: data.fechaVencimiento.present
          ? data.fechaVencimiento.value
          : this.fechaVencimiento,
      estado: data.estado.present ? data.estado.value : this.estado,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
      fechaActualizacion: data.fechaActualizacion.present
          ? data.fechaActualizacion.value
          : this.fechaActualizacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prestamo(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('clienteId: $clienteId, ')
          ..write('cajaId: $cajaId, ')
          ..write('montoOriginal: $montoOriginal, ')
          ..write('montoTotal: $montoTotal, ')
          ..write('saldoPendiente: $saldoPendiente, ')
          ..write('tasaInteres: $tasaInteres, ')
          ..write('tipoInteres: $tipoInteres, ')
          ..write('plazoMeses: $plazoMeses, ')
          ..write('cuotaMensual: $cuotaMensual, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('estado: $estado, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('fechaActualizacion: $fechaActualizacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      codigo,
      clienteId,
      cajaId,
      montoOriginal,
      montoTotal,
      saldoPendiente,
      tasaInteres,
      tipoInteres,
      plazoMeses,
      cuotaMensual,
      fechaInicio,
      fechaVencimiento,
      estado,
      observaciones,
      fechaRegistro,
      fechaActualizacion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prestamo &&
          other.id == this.id &&
          other.codigo == this.codigo &&
          other.clienteId == this.clienteId &&
          other.cajaId == this.cajaId &&
          other.montoOriginal == this.montoOriginal &&
          other.montoTotal == this.montoTotal &&
          other.saldoPendiente == this.saldoPendiente &&
          other.tasaInteres == this.tasaInteres &&
          other.tipoInteres == this.tipoInteres &&
          other.plazoMeses == this.plazoMeses &&
          other.cuotaMensual == this.cuotaMensual &&
          other.fechaInicio == this.fechaInicio &&
          other.fechaVencimiento == this.fechaVencimiento &&
          other.estado == this.estado &&
          other.observaciones == this.observaciones &&
          other.fechaRegistro == this.fechaRegistro &&
          other.fechaActualizacion == this.fechaActualizacion);
}

class PrestamosCompanion extends UpdateCompanion<Prestamo> {
  final Value<int> id;
  final Value<String> codigo;
  final Value<int> clienteId;
  final Value<int> cajaId;
  final Value<double> montoOriginal;
  final Value<double> montoTotal;
  final Value<double> saldoPendiente;
  final Value<double> tasaInteres;
  final Value<String> tipoInteres;
  final Value<int> plazoMeses;
  final Value<double> cuotaMensual;
  final Value<DateTime> fechaInicio;
  final Value<DateTime> fechaVencimiento;
  final Value<String> estado;
  final Value<String?> observaciones;
  final Value<DateTime> fechaRegistro;
  final Value<DateTime?> fechaActualizacion;
  const PrestamosCompanion({
    this.id = const Value.absent(),
    this.codigo = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.cajaId = const Value.absent(),
    this.montoOriginal = const Value.absent(),
    this.montoTotal = const Value.absent(),
    this.saldoPendiente = const Value.absent(),
    this.tasaInteres = const Value.absent(),
    this.tipoInteres = const Value.absent(),
    this.plazoMeses = const Value.absent(),
    this.cuotaMensual = const Value.absent(),
    this.fechaInicio = const Value.absent(),
    this.fechaVencimiento = const Value.absent(),
    this.estado = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
    this.fechaActualizacion = const Value.absent(),
  });
  PrestamosCompanion.insert({
    this.id = const Value.absent(),
    required String codigo,
    required int clienteId,
    required int cajaId,
    required double montoOriginal,
    required double montoTotal,
    required double saldoPendiente,
    required double tasaInteres,
    required String tipoInteres,
    required int plazoMeses,
    required double cuotaMensual,
    required DateTime fechaInicio,
    required DateTime fechaVencimiento,
    required String estado,
    this.observaciones = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
    this.fechaActualizacion = const Value.absent(),
  })  : codigo = Value(codigo),
        clienteId = Value(clienteId),
        cajaId = Value(cajaId),
        montoOriginal = Value(montoOriginal),
        montoTotal = Value(montoTotal),
        saldoPendiente = Value(saldoPendiente),
        tasaInteres = Value(tasaInteres),
        tipoInteres = Value(tipoInteres),
        plazoMeses = Value(plazoMeses),
        cuotaMensual = Value(cuotaMensual),
        fechaInicio = Value(fechaInicio),
        fechaVencimiento = Value(fechaVencimiento),
        estado = Value(estado);
  static Insertable<Prestamo> custom({
    Expression<int>? id,
    Expression<String>? codigo,
    Expression<int>? clienteId,
    Expression<int>? cajaId,
    Expression<double>? montoOriginal,
    Expression<double>? montoTotal,
    Expression<double>? saldoPendiente,
    Expression<double>? tasaInteres,
    Expression<String>? tipoInteres,
    Expression<int>? plazoMeses,
    Expression<double>? cuotaMensual,
    Expression<DateTime>? fechaInicio,
    Expression<DateTime>? fechaVencimiento,
    Expression<String>? estado,
    Expression<String>? observaciones,
    Expression<DateTime>? fechaRegistro,
    Expression<DateTime>? fechaActualizacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigo != null) 'codigo': codigo,
      if (clienteId != null) 'cliente_id': clienteId,
      if (cajaId != null) 'caja_id': cajaId,
      if (montoOriginal != null) 'monto_original': montoOriginal,
      if (montoTotal != null) 'monto_total': montoTotal,
      if (saldoPendiente != null) 'saldo_pendiente': saldoPendiente,
      if (tasaInteres != null) 'tasa_interes': tasaInteres,
      if (tipoInteres != null) 'tipo_interes': tipoInteres,
      if (plazoMeses != null) 'plazo_meses': plazoMeses,
      if (cuotaMensual != null) 'cuota_mensual': cuotaMensual,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio,
      if (fechaVencimiento != null) 'fecha_vencimiento': fechaVencimiento,
      if (estado != null) 'estado': estado,
      if (observaciones != null) 'observaciones': observaciones,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
      if (fechaActualizacion != null) 'fecha_actualizacion': fechaActualizacion,
    });
  }

  PrestamosCompanion copyWith(
      {Value<int>? id,
      Value<String>? codigo,
      Value<int>? clienteId,
      Value<int>? cajaId,
      Value<double>? montoOriginal,
      Value<double>? montoTotal,
      Value<double>? saldoPendiente,
      Value<double>? tasaInteres,
      Value<String>? tipoInteres,
      Value<int>? plazoMeses,
      Value<double>? cuotaMensual,
      Value<DateTime>? fechaInicio,
      Value<DateTime>? fechaVencimiento,
      Value<String>? estado,
      Value<String?>? observaciones,
      Value<DateTime>? fechaRegistro,
      Value<DateTime?>? fechaActualizacion}) {
    return PrestamosCompanion(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      clienteId: clienteId ?? this.clienteId,
      cajaId: cajaId ?? this.cajaId,
      montoOriginal: montoOriginal ?? this.montoOriginal,
      montoTotal: montoTotal ?? this.montoTotal,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      tasaInteres: tasaInteres ?? this.tasaInteres,
      tipoInteres: tipoInteres ?? this.tipoInteres,
      plazoMeses: plazoMeses ?? this.plazoMeses,
      cuotaMensual: cuotaMensual ?? this.cuotaMensual,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (cajaId.present) {
      map['caja_id'] = Variable<int>(cajaId.value);
    }
    if (montoOriginal.present) {
      map['monto_original'] = Variable<double>(montoOriginal.value);
    }
    if (montoTotal.present) {
      map['monto_total'] = Variable<double>(montoTotal.value);
    }
    if (saldoPendiente.present) {
      map['saldo_pendiente'] = Variable<double>(saldoPendiente.value);
    }
    if (tasaInteres.present) {
      map['tasa_interes'] = Variable<double>(tasaInteres.value);
    }
    if (tipoInteres.present) {
      map['tipo_interes'] = Variable<String>(tipoInteres.value);
    }
    if (plazoMeses.present) {
      map['plazo_meses'] = Variable<int>(plazoMeses.value);
    }
    if (cuotaMensual.present) {
      map['cuota_mensual'] = Variable<double>(cuotaMensual.value);
    }
    if (fechaInicio.present) {
      map['fecha_inicio'] = Variable<DateTime>(fechaInicio.value);
    }
    if (fechaVencimiento.present) {
      map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    if (fechaActualizacion.present) {
      map['fecha_actualizacion'] = Variable<DateTime>(fechaActualizacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrestamosCompanion(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('clienteId: $clienteId, ')
          ..write('cajaId: $cajaId, ')
          ..write('montoOriginal: $montoOriginal, ')
          ..write('montoTotal: $montoTotal, ')
          ..write('saldoPendiente: $saldoPendiente, ')
          ..write('tasaInteres: $tasaInteres, ')
          ..write('tipoInteres: $tipoInteres, ')
          ..write('plazoMeses: $plazoMeses, ')
          ..write('cuotaMensual: $cuotaMensual, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('estado: $estado, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaRegistro: $fechaRegistro, ')
          ..write('fechaActualizacion: $fechaActualizacion')
          ..write(')'))
        .toString();
  }
}

class $CuotasTable extends Cuotas with TableInfo<$CuotasTable, Cuota> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CuotasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _prestamoIdMeta =
      const VerificationMeta('prestamoId');
  @override
  late final GeneratedColumn<int> prestamoId = GeneratedColumn<int>(
      'prestamo_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES prestamos (id) ON DELETE CASCADE'));
  static const VerificationMeta _numeroCuotaMeta =
      const VerificationMeta('numeroCuota');
  @override
  late final GeneratedColumn<int> numeroCuota = GeneratedColumn<int>(
      'numero_cuota', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fechaVencimientoMeta =
      const VerificationMeta('fechaVencimiento');
  @override
  late final GeneratedColumn<DateTime> fechaVencimiento =
      GeneratedColumn<DateTime>('fecha_vencimiento', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _montoCuotaMeta =
      const VerificationMeta('montoCuota');
  @override
  late final GeneratedColumn<double> montoCuota = GeneratedColumn<double>(
      'monto_cuota', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _capitalMeta =
      const VerificationMeta('capital');
  @override
  late final GeneratedColumn<double> capital = GeneratedColumn<double>(
      'capital', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _interesMeta =
      const VerificationMeta('interes');
  @override
  late final GeneratedColumn<double> interes = GeneratedColumn<double>(
      'interes', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _saldoPendienteMeta =
      const VerificationMeta('saldoPendiente');
  @override
  late final GeneratedColumn<double> saldoPendiente = GeneratedColumn<double>(
      'saldo_pendiente', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _montoPagadoMeta =
      const VerificationMeta('montoPagado');
  @override
  late final GeneratedColumn<double> montoPagado = GeneratedColumn<double>(
      'monto_pagado', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _montoMoraMeta =
      const VerificationMeta('montoMora');
  @override
  late final GeneratedColumn<double> montoMora = GeneratedColumn<double>(
      'monto_mora', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
      'estado', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _fechaPagoMeta =
      const VerificationMeta('fechaPago');
  @override
  late final GeneratedColumn<DateTime> fechaPago = GeneratedColumn<DateTime>(
      'fecha_pago', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _fechaRegistroMeta =
      const VerificationMeta('fechaRegistro');
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>('fecha_registro', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        prestamoId,
        numeroCuota,
        fechaVencimiento,
        montoCuota,
        capital,
        interes,
        saldoPendiente,
        montoPagado,
        montoMora,
        estado,
        fechaPago,
        fechaRegistro
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cuotas';
  @override
  VerificationContext validateIntegrity(Insertable<Cuota> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prestamo_id')) {
      context.handle(
          _prestamoIdMeta,
          prestamoId.isAcceptableOrUnknown(
              data['prestamo_id']!, _prestamoIdMeta));
    } else if (isInserting) {
      context.missing(_prestamoIdMeta);
    }
    if (data.containsKey('numero_cuota')) {
      context.handle(
          _numeroCuotaMeta,
          numeroCuota.isAcceptableOrUnknown(
              data['numero_cuota']!, _numeroCuotaMeta));
    } else if (isInserting) {
      context.missing(_numeroCuotaMeta);
    }
    if (data.containsKey('fecha_vencimiento')) {
      context.handle(
          _fechaVencimientoMeta,
          fechaVencimiento.isAcceptableOrUnknown(
              data['fecha_vencimiento']!, _fechaVencimientoMeta));
    } else if (isInserting) {
      context.missing(_fechaVencimientoMeta);
    }
    if (data.containsKey('monto_cuota')) {
      context.handle(
          _montoCuotaMeta,
          montoCuota.isAcceptableOrUnknown(
              data['monto_cuota']!, _montoCuotaMeta));
    } else if (isInserting) {
      context.missing(_montoCuotaMeta);
    }
    if (data.containsKey('capital')) {
      context.handle(_capitalMeta,
          capital.isAcceptableOrUnknown(data['capital']!, _capitalMeta));
    } else if (isInserting) {
      context.missing(_capitalMeta);
    }
    if (data.containsKey('interes')) {
      context.handle(_interesMeta,
          interes.isAcceptableOrUnknown(data['interes']!, _interesMeta));
    } else if (isInserting) {
      context.missing(_interesMeta);
    }
    if (data.containsKey('saldo_pendiente')) {
      context.handle(
          _saldoPendienteMeta,
          saldoPendiente.isAcceptableOrUnknown(
              data['saldo_pendiente']!, _saldoPendienteMeta));
    } else if (isInserting) {
      context.missing(_saldoPendienteMeta);
    }
    if (data.containsKey('monto_pagado')) {
      context.handle(
          _montoPagadoMeta,
          montoPagado.isAcceptableOrUnknown(
              data['monto_pagado']!, _montoPagadoMeta));
    }
    if (data.containsKey('monto_mora')) {
      context.handle(_montoMoraMeta,
          montoMora.isAcceptableOrUnknown(data['monto_mora']!, _montoMoraMeta));
    }
    if (data.containsKey('estado')) {
      context.handle(_estadoMeta,
          estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta));
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('fecha_pago')) {
      context.handle(_fechaPagoMeta,
          fechaPago.isAcceptableOrUnknown(data['fecha_pago']!, _fechaPagoMeta));
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
          _fechaRegistroMeta,
          fechaRegistro.isAcceptableOrUnknown(
              data['fecha_registro']!, _fechaRegistroMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cuota map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cuota(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      prestamoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prestamo_id'])!,
      numeroCuota: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}numero_cuota'])!,
      fechaVencimiento: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_vencimiento'])!,
      montoCuota: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_cuota'])!,
      capital: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}capital'])!,
      interes: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}interes'])!,
      saldoPendiente: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}saldo_pendiente'])!,
      montoPagado: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_pagado'])!,
      montoMora: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_mora'])!,
      estado: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}estado'])!,
      fechaPago: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha_pago']),
      fechaRegistro: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_registro'])!,
    );
  }

  @override
  $CuotasTable createAlias(String alias) {
    return $CuotasTable(attachedDatabase, alias);
  }
}

class Cuota extends DataClass implements Insertable<Cuota> {
  final int id;
  final int prestamoId;
  final int numeroCuota;
  final DateTime fechaVencimiento;
  final double montoCuota;
  final double capital;
  final double interes;
  final double saldoPendiente;
  final double montoPagado;
  final double montoMora;
  final String estado;
  final DateTime? fechaPago;
  final DateTime fechaRegistro;
  const Cuota(
      {required this.id,
      required this.prestamoId,
      required this.numeroCuota,
      required this.fechaVencimiento,
      required this.montoCuota,
      required this.capital,
      required this.interes,
      required this.saldoPendiente,
      required this.montoPagado,
      required this.montoMora,
      required this.estado,
      this.fechaPago,
      required this.fechaRegistro});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prestamo_id'] = Variable<int>(prestamoId);
    map['numero_cuota'] = Variable<int>(numeroCuota);
    map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento);
    map['monto_cuota'] = Variable<double>(montoCuota);
    map['capital'] = Variable<double>(capital);
    map['interes'] = Variable<double>(interes);
    map['saldo_pendiente'] = Variable<double>(saldoPendiente);
    map['monto_pagado'] = Variable<double>(montoPagado);
    map['monto_mora'] = Variable<double>(montoMora);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || fechaPago != null) {
      map['fecha_pago'] = Variable<DateTime>(fechaPago);
    }
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    return map;
  }

  CuotasCompanion toCompanion(bool nullToAbsent) {
    return CuotasCompanion(
      id: Value(id),
      prestamoId: Value(prestamoId),
      numeroCuota: Value(numeroCuota),
      fechaVencimiento: Value(fechaVencimiento),
      montoCuota: Value(montoCuota),
      capital: Value(capital),
      interes: Value(interes),
      saldoPendiente: Value(saldoPendiente),
      montoPagado: Value(montoPagado),
      montoMora: Value(montoMora),
      estado: Value(estado),
      fechaPago: fechaPago == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaPago),
      fechaRegistro: Value(fechaRegistro),
    );
  }

  factory Cuota.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cuota(
      id: serializer.fromJson<int>(json['id']),
      prestamoId: serializer.fromJson<int>(json['prestamoId']),
      numeroCuota: serializer.fromJson<int>(json['numeroCuota']),
      fechaVencimiento: serializer.fromJson<DateTime>(json['fechaVencimiento']),
      montoCuota: serializer.fromJson<double>(json['montoCuota']),
      capital: serializer.fromJson<double>(json['capital']),
      interes: serializer.fromJson<double>(json['interes']),
      saldoPendiente: serializer.fromJson<double>(json['saldoPendiente']),
      montoPagado: serializer.fromJson<double>(json['montoPagado']),
      montoMora: serializer.fromJson<double>(json['montoMora']),
      estado: serializer.fromJson<String>(json['estado']),
      fechaPago: serializer.fromJson<DateTime?>(json['fechaPago']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prestamoId': serializer.toJson<int>(prestamoId),
      'numeroCuota': serializer.toJson<int>(numeroCuota),
      'fechaVencimiento': serializer.toJson<DateTime>(fechaVencimiento),
      'montoCuota': serializer.toJson<double>(montoCuota),
      'capital': serializer.toJson<double>(capital),
      'interes': serializer.toJson<double>(interes),
      'saldoPendiente': serializer.toJson<double>(saldoPendiente),
      'montoPagado': serializer.toJson<double>(montoPagado),
      'montoMora': serializer.toJson<double>(montoMora),
      'estado': serializer.toJson<String>(estado),
      'fechaPago': serializer.toJson<DateTime?>(fechaPago),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
    };
  }

  Cuota copyWith(
          {int? id,
          int? prestamoId,
          int? numeroCuota,
          DateTime? fechaVencimiento,
          double? montoCuota,
          double? capital,
          double? interes,
          double? saldoPendiente,
          double? montoPagado,
          double? montoMora,
          String? estado,
          Value<DateTime?> fechaPago = const Value.absent(),
          DateTime? fechaRegistro}) =>
      Cuota(
        id: id ?? this.id,
        prestamoId: prestamoId ?? this.prestamoId,
        numeroCuota: numeroCuota ?? this.numeroCuota,
        fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
        montoCuota: montoCuota ?? this.montoCuota,
        capital: capital ?? this.capital,
        interes: interes ?? this.interes,
        saldoPendiente: saldoPendiente ?? this.saldoPendiente,
        montoPagado: montoPagado ?? this.montoPagado,
        montoMora: montoMora ?? this.montoMora,
        estado: estado ?? this.estado,
        fechaPago: fechaPago.present ? fechaPago.value : this.fechaPago,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );
  Cuota copyWithCompanion(CuotasCompanion data) {
    return Cuota(
      id: data.id.present ? data.id.value : this.id,
      prestamoId:
          data.prestamoId.present ? data.prestamoId.value : this.prestamoId,
      numeroCuota:
          data.numeroCuota.present ? data.numeroCuota.value : this.numeroCuota,
      fechaVencimiento: data.fechaVencimiento.present
          ? data.fechaVencimiento.value
          : this.fechaVencimiento,
      montoCuota:
          data.montoCuota.present ? data.montoCuota.value : this.montoCuota,
      capital: data.capital.present ? data.capital.value : this.capital,
      interes: data.interes.present ? data.interes.value : this.interes,
      saldoPendiente: data.saldoPendiente.present
          ? data.saldoPendiente.value
          : this.saldoPendiente,
      montoPagado:
          data.montoPagado.present ? data.montoPagado.value : this.montoPagado,
      montoMora: data.montoMora.present ? data.montoMora.value : this.montoMora,
      estado: data.estado.present ? data.estado.value : this.estado,
      fechaPago: data.fechaPago.present ? data.fechaPago.value : this.fechaPago,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cuota(')
          ..write('id: $id, ')
          ..write('prestamoId: $prestamoId, ')
          ..write('numeroCuota: $numeroCuota, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('montoCuota: $montoCuota, ')
          ..write('capital: $capital, ')
          ..write('interes: $interes, ')
          ..write('saldoPendiente: $saldoPendiente, ')
          ..write('montoPagado: $montoPagado, ')
          ..write('montoMora: $montoMora, ')
          ..write('estado: $estado, ')
          ..write('fechaPago: $fechaPago, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      prestamoId,
      numeroCuota,
      fechaVencimiento,
      montoCuota,
      capital,
      interes,
      saldoPendiente,
      montoPagado,
      montoMora,
      estado,
      fechaPago,
      fechaRegistro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cuota &&
          other.id == this.id &&
          other.prestamoId == this.prestamoId &&
          other.numeroCuota == this.numeroCuota &&
          other.fechaVencimiento == this.fechaVencimiento &&
          other.montoCuota == this.montoCuota &&
          other.capital == this.capital &&
          other.interes == this.interes &&
          other.saldoPendiente == this.saldoPendiente &&
          other.montoPagado == this.montoPagado &&
          other.montoMora == this.montoMora &&
          other.estado == this.estado &&
          other.fechaPago == this.fechaPago &&
          other.fechaRegistro == this.fechaRegistro);
}

class CuotasCompanion extends UpdateCompanion<Cuota> {
  final Value<int> id;
  final Value<int> prestamoId;
  final Value<int> numeroCuota;
  final Value<DateTime> fechaVencimiento;
  final Value<double> montoCuota;
  final Value<double> capital;
  final Value<double> interes;
  final Value<double> saldoPendiente;
  final Value<double> montoPagado;
  final Value<double> montoMora;
  final Value<String> estado;
  final Value<DateTime?> fechaPago;
  final Value<DateTime> fechaRegistro;
  const CuotasCompanion({
    this.id = const Value.absent(),
    this.prestamoId = const Value.absent(),
    this.numeroCuota = const Value.absent(),
    this.fechaVencimiento = const Value.absent(),
    this.montoCuota = const Value.absent(),
    this.capital = const Value.absent(),
    this.interes = const Value.absent(),
    this.saldoPendiente = const Value.absent(),
    this.montoPagado = const Value.absent(),
    this.montoMora = const Value.absent(),
    this.estado = const Value.absent(),
    this.fechaPago = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  });
  CuotasCompanion.insert({
    this.id = const Value.absent(),
    required int prestamoId,
    required int numeroCuota,
    required DateTime fechaVencimiento,
    required double montoCuota,
    required double capital,
    required double interes,
    required double saldoPendiente,
    this.montoPagado = const Value.absent(),
    this.montoMora = const Value.absent(),
    required String estado,
    this.fechaPago = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  })  : prestamoId = Value(prestamoId),
        numeroCuota = Value(numeroCuota),
        fechaVencimiento = Value(fechaVencimiento),
        montoCuota = Value(montoCuota),
        capital = Value(capital),
        interes = Value(interes),
        saldoPendiente = Value(saldoPendiente),
        estado = Value(estado);
  static Insertable<Cuota> custom({
    Expression<int>? id,
    Expression<int>? prestamoId,
    Expression<int>? numeroCuota,
    Expression<DateTime>? fechaVencimiento,
    Expression<double>? montoCuota,
    Expression<double>? capital,
    Expression<double>? interes,
    Expression<double>? saldoPendiente,
    Expression<double>? montoPagado,
    Expression<double>? montoMora,
    Expression<String>? estado,
    Expression<DateTime>? fechaPago,
    Expression<DateTime>? fechaRegistro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prestamoId != null) 'prestamo_id': prestamoId,
      if (numeroCuota != null) 'numero_cuota': numeroCuota,
      if (fechaVencimiento != null) 'fecha_vencimiento': fechaVencimiento,
      if (montoCuota != null) 'monto_cuota': montoCuota,
      if (capital != null) 'capital': capital,
      if (interes != null) 'interes': interes,
      if (saldoPendiente != null) 'saldo_pendiente': saldoPendiente,
      if (montoPagado != null) 'monto_pagado': montoPagado,
      if (montoMora != null) 'monto_mora': montoMora,
      if (estado != null) 'estado': estado,
      if (fechaPago != null) 'fecha_pago': fechaPago,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
    });
  }

  CuotasCompanion copyWith(
      {Value<int>? id,
      Value<int>? prestamoId,
      Value<int>? numeroCuota,
      Value<DateTime>? fechaVencimiento,
      Value<double>? montoCuota,
      Value<double>? capital,
      Value<double>? interes,
      Value<double>? saldoPendiente,
      Value<double>? montoPagado,
      Value<double>? montoMora,
      Value<String>? estado,
      Value<DateTime?>? fechaPago,
      Value<DateTime>? fechaRegistro}) {
    return CuotasCompanion(
      id: id ?? this.id,
      prestamoId: prestamoId ?? this.prestamoId,
      numeroCuota: numeroCuota ?? this.numeroCuota,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      montoCuota: montoCuota ?? this.montoCuota,
      capital: capital ?? this.capital,
      interes: interes ?? this.interes,
      saldoPendiente: saldoPendiente ?? this.saldoPendiente,
      montoPagado: montoPagado ?? this.montoPagado,
      montoMora: montoMora ?? this.montoMora,
      estado: estado ?? this.estado,
      fechaPago: fechaPago ?? this.fechaPago,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (prestamoId.present) {
      map['prestamo_id'] = Variable<int>(prestamoId.value);
    }
    if (numeroCuota.present) {
      map['numero_cuota'] = Variable<int>(numeroCuota.value);
    }
    if (fechaVencimiento.present) {
      map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento.value);
    }
    if (montoCuota.present) {
      map['monto_cuota'] = Variable<double>(montoCuota.value);
    }
    if (capital.present) {
      map['capital'] = Variable<double>(capital.value);
    }
    if (interes.present) {
      map['interes'] = Variable<double>(interes.value);
    }
    if (saldoPendiente.present) {
      map['saldo_pendiente'] = Variable<double>(saldoPendiente.value);
    }
    if (montoPagado.present) {
      map['monto_pagado'] = Variable<double>(montoPagado.value);
    }
    if (montoMora.present) {
      map['monto_mora'] = Variable<double>(montoMora.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (fechaPago.present) {
      map['fecha_pago'] = Variable<DateTime>(fechaPago.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CuotasCompanion(')
          ..write('id: $id, ')
          ..write('prestamoId: $prestamoId, ')
          ..write('numeroCuota: $numeroCuota, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('montoCuota: $montoCuota, ')
          ..write('capital: $capital, ')
          ..write('interes: $interes, ')
          ..write('saldoPendiente: $saldoPendiente, ')
          ..write('montoPagado: $montoPagado, ')
          ..write('montoMora: $montoMora, ')
          ..write('estado: $estado, ')
          ..write('fechaPago: $fechaPago, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }
}

class $PagosTable extends Pagos with TableInfo<$PagosTable, Pago> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
      'codigo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _prestamoIdMeta =
      const VerificationMeta('prestamoId');
  @override
  late final GeneratedColumn<int> prestamoId = GeneratedColumn<int>(
      'prestamo_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES prestamos (id)'));
  static const VerificationMeta _clienteIdMeta =
      const VerificationMeta('clienteId');
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
      'cliente_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES clientes (id)'));
  static const VerificationMeta _cajaIdMeta = const VerificationMeta('cajaId');
  @override
  late final GeneratedColumn<int> cajaId = GeneratedColumn<int>(
      'caja_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES cajas (id)'));
  static const VerificationMeta _montoPagoMeta =
      const VerificationMeta('montoPago');
  @override
  late final GeneratedColumn<double> montoPago = GeneratedColumn<double>(
      'monto_pago', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _montoCapitalMeta =
      const VerificationMeta('montoCapital');
  @override
  late final GeneratedColumn<double> montoCapital = GeneratedColumn<double>(
      'monto_capital', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _montoInteresMeta =
      const VerificationMeta('montoInteres');
  @override
  late final GeneratedColumn<double> montoInteres = GeneratedColumn<double>(
      'monto_interes', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _montoMoraMeta =
      const VerificationMeta('montoMora');
  @override
  late final GeneratedColumn<double> montoMora = GeneratedColumn<double>(
      'monto_mora', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fechaPagoMeta =
      const VerificationMeta('fechaPago');
  @override
  late final GeneratedColumn<DateTime> fechaPago = GeneratedColumn<DateTime>(
      'fecha_pago', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _metodoPagoMeta =
      const VerificationMeta('metodoPago');
  @override
  late final GeneratedColumn<String> metodoPago = GeneratedColumn<String>(
      'metodo_pago', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaRegistroMeta =
      const VerificationMeta('fechaRegistro');
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>('fecha_registro', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        codigo,
        prestamoId,
        clienteId,
        cajaId,
        montoPago,
        montoCapital,
        montoInteres,
        montoMora,
        fechaPago,
        metodoPago,
        observaciones,
        fechaRegistro
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagos';
  @override
  VerificationContext validateIntegrity(Insertable<Pago> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo')) {
      context.handle(_codigoMeta,
          codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta));
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('prestamo_id')) {
      context.handle(
          _prestamoIdMeta,
          prestamoId.isAcceptableOrUnknown(
              data['prestamo_id']!, _prestamoIdMeta));
    } else if (isInserting) {
      context.missing(_prestamoIdMeta);
    }
    if (data.containsKey('cliente_id')) {
      context.handle(_clienteIdMeta,
          clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta));
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('caja_id')) {
      context.handle(_cajaIdMeta,
          cajaId.isAcceptableOrUnknown(data['caja_id']!, _cajaIdMeta));
    } else if (isInserting) {
      context.missing(_cajaIdMeta);
    }
    if (data.containsKey('monto_pago')) {
      context.handle(_montoPagoMeta,
          montoPago.isAcceptableOrUnknown(data['monto_pago']!, _montoPagoMeta));
    } else if (isInserting) {
      context.missing(_montoPagoMeta);
    }
    if (data.containsKey('monto_capital')) {
      context.handle(
          _montoCapitalMeta,
          montoCapital.isAcceptableOrUnknown(
              data['monto_capital']!, _montoCapitalMeta));
    } else if (isInserting) {
      context.missing(_montoCapitalMeta);
    }
    if (data.containsKey('monto_interes')) {
      context.handle(
          _montoInteresMeta,
          montoInteres.isAcceptableOrUnknown(
              data['monto_interes']!, _montoInteresMeta));
    } else if (isInserting) {
      context.missing(_montoInteresMeta);
    }
    if (data.containsKey('monto_mora')) {
      context.handle(_montoMoraMeta,
          montoMora.isAcceptableOrUnknown(data['monto_mora']!, _montoMoraMeta));
    }
    if (data.containsKey('fecha_pago')) {
      context.handle(_fechaPagoMeta,
          fechaPago.isAcceptableOrUnknown(data['fecha_pago']!, _fechaPagoMeta));
    } else if (isInserting) {
      context.missing(_fechaPagoMeta);
    }
    if (data.containsKey('metodo_pago')) {
      context.handle(
          _metodoPagoMeta,
          metodoPago.isAcceptableOrUnknown(
              data['metodo_pago']!, _metodoPagoMeta));
    } else if (isInserting) {
      context.missing(_metodoPagoMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
          _fechaRegistroMeta,
          fechaRegistro.isAcceptableOrUnknown(
              data['fecha_registro']!, _fechaRegistroMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pago map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pago(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      codigo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}codigo'])!,
      prestamoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prestamo_id'])!,
      clienteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cliente_id'])!,
      cajaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}caja_id'])!,
      montoPago: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_pago'])!,
      montoCapital: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_capital'])!,
      montoInteres: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_interes'])!,
      montoMora: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_mora'])!,
      fechaPago: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha_pago'])!,
      metodoPago: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metodo_pago'])!,
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
      fechaRegistro: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_registro'])!,
    );
  }

  @override
  $PagosTable createAlias(String alias) {
    return $PagosTable(attachedDatabase, alias);
  }
}

class Pago extends DataClass implements Insertable<Pago> {
  final int id;
  final String codigo;
  final int prestamoId;
  final int clienteId;
  final int cajaId;
  final double montoPago;
  final double montoCapital;
  final double montoInteres;
  final double montoMora;
  final DateTime fechaPago;
  final String metodoPago;
  final String? observaciones;
  final DateTime fechaRegistro;
  const Pago(
      {required this.id,
      required this.codigo,
      required this.prestamoId,
      required this.clienteId,
      required this.cajaId,
      required this.montoPago,
      required this.montoCapital,
      required this.montoInteres,
      required this.montoMora,
      required this.fechaPago,
      required this.metodoPago,
      this.observaciones,
      required this.fechaRegistro});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo'] = Variable<String>(codigo);
    map['prestamo_id'] = Variable<int>(prestamoId);
    map['cliente_id'] = Variable<int>(clienteId);
    map['caja_id'] = Variable<int>(cajaId);
    map['monto_pago'] = Variable<double>(montoPago);
    map['monto_capital'] = Variable<double>(montoCapital);
    map['monto_interes'] = Variable<double>(montoInteres);
    map['monto_mora'] = Variable<double>(montoMora);
    map['fecha_pago'] = Variable<DateTime>(fechaPago);
    map['metodo_pago'] = Variable<String>(metodoPago);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    return map;
  }

  PagosCompanion toCompanion(bool nullToAbsent) {
    return PagosCompanion(
      id: Value(id),
      codigo: Value(codigo),
      prestamoId: Value(prestamoId),
      clienteId: Value(clienteId),
      cajaId: Value(cajaId),
      montoPago: Value(montoPago),
      montoCapital: Value(montoCapital),
      montoInteres: Value(montoInteres),
      montoMora: Value(montoMora),
      fechaPago: Value(fechaPago),
      metodoPago: Value(metodoPago),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      fechaRegistro: Value(fechaRegistro),
    );
  }

  factory Pago.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pago(
      id: serializer.fromJson<int>(json['id']),
      codigo: serializer.fromJson<String>(json['codigo']),
      prestamoId: serializer.fromJson<int>(json['prestamoId']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      cajaId: serializer.fromJson<int>(json['cajaId']),
      montoPago: serializer.fromJson<double>(json['montoPago']),
      montoCapital: serializer.fromJson<double>(json['montoCapital']),
      montoInteres: serializer.fromJson<double>(json['montoInteres']),
      montoMora: serializer.fromJson<double>(json['montoMora']),
      fechaPago: serializer.fromJson<DateTime>(json['fechaPago']),
      metodoPago: serializer.fromJson<String>(json['metodoPago']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigo': serializer.toJson<String>(codigo),
      'prestamoId': serializer.toJson<int>(prestamoId),
      'clienteId': serializer.toJson<int>(clienteId),
      'cajaId': serializer.toJson<int>(cajaId),
      'montoPago': serializer.toJson<double>(montoPago),
      'montoCapital': serializer.toJson<double>(montoCapital),
      'montoInteres': serializer.toJson<double>(montoInteres),
      'montoMora': serializer.toJson<double>(montoMora),
      'fechaPago': serializer.toJson<DateTime>(fechaPago),
      'metodoPago': serializer.toJson<String>(metodoPago),
      'observaciones': serializer.toJson<String?>(observaciones),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
    };
  }

  Pago copyWith(
          {int? id,
          String? codigo,
          int? prestamoId,
          int? clienteId,
          int? cajaId,
          double? montoPago,
          double? montoCapital,
          double? montoInteres,
          double? montoMora,
          DateTime? fechaPago,
          String? metodoPago,
          Value<String?> observaciones = const Value.absent(),
          DateTime? fechaRegistro}) =>
      Pago(
        id: id ?? this.id,
        codigo: codigo ?? this.codigo,
        prestamoId: prestamoId ?? this.prestamoId,
        clienteId: clienteId ?? this.clienteId,
        cajaId: cajaId ?? this.cajaId,
        montoPago: montoPago ?? this.montoPago,
        montoCapital: montoCapital ?? this.montoCapital,
        montoInteres: montoInteres ?? this.montoInteres,
        montoMora: montoMora ?? this.montoMora,
        fechaPago: fechaPago ?? this.fechaPago,
        metodoPago: metodoPago ?? this.metodoPago,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );
  Pago copyWithCompanion(PagosCompanion data) {
    return Pago(
      id: data.id.present ? data.id.value : this.id,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      prestamoId:
          data.prestamoId.present ? data.prestamoId.value : this.prestamoId,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      cajaId: data.cajaId.present ? data.cajaId.value : this.cajaId,
      montoPago: data.montoPago.present ? data.montoPago.value : this.montoPago,
      montoCapital: data.montoCapital.present
          ? data.montoCapital.value
          : this.montoCapital,
      montoInteres: data.montoInteres.present
          ? data.montoInteres.value
          : this.montoInteres,
      montoMora: data.montoMora.present ? data.montoMora.value : this.montoMora,
      fechaPago: data.fechaPago.present ? data.fechaPago.value : this.fechaPago,
      metodoPago:
          data.metodoPago.present ? data.metodoPago.value : this.metodoPago,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pago(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('prestamoId: $prestamoId, ')
          ..write('clienteId: $clienteId, ')
          ..write('cajaId: $cajaId, ')
          ..write('montoPago: $montoPago, ')
          ..write('montoCapital: $montoCapital, ')
          ..write('montoInteres: $montoInteres, ')
          ..write('montoMora: $montoMora, ')
          ..write('fechaPago: $fechaPago, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      codigo,
      prestamoId,
      clienteId,
      cajaId,
      montoPago,
      montoCapital,
      montoInteres,
      montoMora,
      fechaPago,
      metodoPago,
      observaciones,
      fechaRegistro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pago &&
          other.id == this.id &&
          other.codigo == this.codigo &&
          other.prestamoId == this.prestamoId &&
          other.clienteId == this.clienteId &&
          other.cajaId == this.cajaId &&
          other.montoPago == this.montoPago &&
          other.montoCapital == this.montoCapital &&
          other.montoInteres == this.montoInteres &&
          other.montoMora == this.montoMora &&
          other.fechaPago == this.fechaPago &&
          other.metodoPago == this.metodoPago &&
          other.observaciones == this.observaciones &&
          other.fechaRegistro == this.fechaRegistro);
}

class PagosCompanion extends UpdateCompanion<Pago> {
  final Value<int> id;
  final Value<String> codigo;
  final Value<int> prestamoId;
  final Value<int> clienteId;
  final Value<int> cajaId;
  final Value<double> montoPago;
  final Value<double> montoCapital;
  final Value<double> montoInteres;
  final Value<double> montoMora;
  final Value<DateTime> fechaPago;
  final Value<String> metodoPago;
  final Value<String?> observaciones;
  final Value<DateTime> fechaRegistro;
  const PagosCompanion({
    this.id = const Value.absent(),
    this.codigo = const Value.absent(),
    this.prestamoId = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.cajaId = const Value.absent(),
    this.montoPago = const Value.absent(),
    this.montoCapital = const Value.absent(),
    this.montoInteres = const Value.absent(),
    this.montoMora = const Value.absent(),
    this.fechaPago = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  });
  PagosCompanion.insert({
    this.id = const Value.absent(),
    required String codigo,
    required int prestamoId,
    required int clienteId,
    required int cajaId,
    required double montoPago,
    required double montoCapital,
    required double montoInteres,
    this.montoMora = const Value.absent(),
    required DateTime fechaPago,
    required String metodoPago,
    this.observaciones = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  })  : codigo = Value(codigo),
        prestamoId = Value(prestamoId),
        clienteId = Value(clienteId),
        cajaId = Value(cajaId),
        montoPago = Value(montoPago),
        montoCapital = Value(montoCapital),
        montoInteres = Value(montoInteres),
        fechaPago = Value(fechaPago),
        metodoPago = Value(metodoPago);
  static Insertable<Pago> custom({
    Expression<int>? id,
    Expression<String>? codigo,
    Expression<int>? prestamoId,
    Expression<int>? clienteId,
    Expression<int>? cajaId,
    Expression<double>? montoPago,
    Expression<double>? montoCapital,
    Expression<double>? montoInteres,
    Expression<double>? montoMora,
    Expression<DateTime>? fechaPago,
    Expression<String>? metodoPago,
    Expression<String>? observaciones,
    Expression<DateTime>? fechaRegistro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigo != null) 'codigo': codigo,
      if (prestamoId != null) 'prestamo_id': prestamoId,
      if (clienteId != null) 'cliente_id': clienteId,
      if (cajaId != null) 'caja_id': cajaId,
      if (montoPago != null) 'monto_pago': montoPago,
      if (montoCapital != null) 'monto_capital': montoCapital,
      if (montoInteres != null) 'monto_interes': montoInteres,
      if (montoMora != null) 'monto_mora': montoMora,
      if (fechaPago != null) 'fecha_pago': fechaPago,
      if (metodoPago != null) 'metodo_pago': metodoPago,
      if (observaciones != null) 'observaciones': observaciones,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
    });
  }

  PagosCompanion copyWith(
      {Value<int>? id,
      Value<String>? codigo,
      Value<int>? prestamoId,
      Value<int>? clienteId,
      Value<int>? cajaId,
      Value<double>? montoPago,
      Value<double>? montoCapital,
      Value<double>? montoInteres,
      Value<double>? montoMora,
      Value<DateTime>? fechaPago,
      Value<String>? metodoPago,
      Value<String?>? observaciones,
      Value<DateTime>? fechaRegistro}) {
    return PagosCompanion(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      prestamoId: prestamoId ?? this.prestamoId,
      clienteId: clienteId ?? this.clienteId,
      cajaId: cajaId ?? this.cajaId,
      montoPago: montoPago ?? this.montoPago,
      montoCapital: montoCapital ?? this.montoCapital,
      montoInteres: montoInteres ?? this.montoInteres,
      montoMora: montoMora ?? this.montoMora,
      fechaPago: fechaPago ?? this.fechaPago,
      metodoPago: metodoPago ?? this.metodoPago,
      observaciones: observaciones ?? this.observaciones,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (prestamoId.present) {
      map['prestamo_id'] = Variable<int>(prestamoId.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (cajaId.present) {
      map['caja_id'] = Variable<int>(cajaId.value);
    }
    if (montoPago.present) {
      map['monto_pago'] = Variable<double>(montoPago.value);
    }
    if (montoCapital.present) {
      map['monto_capital'] = Variable<double>(montoCapital.value);
    }
    if (montoInteres.present) {
      map['monto_interes'] = Variable<double>(montoInteres.value);
    }
    if (montoMora.present) {
      map['monto_mora'] = Variable<double>(montoMora.value);
    }
    if (fechaPago.present) {
      map['fecha_pago'] = Variable<DateTime>(fechaPago.value);
    }
    if (metodoPago.present) {
      map['metodo_pago'] = Variable<String>(metodoPago.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagosCompanion(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('prestamoId: $prestamoId, ')
          ..write('clienteId: $clienteId, ')
          ..write('cajaId: $cajaId, ')
          ..write('montoPago: $montoPago, ')
          ..write('montoCapital: $montoCapital, ')
          ..write('montoInteres: $montoInteres, ')
          ..write('montoMora: $montoMora, ')
          ..write('fechaPago: $fechaPago, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }
}

class $DetallePagosTable extends DetallePagos
    with TableInfo<$DetallePagosTable, DetallePago> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetallePagosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _pagoIdMeta = const VerificationMeta('pagoId');
  @override
  late final GeneratedColumn<int> pagoId = GeneratedColumn<int>(
      'pago_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES pagos (id) ON DELETE CASCADE'));
  static const VerificationMeta _cuotaIdMeta =
      const VerificationMeta('cuotaId');
  @override
  late final GeneratedColumn<int> cuotaId = GeneratedColumn<int>(
      'cuota_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES cuotas (id)'));
  static const VerificationMeta _montoAplicadoMeta =
      const VerificationMeta('montoAplicado');
  @override
  late final GeneratedColumn<double> montoAplicado = GeneratedColumn<double>(
      'monto_aplicado', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _montoMoraMeta =
      const VerificationMeta('montoMora');
  @override
  late final GeneratedColumn<double> montoMora = GeneratedColumn<double>(
      'monto_mora', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fechaRegistroMeta =
      const VerificationMeta('fechaRegistro');
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>('fecha_registro', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, pagoId, cuotaId, montoAplicado, montoMora, fechaRegistro];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detalle_pagos';
  @override
  VerificationContext validateIntegrity(Insertable<DetallePago> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pago_id')) {
      context.handle(_pagoIdMeta,
          pagoId.isAcceptableOrUnknown(data['pago_id']!, _pagoIdMeta));
    } else if (isInserting) {
      context.missing(_pagoIdMeta);
    }
    if (data.containsKey('cuota_id')) {
      context.handle(_cuotaIdMeta,
          cuotaId.isAcceptableOrUnknown(data['cuota_id']!, _cuotaIdMeta));
    } else if (isInserting) {
      context.missing(_cuotaIdMeta);
    }
    if (data.containsKey('monto_aplicado')) {
      context.handle(
          _montoAplicadoMeta,
          montoAplicado.isAcceptableOrUnknown(
              data['monto_aplicado']!, _montoAplicadoMeta));
    } else if (isInserting) {
      context.missing(_montoAplicadoMeta);
    }
    if (data.containsKey('monto_mora')) {
      context.handle(_montoMoraMeta,
          montoMora.isAcceptableOrUnknown(data['monto_mora']!, _montoMoraMeta));
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
          _fechaRegistroMeta,
          fechaRegistro.isAcceptableOrUnknown(
              data['fecha_registro']!, _fechaRegistroMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetallePago map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetallePago(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      pagoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pago_id'])!,
      cuotaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cuota_id'])!,
      montoAplicado: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_aplicado'])!,
      montoMora: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto_mora'])!,
      fechaRegistro: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_registro'])!,
    );
  }

  @override
  $DetallePagosTable createAlias(String alias) {
    return $DetallePagosTable(attachedDatabase, alias);
  }
}

class DetallePago extends DataClass implements Insertable<DetallePago> {
  final int id;
  final int pagoId;
  final int cuotaId;
  final double montoAplicado;
  final double montoMora;
  final DateTime fechaRegistro;
  const DetallePago(
      {required this.id,
      required this.pagoId,
      required this.cuotaId,
      required this.montoAplicado,
      required this.montoMora,
      required this.fechaRegistro});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pago_id'] = Variable<int>(pagoId);
    map['cuota_id'] = Variable<int>(cuotaId);
    map['monto_aplicado'] = Variable<double>(montoAplicado);
    map['monto_mora'] = Variable<double>(montoMora);
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    return map;
  }

  DetallePagosCompanion toCompanion(bool nullToAbsent) {
    return DetallePagosCompanion(
      id: Value(id),
      pagoId: Value(pagoId),
      cuotaId: Value(cuotaId),
      montoAplicado: Value(montoAplicado),
      montoMora: Value(montoMora),
      fechaRegistro: Value(fechaRegistro),
    );
  }

  factory DetallePago.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetallePago(
      id: serializer.fromJson<int>(json['id']),
      pagoId: serializer.fromJson<int>(json['pagoId']),
      cuotaId: serializer.fromJson<int>(json['cuotaId']),
      montoAplicado: serializer.fromJson<double>(json['montoAplicado']),
      montoMora: serializer.fromJson<double>(json['montoMora']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pagoId': serializer.toJson<int>(pagoId),
      'cuotaId': serializer.toJson<int>(cuotaId),
      'montoAplicado': serializer.toJson<double>(montoAplicado),
      'montoMora': serializer.toJson<double>(montoMora),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
    };
  }

  DetallePago copyWith(
          {int? id,
          int? pagoId,
          int? cuotaId,
          double? montoAplicado,
          double? montoMora,
          DateTime? fechaRegistro}) =>
      DetallePago(
        id: id ?? this.id,
        pagoId: pagoId ?? this.pagoId,
        cuotaId: cuotaId ?? this.cuotaId,
        montoAplicado: montoAplicado ?? this.montoAplicado,
        montoMora: montoMora ?? this.montoMora,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );
  DetallePago copyWithCompanion(DetallePagosCompanion data) {
    return DetallePago(
      id: data.id.present ? data.id.value : this.id,
      pagoId: data.pagoId.present ? data.pagoId.value : this.pagoId,
      cuotaId: data.cuotaId.present ? data.cuotaId.value : this.cuotaId,
      montoAplicado: data.montoAplicado.present
          ? data.montoAplicado.value
          : this.montoAplicado,
      montoMora: data.montoMora.present ? data.montoMora.value : this.montoMora,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetallePago(')
          ..write('id: $id, ')
          ..write('pagoId: $pagoId, ')
          ..write('cuotaId: $cuotaId, ')
          ..write('montoAplicado: $montoAplicado, ')
          ..write('montoMora: $montoMora, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pagoId, cuotaId, montoAplicado, montoMora, fechaRegistro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetallePago &&
          other.id == this.id &&
          other.pagoId == this.pagoId &&
          other.cuotaId == this.cuotaId &&
          other.montoAplicado == this.montoAplicado &&
          other.montoMora == this.montoMora &&
          other.fechaRegistro == this.fechaRegistro);
}

class DetallePagosCompanion extends UpdateCompanion<DetallePago> {
  final Value<int> id;
  final Value<int> pagoId;
  final Value<int> cuotaId;
  final Value<double> montoAplicado;
  final Value<double> montoMora;
  final Value<DateTime> fechaRegistro;
  const DetallePagosCompanion({
    this.id = const Value.absent(),
    this.pagoId = const Value.absent(),
    this.cuotaId = const Value.absent(),
    this.montoAplicado = const Value.absent(),
    this.montoMora = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  });
  DetallePagosCompanion.insert({
    this.id = const Value.absent(),
    required int pagoId,
    required int cuotaId,
    required double montoAplicado,
    this.montoMora = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  })  : pagoId = Value(pagoId),
        cuotaId = Value(cuotaId),
        montoAplicado = Value(montoAplicado);
  static Insertable<DetallePago> custom({
    Expression<int>? id,
    Expression<int>? pagoId,
    Expression<int>? cuotaId,
    Expression<double>? montoAplicado,
    Expression<double>? montoMora,
    Expression<DateTime>? fechaRegistro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pagoId != null) 'pago_id': pagoId,
      if (cuotaId != null) 'cuota_id': cuotaId,
      if (montoAplicado != null) 'monto_aplicado': montoAplicado,
      if (montoMora != null) 'monto_mora': montoMora,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
    });
  }

  DetallePagosCompanion copyWith(
      {Value<int>? id,
      Value<int>? pagoId,
      Value<int>? cuotaId,
      Value<double>? montoAplicado,
      Value<double>? montoMora,
      Value<DateTime>? fechaRegistro}) {
    return DetallePagosCompanion(
      id: id ?? this.id,
      pagoId: pagoId ?? this.pagoId,
      cuotaId: cuotaId ?? this.cuotaId,
      montoAplicado: montoAplicado ?? this.montoAplicado,
      montoMora: montoMora ?? this.montoMora,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pagoId.present) {
      map['pago_id'] = Variable<int>(pagoId.value);
    }
    if (cuotaId.present) {
      map['cuota_id'] = Variable<int>(cuotaId.value);
    }
    if (montoAplicado.present) {
      map['monto_aplicado'] = Variable<double>(montoAplicado.value);
    }
    if (montoMora.present) {
      map['monto_mora'] = Variable<double>(montoMora.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetallePagosCompanion(')
          ..write('id: $id, ')
          ..write('pagoId: $pagoId, ')
          ..write('cuotaId: $cuotaId, ')
          ..write('montoAplicado: $montoAplicado, ')
          ..write('montoMora: $montoMora, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }
}

class $MovimientosTable extends Movimientos
    with TableInfo<$MovimientosTable, Movimiento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
      'codigo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _cajaIdMeta = const VerificationMeta('cajaId');
  @override
  late final GeneratedColumn<int> cajaId = GeneratedColumn<int>(
      'caja_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES cajas (id)'));
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>(
      'monto', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoriaMeta =
      const VerificationMeta('categoria');
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
      'categoria', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prestamoIdMeta =
      const VerificationMeta('prestamoId');
  @override
  late final GeneratedColumn<int> prestamoId = GeneratedColumn<int>(
      'prestamo_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES prestamos (id)'));
  static const VerificationMeta _pagoIdMeta = const VerificationMeta('pagoId');
  @override
  late final GeneratedColumn<int> pagoId = GeneratedColumn<int>(
      'pago_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES pagos (id)'));
  static const VerificationMeta _cajaDestinoIdMeta =
      const VerificationMeta('cajaDestinoId');
  @override
  late final GeneratedColumn<int> cajaDestinoId = GeneratedColumn<int>(
      'caja_destino_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES cajas (id)'));
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
      'fecha', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _observacionesMeta =
      const VerificationMeta('observaciones');
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
      'observaciones', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaRegistroMeta =
      const VerificationMeta('fechaRegistro');
  @override
  late final GeneratedColumn<DateTime> fechaRegistro =
      GeneratedColumn<DateTime>('fecha_registro', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        codigo,
        cajaId,
        tipo,
        monto,
        categoria,
        descripcion,
        prestamoId,
        pagoId,
        cajaDestinoId,
        fecha,
        observaciones,
        fechaRegistro
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos';
  @override
  VerificationContext validateIntegrity(Insertable<Movimiento> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo')) {
      context.handle(_codigoMeta,
          codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta));
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('caja_id')) {
      context.handle(_cajaIdMeta,
          cajaId.isAcceptableOrUnknown(data['caja_id']!, _cajaIdMeta));
    } else if (isInserting) {
      context.missing(_cajaIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
          _montoMeta, monto.isAcceptableOrUnknown(data['monto']!, _montoMeta));
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(_categoriaMeta,
          categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta));
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('prestamo_id')) {
      context.handle(
          _prestamoIdMeta,
          prestamoId.isAcceptableOrUnknown(
              data['prestamo_id']!, _prestamoIdMeta));
    }
    if (data.containsKey('pago_id')) {
      context.handle(_pagoIdMeta,
          pagoId.isAcceptableOrUnknown(data['pago_id']!, _pagoIdMeta));
    }
    if (data.containsKey('caja_destino_id')) {
      context.handle(
          _cajaDestinoIdMeta,
          cajaDestinoId.isAcceptableOrUnknown(
              data['caja_destino_id']!, _cajaDestinoIdMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
          _observacionesMeta,
          observaciones.isAcceptableOrUnknown(
              data['observaciones']!, _observacionesMeta));
    }
    if (data.containsKey('fecha_registro')) {
      context.handle(
          _fechaRegistroMeta,
          fechaRegistro.isAcceptableOrUnknown(
              data['fecha_registro']!, _fechaRegistroMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Movimiento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Movimiento(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      codigo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}codigo'])!,
      cajaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}caja_id'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo'])!,
      monto: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monto'])!,
      categoria: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria'])!,
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion'])!,
      prestamoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prestamo_id']),
      pagoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pago_id']),
      cajaDestinoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}caja_destino_id']),
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha'])!,
      observaciones: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}observaciones']),
      fechaRegistro: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_registro'])!,
    );
  }

  @override
  $MovimientosTable createAlias(String alias) {
    return $MovimientosTable(attachedDatabase, alias);
  }
}

class Movimiento extends DataClass implements Insertable<Movimiento> {
  final int id;
  final String codigo;
  final int cajaId;
  final String tipo;
  final double monto;
  final String categoria;
  final String descripcion;
  final int? prestamoId;
  final int? pagoId;
  final int? cajaDestinoId;
  final DateTime fecha;
  final String? observaciones;
  final DateTime fechaRegistro;
  const Movimiento(
      {required this.id,
      required this.codigo,
      required this.cajaId,
      required this.tipo,
      required this.monto,
      required this.categoria,
      required this.descripcion,
      this.prestamoId,
      this.pagoId,
      this.cajaDestinoId,
      required this.fecha,
      this.observaciones,
      required this.fechaRegistro});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['codigo'] = Variable<String>(codigo);
    map['caja_id'] = Variable<int>(cajaId);
    map['tipo'] = Variable<String>(tipo);
    map['monto'] = Variable<double>(monto);
    map['categoria'] = Variable<String>(categoria);
    map['descripcion'] = Variable<String>(descripcion);
    if (!nullToAbsent || prestamoId != null) {
      map['prestamo_id'] = Variable<int>(prestamoId);
    }
    if (!nullToAbsent || pagoId != null) {
      map['pago_id'] = Variable<int>(pagoId);
    }
    if (!nullToAbsent || cajaDestinoId != null) {
      map['caja_destino_id'] = Variable<int>(cajaDestinoId);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['fecha_registro'] = Variable<DateTime>(fechaRegistro);
    return map;
  }

  MovimientosCompanion toCompanion(bool nullToAbsent) {
    return MovimientosCompanion(
      id: Value(id),
      codigo: Value(codigo),
      cajaId: Value(cajaId),
      tipo: Value(tipo),
      monto: Value(monto),
      categoria: Value(categoria),
      descripcion: Value(descripcion),
      prestamoId: prestamoId == null && nullToAbsent
          ? const Value.absent()
          : Value(prestamoId),
      pagoId:
          pagoId == null && nullToAbsent ? const Value.absent() : Value(pagoId),
      cajaDestinoId: cajaDestinoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cajaDestinoId),
      fecha: Value(fecha),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      fechaRegistro: Value(fechaRegistro),
    );
  }

  factory Movimiento.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Movimiento(
      id: serializer.fromJson<int>(json['id']),
      codigo: serializer.fromJson<String>(json['codigo']),
      cajaId: serializer.fromJson<int>(json['cajaId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      monto: serializer.fromJson<double>(json['monto']),
      categoria: serializer.fromJson<String>(json['categoria']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      prestamoId: serializer.fromJson<int?>(json['prestamoId']),
      pagoId: serializer.fromJson<int?>(json['pagoId']),
      cajaDestinoId: serializer.fromJson<int?>(json['cajaDestinoId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      fechaRegistro: serializer.fromJson<DateTime>(json['fechaRegistro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigo': serializer.toJson<String>(codigo),
      'cajaId': serializer.toJson<int>(cajaId),
      'tipo': serializer.toJson<String>(tipo),
      'monto': serializer.toJson<double>(monto),
      'categoria': serializer.toJson<String>(categoria),
      'descripcion': serializer.toJson<String>(descripcion),
      'prestamoId': serializer.toJson<int?>(prestamoId),
      'pagoId': serializer.toJson<int?>(pagoId),
      'cajaDestinoId': serializer.toJson<int?>(cajaDestinoId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'observaciones': serializer.toJson<String?>(observaciones),
      'fechaRegistro': serializer.toJson<DateTime>(fechaRegistro),
    };
  }

  Movimiento copyWith(
          {int? id,
          String? codigo,
          int? cajaId,
          String? tipo,
          double? monto,
          String? categoria,
          String? descripcion,
          Value<int?> prestamoId = const Value.absent(),
          Value<int?> pagoId = const Value.absent(),
          Value<int?> cajaDestinoId = const Value.absent(),
          DateTime? fecha,
          Value<String?> observaciones = const Value.absent(),
          DateTime? fechaRegistro}) =>
      Movimiento(
        id: id ?? this.id,
        codigo: codigo ?? this.codigo,
        cajaId: cajaId ?? this.cajaId,
        tipo: tipo ?? this.tipo,
        monto: monto ?? this.monto,
        categoria: categoria ?? this.categoria,
        descripcion: descripcion ?? this.descripcion,
        prestamoId: prestamoId.present ? prestamoId.value : this.prestamoId,
        pagoId: pagoId.present ? pagoId.value : this.pagoId,
        cajaDestinoId:
            cajaDestinoId.present ? cajaDestinoId.value : this.cajaDestinoId,
        fecha: fecha ?? this.fecha,
        observaciones:
            observaciones.present ? observaciones.value : this.observaciones,
        fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      );
  Movimiento copyWithCompanion(MovimientosCompanion data) {
    return Movimiento(
      id: data.id.present ? data.id.value : this.id,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      cajaId: data.cajaId.present ? data.cajaId.value : this.cajaId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      monto: data.monto.present ? data.monto.value : this.monto,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      prestamoId:
          data.prestamoId.present ? data.prestamoId.value : this.prestamoId,
      pagoId: data.pagoId.present ? data.pagoId.value : this.pagoId,
      cajaDestinoId: data.cajaDestinoId.present
          ? data.cajaDestinoId.value
          : this.cajaDestinoId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      fechaRegistro: data.fechaRegistro.present
          ? data.fechaRegistro.value
          : this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Movimiento(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('cajaId: $cajaId, ')
          ..write('tipo: $tipo, ')
          ..write('monto: $monto, ')
          ..write('categoria: $categoria, ')
          ..write('descripcion: $descripcion, ')
          ..write('prestamoId: $prestamoId, ')
          ..write('pagoId: $pagoId, ')
          ..write('cajaDestinoId: $cajaDestinoId, ')
          ..write('fecha: $fecha, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      codigo,
      cajaId,
      tipo,
      monto,
      categoria,
      descripcion,
      prestamoId,
      pagoId,
      cajaDestinoId,
      fecha,
      observaciones,
      fechaRegistro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Movimiento &&
          other.id == this.id &&
          other.codigo == this.codigo &&
          other.cajaId == this.cajaId &&
          other.tipo == this.tipo &&
          other.monto == this.monto &&
          other.categoria == this.categoria &&
          other.descripcion == this.descripcion &&
          other.prestamoId == this.prestamoId &&
          other.pagoId == this.pagoId &&
          other.cajaDestinoId == this.cajaDestinoId &&
          other.fecha == this.fecha &&
          other.observaciones == this.observaciones &&
          other.fechaRegistro == this.fechaRegistro);
}

class MovimientosCompanion extends UpdateCompanion<Movimiento> {
  final Value<int> id;
  final Value<String> codigo;
  final Value<int> cajaId;
  final Value<String> tipo;
  final Value<double> monto;
  final Value<String> categoria;
  final Value<String> descripcion;
  final Value<int?> prestamoId;
  final Value<int?> pagoId;
  final Value<int?> cajaDestinoId;
  final Value<DateTime> fecha;
  final Value<String?> observaciones;
  final Value<DateTime> fechaRegistro;
  const MovimientosCompanion({
    this.id = const Value.absent(),
    this.codigo = const Value.absent(),
    this.cajaId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.monto = const Value.absent(),
    this.categoria = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.prestamoId = const Value.absent(),
    this.pagoId = const Value.absent(),
    this.cajaDestinoId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  });
  MovimientosCompanion.insert({
    this.id = const Value.absent(),
    required String codigo,
    required int cajaId,
    required String tipo,
    required double monto,
    required String categoria,
    required String descripcion,
    this.prestamoId = const Value.absent(),
    this.pagoId = const Value.absent(),
    this.cajaDestinoId = const Value.absent(),
    required DateTime fecha,
    this.observaciones = const Value.absent(),
    this.fechaRegistro = const Value.absent(),
  })  : codigo = Value(codigo),
        cajaId = Value(cajaId),
        tipo = Value(tipo),
        monto = Value(monto),
        categoria = Value(categoria),
        descripcion = Value(descripcion),
        fecha = Value(fecha);
  static Insertable<Movimiento> custom({
    Expression<int>? id,
    Expression<String>? codigo,
    Expression<int>? cajaId,
    Expression<String>? tipo,
    Expression<double>? monto,
    Expression<String>? categoria,
    Expression<String>? descripcion,
    Expression<int>? prestamoId,
    Expression<int>? pagoId,
    Expression<int>? cajaDestinoId,
    Expression<DateTime>? fecha,
    Expression<String>? observaciones,
    Expression<DateTime>? fechaRegistro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigo != null) 'codigo': codigo,
      if (cajaId != null) 'caja_id': cajaId,
      if (tipo != null) 'tipo': tipo,
      if (monto != null) 'monto': monto,
      if (categoria != null) 'categoria': categoria,
      if (descripcion != null) 'descripcion': descripcion,
      if (prestamoId != null) 'prestamo_id': prestamoId,
      if (pagoId != null) 'pago_id': pagoId,
      if (cajaDestinoId != null) 'caja_destino_id': cajaDestinoId,
      if (fecha != null) 'fecha': fecha,
      if (observaciones != null) 'observaciones': observaciones,
      if (fechaRegistro != null) 'fecha_registro': fechaRegistro,
    });
  }

  MovimientosCompanion copyWith(
      {Value<int>? id,
      Value<String>? codigo,
      Value<int>? cajaId,
      Value<String>? tipo,
      Value<double>? monto,
      Value<String>? categoria,
      Value<String>? descripcion,
      Value<int?>? prestamoId,
      Value<int?>? pagoId,
      Value<int?>? cajaDestinoId,
      Value<DateTime>? fecha,
      Value<String?>? observaciones,
      Value<DateTime>? fechaRegistro}) {
    return MovimientosCompanion(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      cajaId: cajaId ?? this.cajaId,
      tipo: tipo ?? this.tipo,
      monto: monto ?? this.monto,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      prestamoId: prestamoId ?? this.prestamoId,
      pagoId: pagoId ?? this.pagoId,
      cajaDestinoId: cajaDestinoId ?? this.cajaDestinoId,
      fecha: fecha ?? this.fecha,
      observaciones: observaciones ?? this.observaciones,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (cajaId.present) {
      map['caja_id'] = Variable<int>(cajaId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (monto.present) {
      map['monto'] = Variable<double>(monto.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (prestamoId.present) {
      map['prestamo_id'] = Variable<int>(prestamoId.value);
    }
    if (pagoId.present) {
      map['pago_id'] = Variable<int>(pagoId.value);
    }
    if (cajaDestinoId.present) {
      map['caja_destino_id'] = Variable<int>(cajaDestinoId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (fechaRegistro.present) {
      map['fecha_registro'] = Variable<DateTime>(fechaRegistro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosCompanion(')
          ..write('id: $id, ')
          ..write('codigo: $codigo, ')
          ..write('cajaId: $cajaId, ')
          ..write('tipo: $tipo, ')
          ..write('monto: $monto, ')
          ..write('categoria: $categoria, ')
          ..write('descripcion: $descripcion, ')
          ..write('prestamoId: $prestamoId, ')
          ..write('pagoId: $pagoId, ')
          ..write('cajaDestinoId: $cajaDestinoId, ')
          ..write('fecha: $fecha, ')
          ..write('observaciones: $observaciones, ')
          ..write('fechaRegistro: $fechaRegistro')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $CajasTable cajas = $CajasTable(this);
  late final $PrestamosTable prestamos = $PrestamosTable(this);
  late final $CuotasTable cuotas = $CuotasTable(this);
  late final $PagosTable pagos = $PagosTable(this);
  late final $DetallePagosTable detallePagos = $DetallePagosTable(this);
  late final $MovimientosTable movimientos = $MovimientosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [clientes, cajas, prestamos, cuotas, pagos, detallePagos, movimientos];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('prestamos',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('cuotas', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('pagos',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('detalle_pagos', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ClientesTableCreateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  required String nombres,
  required String apellidos,
  required String tipoDocumento,
  required String numeroDocumento,
  required String telefono,
  Value<String?> email,
  required String direccion,
  Value<String?> referencia,
  Value<String?> observaciones,
  Value<bool> activo,
  Value<DateTime> fechaRegistro,
  Value<DateTime?> fechaActualizacion,
});
typedef $$ClientesTableUpdateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  Value<String> nombres,
  Value<String> apellidos,
  Value<String> tipoDocumento,
  Value<String> numeroDocumento,
  Value<String> telefono,
  Value<String?> email,
  Value<String> direccion,
  Value<String?> referencia,
  Value<String?> observaciones,
  Value<bool> activo,
  Value<DateTime> fechaRegistro,
  Value<DateTime?> fechaActualizacion,
});

final class $$ClientesTableReferences
    extends BaseReferences<_$AppDatabase, $ClientesTable, Cliente> {
  $$ClientesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PrestamosTable, List<Prestamo>>
      _prestamosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.prestamos,
              aliasName:
                  $_aliasNameGenerator(db.clientes.id, db.prestamos.clienteId));

  $$PrestamosTableProcessedTableManager get prestamosRefs {
    final manager = $$PrestamosTableTableManager($_db, $_db.prestamos)
        .filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_prestamosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PagosTable, List<Pago>> _pagosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pagos,
          aliasName: $_aliasNameGenerator(db.clientes.id, db.pagos.clienteId));

  $$PagosTableProcessedTableManager get pagosRefs {
    final manager = $$PagosTableTableManager($_db, $_db.pagos)
        .filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombres => $composableBuilder(
      column: $table.nombres, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get apellidos => $composableBuilder(
      column: $table.apellidos, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoDocumento => $composableBuilder(
      column: $table.tipoDocumento, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numeroDocumento => $composableBuilder(
      column: $table.numeroDocumento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referencia => $composableBuilder(
      column: $table.referencia, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion,
      builder: (column) => ColumnFilters(column));

  Expression<bool> prestamosRefs(
      Expression<bool> Function($$PrestamosTableFilterComposer f) f) {
    final $$PrestamosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.clienteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableFilterComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pagosRefs(
      Expression<bool> Function($$PagosTableFilterComposer f) f) {
    final $$PagosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.clienteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableFilterComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombres => $composableBuilder(
      column: $table.nombres, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get apellidos => $composableBuilder(
      column: $table.apellidos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoDocumento => $composableBuilder(
      column: $table.tipoDocumento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numeroDocumento => $composableBuilder(
      column: $table.numeroDocumento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referencia => $composableBuilder(
      column: $table.referencia, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observaciones => $composableBuilder(
      column: $table.observaciones,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion,
      builder: (column) => ColumnOrderings(column));
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombres =>
      $composableBuilder(column: $table.nombres, builder: (column) => column);

  GeneratedColumn<String> get apellidos =>
      $composableBuilder(column: $table.apellidos, builder: (column) => column);

  GeneratedColumn<String> get tipoDocumento => $composableBuilder(
      column: $table.tipoDocumento, builder: (column) => column);

  GeneratedColumn<String> get numeroDocumento => $composableBuilder(
      column: $table.numeroDocumento, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get referencia => $composableBuilder(
      column: $table.referencia, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion, builder: (column) => column);

  Expression<T> prestamosRefs<T extends Object>(
      Expression<T> Function($$PrestamosTableAnnotationComposer a) f) {
    final $$PrestamosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.clienteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableAnnotationComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pagosRefs<T extends Object>(
      Expression<T> Function($$PagosTableAnnotationComposer a) f) {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.clienteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableAnnotationComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClientesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientesTable,
    Cliente,
    $$ClientesTableFilterComposer,
    $$ClientesTableOrderingComposer,
    $$ClientesTableAnnotationComposer,
    $$ClientesTableCreateCompanionBuilder,
    $$ClientesTableUpdateCompanionBuilder,
    (Cliente, $$ClientesTableReferences),
    Cliente,
    PrefetchHooks Function({bool prestamosRefs, bool pagosRefs})> {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombres = const Value.absent(),
            Value<String> apellidos = const Value.absent(),
            Value<String> tipoDocumento = const Value.absent(),
            Value<String> numeroDocumento = const Value.absent(),
            Value<String> telefono = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String> direccion = const Value.absent(),
            Value<String?> referencia = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<bool> activo = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
            Value<DateTime?> fechaActualizacion = const Value.absent(),
          }) =>
              ClientesCompanion(
            id: id,
            nombres: nombres,
            apellidos: apellidos,
            tipoDocumento: tipoDocumento,
            numeroDocumento: numeroDocumento,
            telefono: telefono,
            email: email,
            direccion: direccion,
            referencia: referencia,
            observaciones: observaciones,
            activo: activo,
            fechaRegistro: fechaRegistro,
            fechaActualizacion: fechaActualizacion,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nombres,
            required String apellidos,
            required String tipoDocumento,
            required String numeroDocumento,
            required String telefono,
            Value<String?> email = const Value.absent(),
            required String direccion,
            Value<String?> referencia = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<bool> activo = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
            Value<DateTime?> fechaActualizacion = const Value.absent(),
          }) =>
              ClientesCompanion.insert(
            id: id,
            nombres: nombres,
            apellidos: apellidos,
            tipoDocumento: tipoDocumento,
            numeroDocumento: numeroDocumento,
            telefono: telefono,
            email: email,
            direccion: direccion,
            referencia: referencia,
            observaciones: observaciones,
            activo: activo,
            fechaRegistro: fechaRegistro,
            fechaActualizacion: fechaActualizacion,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ClientesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({prestamosRefs = false, pagosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (prestamosRefs) db.prestamos,
                if (pagosRefs) db.pagos
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (prestamosRefs)
                    await $_getPrefetchedData<Cliente, $ClientesTable,
                            Prestamo>(
                        currentTable: table,
                        referencedTable:
                            $$ClientesTableReferences._prestamosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClientesTableReferences(db, table, p0)
                                .prestamosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.clienteId == item.id),
                        typedResults: items),
                  if (pagosRefs)
                    await $_getPrefetchedData<Cliente, $ClientesTable, Pago>(
                        currentTable: table,
                        referencedTable:
                            $$ClientesTableReferences._pagosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClientesTableReferences(db, table, p0).pagosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.clienteId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ClientesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientesTable,
    Cliente,
    $$ClientesTableFilterComposer,
    $$ClientesTableOrderingComposer,
    $$ClientesTableAnnotationComposer,
    $$ClientesTableCreateCompanionBuilder,
    $$ClientesTableUpdateCompanionBuilder,
    (Cliente, $$ClientesTableReferences),
    Cliente,
    PrefetchHooks Function({bool prestamosRefs, bool pagosRefs})>;
typedef $$CajasTableCreateCompanionBuilder = CajasCompanion Function({
  Value<int> id,
  required String nombre,
  required String tipo,
  Value<String?> descripcion,
  Value<double> saldoInicial,
  Value<double> saldoActual,
  Value<bool> activa,
  Value<DateTime> fechaCreacion,
  Value<DateTime?> fechaActualizacion,
});
typedef $$CajasTableUpdateCompanionBuilder = CajasCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String> tipo,
  Value<String?> descripcion,
  Value<double> saldoInicial,
  Value<double> saldoActual,
  Value<bool> activa,
  Value<DateTime> fechaCreacion,
  Value<DateTime?> fechaActualizacion,
});

final class $$CajasTableReferences
    extends BaseReferences<_$AppDatabase, $CajasTable, Caja> {
  $$CajasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PrestamosTable, List<Prestamo>>
      _prestamosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.prestamos,
          aliasName: $_aliasNameGenerator(db.cajas.id, db.prestamos.cajaId));

  $$PrestamosTableProcessedTableManager get prestamosRefs {
    final manager = $$PrestamosTableTableManager($_db, $_db.prestamos)
        .filter((f) => f.cajaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_prestamosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PagosTable, List<Pago>> _pagosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pagos,
          aliasName: $_aliasNameGenerator(db.cajas.id, db.pagos.cajaId));

  $$PagosTableProcessedTableManager get pagosRefs {
    final manager = $$PagosTableTableManager($_db, $_db.pagos)
        .filter((f) => f.cajaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CajasTableFilterComposer extends Composer<_$AppDatabase, $CajasTable> {
  $$CajasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get saldoInicial => $composableBuilder(
      column: $table.saldoInicial, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get saldoActual => $composableBuilder(
      column: $table.saldoActual, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activa => $composableBuilder(
      column: $table.activa, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion,
      builder: (column) => ColumnFilters(column));

  Expression<bool> prestamosRefs(
      Expression<bool> Function($$PrestamosTableFilterComposer f) f) {
    final $$PrestamosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.cajaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableFilterComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pagosRefs(
      Expression<bool> Function($$PagosTableFilterComposer f) f) {
    final $$PagosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.cajaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableFilterComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CajasTableOrderingComposer
    extends Composer<_$AppDatabase, $CajasTable> {
  $$CajasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombre => $composableBuilder(
      column: $table.nombre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get saldoInicial => $composableBuilder(
      column: $table.saldoInicial,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get saldoActual => $composableBuilder(
      column: $table.saldoActual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activa => $composableBuilder(
      column: $table.activa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion,
      builder: (column) => ColumnOrderings(column));
}

class $$CajasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CajasTable> {
  $$CajasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<double> get saldoInicial => $composableBuilder(
      column: $table.saldoInicial, builder: (column) => column);

  GeneratedColumn<double> get saldoActual => $composableBuilder(
      column: $table.saldoActual, builder: (column) => column);

  GeneratedColumn<bool> get activa =>
      $composableBuilder(column: $table.activa, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion, builder: (column) => column);

  Expression<T> prestamosRefs<T extends Object>(
      Expression<T> Function($$PrestamosTableAnnotationComposer a) f) {
    final $$PrestamosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.cajaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableAnnotationComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pagosRefs<T extends Object>(
      Expression<T> Function($$PagosTableAnnotationComposer a) f) {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.cajaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableAnnotationComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CajasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CajasTable,
    Caja,
    $$CajasTableFilterComposer,
    $$CajasTableOrderingComposer,
    $$CajasTableAnnotationComposer,
    $$CajasTableCreateCompanionBuilder,
    $$CajasTableUpdateCompanionBuilder,
    (Caja, $$CajasTableReferences),
    Caja,
    PrefetchHooks Function({bool prestamosRefs, bool pagosRefs})> {
  $$CajasTableTableManager(_$AppDatabase db, $CajasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CajasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CajasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CajasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nombre = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<double> saldoInicial = const Value.absent(),
            Value<double> saldoActual = const Value.absent(),
            Value<bool> activa = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<DateTime?> fechaActualizacion = const Value.absent(),
          }) =>
              CajasCompanion(
            id: id,
            nombre: nombre,
            tipo: tipo,
            descripcion: descripcion,
            saldoInicial: saldoInicial,
            saldoActual: saldoActual,
            activa: activa,
            fechaCreacion: fechaCreacion,
            fechaActualizacion: fechaActualizacion,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nombre,
            required String tipo,
            Value<String?> descripcion = const Value.absent(),
            Value<double> saldoInicial = const Value.absent(),
            Value<double> saldoActual = const Value.absent(),
            Value<bool> activa = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<DateTime?> fechaActualizacion = const Value.absent(),
          }) =>
              CajasCompanion.insert(
            id: id,
            nombre: nombre,
            tipo: tipo,
            descripcion: descripcion,
            saldoInicial: saldoInicial,
            saldoActual: saldoActual,
            activa: activa,
            fechaCreacion: fechaCreacion,
            fechaActualizacion: fechaActualizacion,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$CajasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({prestamosRefs = false, pagosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (prestamosRefs) db.prestamos,
                if (pagosRefs) db.pagos
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (prestamosRefs)
                    await $_getPrefetchedData<Caja, $CajasTable, Prestamo>(
                        currentTable: table,
                        referencedTable:
                            $$CajasTableReferences._prestamosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CajasTableReferences(db, table, p0).prestamosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.cajaId == item.id),
                        typedResults: items),
                  if (pagosRefs)
                    await $_getPrefetchedData<Caja, $CajasTable, Pago>(
                        currentTable: table,
                        referencedTable:
                            $$CajasTableReferences._pagosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CajasTableReferences(db, table, p0).pagosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.cajaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CajasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CajasTable,
    Caja,
    $$CajasTableFilterComposer,
    $$CajasTableOrderingComposer,
    $$CajasTableAnnotationComposer,
    $$CajasTableCreateCompanionBuilder,
    $$CajasTableUpdateCompanionBuilder,
    (Caja, $$CajasTableReferences),
    Caja,
    PrefetchHooks Function({bool prestamosRefs, bool pagosRefs})>;
typedef $$PrestamosTableCreateCompanionBuilder = PrestamosCompanion Function({
  Value<int> id,
  required String codigo,
  required int clienteId,
  required int cajaId,
  required double montoOriginal,
  required double montoTotal,
  required double saldoPendiente,
  required double tasaInteres,
  required String tipoInteres,
  required int plazoMeses,
  required double cuotaMensual,
  required DateTime fechaInicio,
  required DateTime fechaVencimiento,
  required String estado,
  Value<String?> observaciones,
  Value<DateTime> fechaRegistro,
  Value<DateTime?> fechaActualizacion,
});
typedef $$PrestamosTableUpdateCompanionBuilder = PrestamosCompanion Function({
  Value<int> id,
  Value<String> codigo,
  Value<int> clienteId,
  Value<int> cajaId,
  Value<double> montoOriginal,
  Value<double> montoTotal,
  Value<double> saldoPendiente,
  Value<double> tasaInteres,
  Value<String> tipoInteres,
  Value<int> plazoMeses,
  Value<double> cuotaMensual,
  Value<DateTime> fechaInicio,
  Value<DateTime> fechaVencimiento,
  Value<String> estado,
  Value<String?> observaciones,
  Value<DateTime> fechaRegistro,
  Value<DateTime?> fechaActualizacion,
});

final class $$PrestamosTableReferences
    extends BaseReferences<_$AppDatabase, $PrestamosTable, Prestamo> {
  $$PrestamosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias(
          $_aliasNameGenerator(db.prestamos.clienteId, db.clientes.id));

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<int>('cliente_id')!;

    final manager = $$ClientesTableTableManager($_db, $_db.clientes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CajasTable _cajaIdTable(_$AppDatabase db) => db.cajas
      .createAlias($_aliasNameGenerator(db.prestamos.cajaId, db.cajas.id));

  $$CajasTableProcessedTableManager get cajaId {
    final $_column = $_itemColumn<int>('caja_id')!;

    final manager = $$CajasTableTableManager($_db, $_db.cajas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cajaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CuotasTable, List<Cuota>> _cuotasRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.cuotas,
          aliasName:
              $_aliasNameGenerator(db.prestamos.id, db.cuotas.prestamoId));

  $$CuotasTableProcessedTableManager get cuotasRefs {
    final manager = $$CuotasTableTableManager($_db, $_db.cuotas)
        .filter((f) => f.prestamoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cuotasRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PagosTable, List<Pago>> _pagosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.pagos,
          aliasName:
              $_aliasNameGenerator(db.prestamos.id, db.pagos.prestamoId));

  $$PagosTableProcessedTableManager get pagosRefs {
    final manager = $$PagosTableTableManager($_db, $_db.pagos)
        .filter((f) => f.prestamoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MovimientosTable, List<Movimiento>>
      _movimientosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.movimientos,
          aliasName:
              $_aliasNameGenerator(db.prestamos.id, db.movimientos.prestamoId));

  $$MovimientosTableProcessedTableManager get movimientosRefs {
    final manager = $$MovimientosTableTableManager($_db, $_db.movimientos)
        .filter((f) => f.prestamoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_movimientosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PrestamosTableFilterComposer
    extends Composer<_$AppDatabase, $PrestamosTable> {
  $$PrestamosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get codigo => $composableBuilder(
      column: $table.codigo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoOriginal => $composableBuilder(
      column: $table.montoOriginal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoTotal => $composableBuilder(
      column: $table.montoTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get saldoPendiente => $composableBuilder(
      column: $table.saldoPendiente,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tasaInteres => $composableBuilder(
      column: $table.tasaInteres, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoInteres => $composableBuilder(
      column: $table.tipoInteres, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plazoMeses => $composableBuilder(
      column: $table.plazoMeses, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cuotaMensual => $composableBuilder(
      column: $table.cuotaMensual, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaInicio => $composableBuilder(
      column: $table.fechaInicio, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion,
      builder: (column) => ColumnFilters(column));

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableFilterComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CajasTableFilterComposer get cajaId {
    final $$CajasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableFilterComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> cuotasRefs(
      Expression<bool> Function($$CuotasTableFilterComposer f) f) {
    final $$CuotasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cuotas,
        getReferencedColumn: (t) => t.prestamoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CuotasTableFilterComposer(
              $db: $db,
              $table: $db.cuotas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pagosRefs(
      Expression<bool> Function($$PagosTableFilterComposer f) f) {
    final $$PagosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.prestamoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableFilterComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> movimientosRefs(
      Expression<bool> Function($$MovimientosTableFilterComposer f) f) {
    final $$MovimientosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.movimientos,
        getReferencedColumn: (t) => t.prestamoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MovimientosTableFilterComposer(
              $db: $db,
              $table: $db.movimientos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PrestamosTableOrderingComposer
    extends Composer<_$AppDatabase, $PrestamosTable> {
  $$PrestamosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get codigo => $composableBuilder(
      column: $table.codigo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoOriginal => $composableBuilder(
      column: $table.montoOriginal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoTotal => $composableBuilder(
      column: $table.montoTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get saldoPendiente => $composableBuilder(
      column: $table.saldoPendiente,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tasaInteres => $composableBuilder(
      column: $table.tasaInteres, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoInteres => $composableBuilder(
      column: $table.tipoInteres, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plazoMeses => $composableBuilder(
      column: $table.plazoMeses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cuotaMensual => $composableBuilder(
      column: $table.cuotaMensual,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaInicio => $composableBuilder(
      column: $table.fechaInicio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observaciones => $composableBuilder(
      column: $table.observaciones,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion,
      builder: (column) => ColumnOrderings(column));

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableOrderingComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CajasTableOrderingComposer get cajaId {
    final $$CajasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableOrderingComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PrestamosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrestamosTable> {
  $$PrestamosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<double> get montoOriginal => $composableBuilder(
      column: $table.montoOriginal, builder: (column) => column);

  GeneratedColumn<double> get montoTotal => $composableBuilder(
      column: $table.montoTotal, builder: (column) => column);

  GeneratedColumn<double> get saldoPendiente => $composableBuilder(
      column: $table.saldoPendiente, builder: (column) => column);

  GeneratedColumn<double> get tasaInteres => $composableBuilder(
      column: $table.tasaInteres, builder: (column) => column);

  GeneratedColumn<String> get tipoInteres => $composableBuilder(
      column: $table.tipoInteres, builder: (column) => column);

  GeneratedColumn<int> get plazoMeses => $composableBuilder(
      column: $table.plazoMeses, builder: (column) => column);

  GeneratedColumn<double> get cuotaMensual => $composableBuilder(
      column: $table.cuotaMensual, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaInicio => $composableBuilder(
      column: $table.fechaInicio, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaActualizacion => $composableBuilder(
      column: $table.fechaActualizacion, builder: (column) => column);

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableAnnotationComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CajasTableAnnotationComposer get cajaId {
    final $$CajasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableAnnotationComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> cuotasRefs<T extends Object>(
      Expression<T> Function($$CuotasTableAnnotationComposer a) f) {
    final $$CuotasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cuotas,
        getReferencedColumn: (t) => t.prestamoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CuotasTableAnnotationComposer(
              $db: $db,
              $table: $db.cuotas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pagosRefs<T extends Object>(
      Expression<T> Function($$PagosTableAnnotationComposer a) f) {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.prestamoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableAnnotationComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> movimientosRefs<T extends Object>(
      Expression<T> Function($$MovimientosTableAnnotationComposer a) f) {
    final $$MovimientosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.movimientos,
        getReferencedColumn: (t) => t.prestamoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MovimientosTableAnnotationComposer(
              $db: $db,
              $table: $db.movimientos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PrestamosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PrestamosTable,
    Prestamo,
    $$PrestamosTableFilterComposer,
    $$PrestamosTableOrderingComposer,
    $$PrestamosTableAnnotationComposer,
    $$PrestamosTableCreateCompanionBuilder,
    $$PrestamosTableUpdateCompanionBuilder,
    (Prestamo, $$PrestamosTableReferences),
    Prestamo,
    PrefetchHooks Function(
        {bool clienteId,
        bool cajaId,
        bool cuotasRefs,
        bool pagosRefs,
        bool movimientosRefs})> {
  $$PrestamosTableTableManager(_$AppDatabase db, $PrestamosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrestamosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrestamosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrestamosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> codigo = const Value.absent(),
            Value<int> clienteId = const Value.absent(),
            Value<int> cajaId = const Value.absent(),
            Value<double> montoOriginal = const Value.absent(),
            Value<double> montoTotal = const Value.absent(),
            Value<double> saldoPendiente = const Value.absent(),
            Value<double> tasaInteres = const Value.absent(),
            Value<String> tipoInteres = const Value.absent(),
            Value<int> plazoMeses = const Value.absent(),
            Value<double> cuotaMensual = const Value.absent(),
            Value<DateTime> fechaInicio = const Value.absent(),
            Value<DateTime> fechaVencimiento = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
            Value<DateTime?> fechaActualizacion = const Value.absent(),
          }) =>
              PrestamosCompanion(
            id: id,
            codigo: codigo,
            clienteId: clienteId,
            cajaId: cajaId,
            montoOriginal: montoOriginal,
            montoTotal: montoTotal,
            saldoPendiente: saldoPendiente,
            tasaInteres: tasaInteres,
            tipoInteres: tipoInteres,
            plazoMeses: plazoMeses,
            cuotaMensual: cuotaMensual,
            fechaInicio: fechaInicio,
            fechaVencimiento: fechaVencimiento,
            estado: estado,
            observaciones: observaciones,
            fechaRegistro: fechaRegistro,
            fechaActualizacion: fechaActualizacion,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String codigo,
            required int clienteId,
            required int cajaId,
            required double montoOriginal,
            required double montoTotal,
            required double saldoPendiente,
            required double tasaInteres,
            required String tipoInteres,
            required int plazoMeses,
            required double cuotaMensual,
            required DateTime fechaInicio,
            required DateTime fechaVencimiento,
            required String estado,
            Value<String?> observaciones = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
            Value<DateTime?> fechaActualizacion = const Value.absent(),
          }) =>
              PrestamosCompanion.insert(
            id: id,
            codigo: codigo,
            clienteId: clienteId,
            cajaId: cajaId,
            montoOriginal: montoOriginal,
            montoTotal: montoTotal,
            saldoPendiente: saldoPendiente,
            tasaInteres: tasaInteres,
            tipoInteres: tipoInteres,
            plazoMeses: plazoMeses,
            cuotaMensual: cuotaMensual,
            fechaInicio: fechaInicio,
            fechaVencimiento: fechaVencimiento,
            estado: estado,
            observaciones: observaciones,
            fechaRegistro: fechaRegistro,
            fechaActualizacion: fechaActualizacion,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PrestamosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {clienteId = false,
              cajaId = false,
              cuotasRefs = false,
              pagosRefs = false,
              movimientosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cuotasRefs) db.cuotas,
                if (pagosRefs) db.pagos,
                if (movimientosRefs) db.movimientos
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (clienteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clienteId,
                    referencedTable:
                        $$PrestamosTableReferences._clienteIdTable(db),
                    referencedColumn:
                        $$PrestamosTableReferences._clienteIdTable(db).id,
                  ) as T;
                }
                if (cajaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cajaId,
                    referencedTable:
                        $$PrestamosTableReferences._cajaIdTable(db),
                    referencedColumn:
                        $$PrestamosTableReferences._cajaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cuotasRefs)
                    await $_getPrefetchedData<Prestamo, $PrestamosTable, Cuota>(
                        currentTable: table,
                        referencedTable:
                            $$PrestamosTableReferences._cuotasRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PrestamosTableReferences(db, table, p0)
                                .cuotasRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.prestamoId == item.id),
                        typedResults: items),
                  if (pagosRefs)
                    await $_getPrefetchedData<Prestamo, $PrestamosTable, Pago>(
                        currentTable: table,
                        referencedTable:
                            $$PrestamosTableReferences._pagosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PrestamosTableReferences(db, table, p0).pagosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.prestamoId == item.id),
                        typedResults: items),
                  if (movimientosRefs)
                    await $_getPrefetchedData<Prestamo, $PrestamosTable,
                            Movimiento>(
                        currentTable: table,
                        referencedTable: $$PrestamosTableReferences
                            ._movimientosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PrestamosTableReferences(db, table, p0)
                                .movimientosRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.prestamoId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PrestamosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PrestamosTable,
    Prestamo,
    $$PrestamosTableFilterComposer,
    $$PrestamosTableOrderingComposer,
    $$PrestamosTableAnnotationComposer,
    $$PrestamosTableCreateCompanionBuilder,
    $$PrestamosTableUpdateCompanionBuilder,
    (Prestamo, $$PrestamosTableReferences),
    Prestamo,
    PrefetchHooks Function(
        {bool clienteId,
        bool cajaId,
        bool cuotasRefs,
        bool pagosRefs,
        bool movimientosRefs})>;
typedef $$CuotasTableCreateCompanionBuilder = CuotasCompanion Function({
  Value<int> id,
  required int prestamoId,
  required int numeroCuota,
  required DateTime fechaVencimiento,
  required double montoCuota,
  required double capital,
  required double interes,
  required double saldoPendiente,
  Value<double> montoPagado,
  Value<double> montoMora,
  required String estado,
  Value<DateTime?> fechaPago,
  Value<DateTime> fechaRegistro,
});
typedef $$CuotasTableUpdateCompanionBuilder = CuotasCompanion Function({
  Value<int> id,
  Value<int> prestamoId,
  Value<int> numeroCuota,
  Value<DateTime> fechaVencimiento,
  Value<double> montoCuota,
  Value<double> capital,
  Value<double> interes,
  Value<double> saldoPendiente,
  Value<double> montoPagado,
  Value<double> montoMora,
  Value<String> estado,
  Value<DateTime?> fechaPago,
  Value<DateTime> fechaRegistro,
});

final class $$CuotasTableReferences
    extends BaseReferences<_$AppDatabase, $CuotasTable, Cuota> {
  $$CuotasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PrestamosTable _prestamoIdTable(_$AppDatabase db) => db.prestamos
      .createAlias($_aliasNameGenerator(db.cuotas.prestamoId, db.prestamos.id));

  $$PrestamosTableProcessedTableManager get prestamoId {
    final $_column = $_itemColumn<int>('prestamo_id')!;

    final manager = $$PrestamosTableTableManager($_db, $_db.prestamos)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prestamoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DetallePagosTable, List<DetallePago>>
      _detallePagosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.detallePagos,
              aliasName:
                  $_aliasNameGenerator(db.cuotas.id, db.detallePagos.cuotaId));

  $$DetallePagosTableProcessedTableManager get detallePagosRefs {
    final manager = $$DetallePagosTableTableManager($_db, $_db.detallePagos)
        .filter((f) => f.cuotaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_detallePagosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CuotasTableFilterComposer
    extends Composer<_$AppDatabase, $CuotasTable> {
  $$CuotasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numeroCuota => $composableBuilder(
      column: $table.numeroCuota, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoCuota => $composableBuilder(
      column: $table.montoCuota, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get capital => $composableBuilder(
      column: $table.capital, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get interes => $composableBuilder(
      column: $table.interes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get saldoPendiente => $composableBuilder(
      column: $table.saldoPendiente,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoPagado => $composableBuilder(
      column: $table.montoPagado, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoMora => $composableBuilder(
      column: $table.montoMora, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaPago => $composableBuilder(
      column: $table.fechaPago, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => ColumnFilters(column));

  $$PrestamosTableFilterComposer get prestamoId {
    final $$PrestamosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prestamoId,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableFilterComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> detallePagosRefs(
      Expression<bool> Function($$DetallePagosTableFilterComposer f) f) {
    final $$DetallePagosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.detallePagos,
        getReferencedColumn: (t) => t.cuotaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DetallePagosTableFilterComposer(
              $db: $db,
              $table: $db.detallePagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CuotasTableOrderingComposer
    extends Composer<_$AppDatabase, $CuotasTable> {
  $$CuotasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numeroCuota => $composableBuilder(
      column: $table.numeroCuota, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoCuota => $composableBuilder(
      column: $table.montoCuota, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get capital => $composableBuilder(
      column: $table.capital, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get interes => $composableBuilder(
      column: $table.interes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get saldoPendiente => $composableBuilder(
      column: $table.saldoPendiente,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoPagado => $composableBuilder(
      column: $table.montoPagado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoMora => $composableBuilder(
      column: $table.montoMora, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get estado => $composableBuilder(
      column: $table.estado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaPago => $composableBuilder(
      column: $table.fechaPago, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro,
      builder: (column) => ColumnOrderings(column));

  $$PrestamosTableOrderingComposer get prestamoId {
    final $$PrestamosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prestamoId,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableOrderingComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CuotasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CuotasTable> {
  $$CuotasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get numeroCuota => $composableBuilder(
      column: $table.numeroCuota, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaVencimiento => $composableBuilder(
      column: $table.fechaVencimiento, builder: (column) => column);

  GeneratedColumn<double> get montoCuota => $composableBuilder(
      column: $table.montoCuota, builder: (column) => column);

  GeneratedColumn<double> get capital =>
      $composableBuilder(column: $table.capital, builder: (column) => column);

  GeneratedColumn<double> get interes =>
      $composableBuilder(column: $table.interes, builder: (column) => column);

  GeneratedColumn<double> get saldoPendiente => $composableBuilder(
      column: $table.saldoPendiente, builder: (column) => column);

  GeneratedColumn<double> get montoPagado => $composableBuilder(
      column: $table.montoPagado, builder: (column) => column);

  GeneratedColumn<double> get montoMora =>
      $composableBuilder(column: $table.montoMora, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaPago =>
      $composableBuilder(column: $table.fechaPago, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => column);

  $$PrestamosTableAnnotationComposer get prestamoId {
    final $$PrestamosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prestamoId,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableAnnotationComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> detallePagosRefs<T extends Object>(
      Expression<T> Function($$DetallePagosTableAnnotationComposer a) f) {
    final $$DetallePagosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.detallePagos,
        getReferencedColumn: (t) => t.cuotaId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DetallePagosTableAnnotationComposer(
              $db: $db,
              $table: $db.detallePagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CuotasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CuotasTable,
    Cuota,
    $$CuotasTableFilterComposer,
    $$CuotasTableOrderingComposer,
    $$CuotasTableAnnotationComposer,
    $$CuotasTableCreateCompanionBuilder,
    $$CuotasTableUpdateCompanionBuilder,
    (Cuota, $$CuotasTableReferences),
    Cuota,
    PrefetchHooks Function({bool prestamoId, bool detallePagosRefs})> {
  $$CuotasTableTableManager(_$AppDatabase db, $CuotasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CuotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CuotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CuotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> prestamoId = const Value.absent(),
            Value<int> numeroCuota = const Value.absent(),
            Value<DateTime> fechaVencimiento = const Value.absent(),
            Value<double> montoCuota = const Value.absent(),
            Value<double> capital = const Value.absent(),
            Value<double> interes = const Value.absent(),
            Value<double> saldoPendiente = const Value.absent(),
            Value<double> montoPagado = const Value.absent(),
            Value<double> montoMora = const Value.absent(),
            Value<String> estado = const Value.absent(),
            Value<DateTime?> fechaPago = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
          }) =>
              CuotasCompanion(
            id: id,
            prestamoId: prestamoId,
            numeroCuota: numeroCuota,
            fechaVencimiento: fechaVencimiento,
            montoCuota: montoCuota,
            capital: capital,
            interes: interes,
            saldoPendiente: saldoPendiente,
            montoPagado: montoPagado,
            montoMora: montoMora,
            estado: estado,
            fechaPago: fechaPago,
            fechaRegistro: fechaRegistro,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int prestamoId,
            required int numeroCuota,
            required DateTime fechaVencimiento,
            required double montoCuota,
            required double capital,
            required double interes,
            required double saldoPendiente,
            Value<double> montoPagado = const Value.absent(),
            Value<double> montoMora = const Value.absent(),
            required String estado,
            Value<DateTime?> fechaPago = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
          }) =>
              CuotasCompanion.insert(
            id: id,
            prestamoId: prestamoId,
            numeroCuota: numeroCuota,
            fechaVencimiento: fechaVencimiento,
            montoCuota: montoCuota,
            capital: capital,
            interes: interes,
            saldoPendiente: saldoPendiente,
            montoPagado: montoPagado,
            montoMora: montoMora,
            estado: estado,
            fechaPago: fechaPago,
            fechaRegistro: fechaRegistro,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$CuotasTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {prestamoId = false, detallePagosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (detallePagosRefs) db.detallePagos],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (prestamoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.prestamoId,
                    referencedTable:
                        $$CuotasTableReferences._prestamoIdTable(db),
                    referencedColumn:
                        $$CuotasTableReferences._prestamoIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (detallePagosRefs)
                    await $_getPrefetchedData<Cuota, $CuotasTable, DetallePago>(
                        currentTable: table,
                        referencedTable:
                            $$CuotasTableReferences._detallePagosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CuotasTableReferences(db, table, p0)
                                .detallePagosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.cuotaId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CuotasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CuotasTable,
    Cuota,
    $$CuotasTableFilterComposer,
    $$CuotasTableOrderingComposer,
    $$CuotasTableAnnotationComposer,
    $$CuotasTableCreateCompanionBuilder,
    $$CuotasTableUpdateCompanionBuilder,
    (Cuota, $$CuotasTableReferences),
    Cuota,
    PrefetchHooks Function({bool prestamoId, bool detallePagosRefs})>;
typedef $$PagosTableCreateCompanionBuilder = PagosCompanion Function({
  Value<int> id,
  required String codigo,
  required int prestamoId,
  required int clienteId,
  required int cajaId,
  required double montoPago,
  required double montoCapital,
  required double montoInteres,
  Value<double> montoMora,
  required DateTime fechaPago,
  required String metodoPago,
  Value<String?> observaciones,
  Value<DateTime> fechaRegistro,
});
typedef $$PagosTableUpdateCompanionBuilder = PagosCompanion Function({
  Value<int> id,
  Value<String> codigo,
  Value<int> prestamoId,
  Value<int> clienteId,
  Value<int> cajaId,
  Value<double> montoPago,
  Value<double> montoCapital,
  Value<double> montoInteres,
  Value<double> montoMora,
  Value<DateTime> fechaPago,
  Value<String> metodoPago,
  Value<String?> observaciones,
  Value<DateTime> fechaRegistro,
});

final class $$PagosTableReferences
    extends BaseReferences<_$AppDatabase, $PagosTable, Pago> {
  $$PagosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PrestamosTable _prestamoIdTable(_$AppDatabase db) => db.prestamos
      .createAlias($_aliasNameGenerator(db.pagos.prestamoId, db.prestamos.id));

  $$PrestamosTableProcessedTableManager get prestamoId {
    final $_column = $_itemColumn<int>('prestamo_id')!;

    final manager = $$PrestamosTableTableManager($_db, $_db.prestamos)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prestamoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ClientesTable _clienteIdTable(_$AppDatabase db) => db.clientes
      .createAlias($_aliasNameGenerator(db.pagos.clienteId, db.clientes.id));

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<int>('cliente_id')!;

    final manager = $$ClientesTableTableManager($_db, $_db.clientes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CajasTable _cajaIdTable(_$AppDatabase db) =>
      db.cajas.createAlias($_aliasNameGenerator(db.pagos.cajaId, db.cajas.id));

  $$CajasTableProcessedTableManager get cajaId {
    final $_column = $_itemColumn<int>('caja_id')!;

    final manager = $$CajasTableTableManager($_db, $_db.cajas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cajaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DetallePagosTable, List<DetallePago>>
      _detallePagosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.detallePagos,
          aliasName: $_aliasNameGenerator(db.pagos.id, db.detallePagos.pagoId));

  $$DetallePagosTableProcessedTableManager get detallePagosRefs {
    final manager = $$DetallePagosTableTableManager($_db, $_db.detallePagos)
        .filter((f) => f.pagoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_detallePagosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MovimientosTable, List<Movimiento>>
      _movimientosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.movimientos,
          aliasName: $_aliasNameGenerator(db.pagos.id, db.movimientos.pagoId));

  $$MovimientosTableProcessedTableManager get movimientosRefs {
    final manager = $$MovimientosTableTableManager($_db, $_db.movimientos)
        .filter((f) => f.pagoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_movimientosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PagosTableFilterComposer extends Composer<_$AppDatabase, $PagosTable> {
  $$PagosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get codigo => $composableBuilder(
      column: $table.codigo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoPago => $composableBuilder(
      column: $table.montoPago, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoCapital => $composableBuilder(
      column: $table.montoCapital, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoInteres => $composableBuilder(
      column: $table.montoInteres, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoMora => $composableBuilder(
      column: $table.montoMora, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaPago => $composableBuilder(
      column: $table.fechaPago, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metodoPago => $composableBuilder(
      column: $table.metodoPago, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => ColumnFilters(column));

  $$PrestamosTableFilterComposer get prestamoId {
    final $$PrestamosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prestamoId,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableFilterComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableFilterComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CajasTableFilterComposer get cajaId {
    final $$CajasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableFilterComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> detallePagosRefs(
      Expression<bool> Function($$DetallePagosTableFilterComposer f) f) {
    final $$DetallePagosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.detallePagos,
        getReferencedColumn: (t) => t.pagoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DetallePagosTableFilterComposer(
              $db: $db,
              $table: $db.detallePagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> movimientosRefs(
      Expression<bool> Function($$MovimientosTableFilterComposer f) f) {
    final $$MovimientosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.movimientos,
        getReferencedColumn: (t) => t.pagoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MovimientosTableFilterComposer(
              $db: $db,
              $table: $db.movimientos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PagosTableOrderingComposer
    extends Composer<_$AppDatabase, $PagosTable> {
  $$PagosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get codigo => $composableBuilder(
      column: $table.codigo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoPago => $composableBuilder(
      column: $table.montoPago, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoCapital => $composableBuilder(
      column: $table.montoCapital,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoInteres => $composableBuilder(
      column: $table.montoInteres,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoMora => $composableBuilder(
      column: $table.montoMora, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaPago => $composableBuilder(
      column: $table.fechaPago, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metodoPago => $composableBuilder(
      column: $table.metodoPago, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observaciones => $composableBuilder(
      column: $table.observaciones,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro,
      builder: (column) => ColumnOrderings(column));

  $$PrestamosTableOrderingComposer get prestamoId {
    final $$PrestamosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prestamoId,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableOrderingComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableOrderingComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CajasTableOrderingComposer get cajaId {
    final $$CajasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableOrderingComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PagosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagosTable> {
  $$PagosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<double> get montoPago =>
      $composableBuilder(column: $table.montoPago, builder: (column) => column);

  GeneratedColumn<double> get montoCapital => $composableBuilder(
      column: $table.montoCapital, builder: (column) => column);

  GeneratedColumn<double> get montoInteres => $composableBuilder(
      column: $table.montoInteres, builder: (column) => column);

  GeneratedColumn<double> get montoMora =>
      $composableBuilder(column: $table.montoMora, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaPago =>
      $composableBuilder(column: $table.fechaPago, builder: (column) => column);

  GeneratedColumn<String> get metodoPago => $composableBuilder(
      column: $table.metodoPago, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => column);

  $$PrestamosTableAnnotationComposer get prestamoId {
    final $$PrestamosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prestamoId,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableAnnotationComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clienteId,
        referencedTable: $db.clientes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientesTableAnnotationComposer(
              $db: $db,
              $table: $db.clientes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CajasTableAnnotationComposer get cajaId {
    final $$CajasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableAnnotationComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> detallePagosRefs<T extends Object>(
      Expression<T> Function($$DetallePagosTableAnnotationComposer a) f) {
    final $$DetallePagosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.detallePagos,
        getReferencedColumn: (t) => t.pagoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DetallePagosTableAnnotationComposer(
              $db: $db,
              $table: $db.detallePagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> movimientosRefs<T extends Object>(
      Expression<T> Function($$MovimientosTableAnnotationComposer a) f) {
    final $$MovimientosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.movimientos,
        getReferencedColumn: (t) => t.pagoId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MovimientosTableAnnotationComposer(
              $db: $db,
              $table: $db.movimientos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PagosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PagosTable,
    Pago,
    $$PagosTableFilterComposer,
    $$PagosTableOrderingComposer,
    $$PagosTableAnnotationComposer,
    $$PagosTableCreateCompanionBuilder,
    $$PagosTableUpdateCompanionBuilder,
    (Pago, $$PagosTableReferences),
    Pago,
    PrefetchHooks Function(
        {bool prestamoId,
        bool clienteId,
        bool cajaId,
        bool detallePagosRefs,
        bool movimientosRefs})> {
  $$PagosTableTableManager(_$AppDatabase db, $PagosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> codigo = const Value.absent(),
            Value<int> prestamoId = const Value.absent(),
            Value<int> clienteId = const Value.absent(),
            Value<int> cajaId = const Value.absent(),
            Value<double> montoPago = const Value.absent(),
            Value<double> montoCapital = const Value.absent(),
            Value<double> montoInteres = const Value.absent(),
            Value<double> montoMora = const Value.absent(),
            Value<DateTime> fechaPago = const Value.absent(),
            Value<String> metodoPago = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
          }) =>
              PagosCompanion(
            id: id,
            codigo: codigo,
            prestamoId: prestamoId,
            clienteId: clienteId,
            cajaId: cajaId,
            montoPago: montoPago,
            montoCapital: montoCapital,
            montoInteres: montoInteres,
            montoMora: montoMora,
            fechaPago: fechaPago,
            metodoPago: metodoPago,
            observaciones: observaciones,
            fechaRegistro: fechaRegistro,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String codigo,
            required int prestamoId,
            required int clienteId,
            required int cajaId,
            required double montoPago,
            required double montoCapital,
            required double montoInteres,
            Value<double> montoMora = const Value.absent(),
            required DateTime fechaPago,
            required String metodoPago,
            Value<String?> observaciones = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
          }) =>
              PagosCompanion.insert(
            id: id,
            codigo: codigo,
            prestamoId: prestamoId,
            clienteId: clienteId,
            cajaId: cajaId,
            montoPago: montoPago,
            montoCapital: montoCapital,
            montoInteres: montoInteres,
            montoMora: montoMora,
            fechaPago: fechaPago,
            metodoPago: metodoPago,
            observaciones: observaciones,
            fechaRegistro: fechaRegistro,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PagosTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {prestamoId = false,
              clienteId = false,
              cajaId = false,
              detallePagosRefs = false,
              movimientosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (detallePagosRefs) db.detallePagos,
                if (movimientosRefs) db.movimientos
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (prestamoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.prestamoId,
                    referencedTable:
                        $$PagosTableReferences._prestamoIdTable(db),
                    referencedColumn:
                        $$PagosTableReferences._prestamoIdTable(db).id,
                  ) as T;
                }
                if (clienteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clienteId,
                    referencedTable: $$PagosTableReferences._clienteIdTable(db),
                    referencedColumn:
                        $$PagosTableReferences._clienteIdTable(db).id,
                  ) as T;
                }
                if (cajaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cajaId,
                    referencedTable: $$PagosTableReferences._cajaIdTable(db),
                    referencedColumn:
                        $$PagosTableReferences._cajaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (detallePagosRefs)
                    await $_getPrefetchedData<Pago, $PagosTable, DetallePago>(
                        currentTable: table,
                        referencedTable:
                            $$PagosTableReferences._detallePagosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PagosTableReferences(db, table, p0)
                                .detallePagosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.pagoId == item.id),
                        typedResults: items),
                  if (movimientosRefs)
                    await $_getPrefetchedData<Pago, $PagosTable, Movimiento>(
                        currentTable: table,
                        referencedTable:
                            $$PagosTableReferences._movimientosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PagosTableReferences(db, table, p0)
                                .movimientosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.pagoId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PagosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PagosTable,
    Pago,
    $$PagosTableFilterComposer,
    $$PagosTableOrderingComposer,
    $$PagosTableAnnotationComposer,
    $$PagosTableCreateCompanionBuilder,
    $$PagosTableUpdateCompanionBuilder,
    (Pago, $$PagosTableReferences),
    Pago,
    PrefetchHooks Function(
        {bool prestamoId,
        bool clienteId,
        bool cajaId,
        bool detallePagosRefs,
        bool movimientosRefs})>;
typedef $$DetallePagosTableCreateCompanionBuilder = DetallePagosCompanion
    Function({
  Value<int> id,
  required int pagoId,
  required int cuotaId,
  required double montoAplicado,
  Value<double> montoMora,
  Value<DateTime> fechaRegistro,
});
typedef $$DetallePagosTableUpdateCompanionBuilder = DetallePagosCompanion
    Function({
  Value<int> id,
  Value<int> pagoId,
  Value<int> cuotaId,
  Value<double> montoAplicado,
  Value<double> montoMora,
  Value<DateTime> fechaRegistro,
});

final class $$DetallePagosTableReferences
    extends BaseReferences<_$AppDatabase, $DetallePagosTable, DetallePago> {
  $$DetallePagosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PagosTable _pagoIdTable(_$AppDatabase db) => db.pagos
      .createAlias($_aliasNameGenerator(db.detallePagos.pagoId, db.pagos.id));

  $$PagosTableProcessedTableManager get pagoId {
    final $_column = $_itemColumn<int>('pago_id')!;

    final manager = $$PagosTableTableManager($_db, $_db.pagos)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pagoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CuotasTable _cuotaIdTable(_$AppDatabase db) => db.cuotas
      .createAlias($_aliasNameGenerator(db.detallePagos.cuotaId, db.cuotas.id));

  $$CuotasTableProcessedTableManager get cuotaId {
    final $_column = $_itemColumn<int>('cuota_id')!;

    final manager = $$CuotasTableTableManager($_db, $_db.cuotas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cuotaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DetallePagosTableFilterComposer
    extends Composer<_$AppDatabase, $DetallePagosTable> {
  $$DetallePagosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoAplicado => $composableBuilder(
      column: $table.montoAplicado, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get montoMora => $composableBuilder(
      column: $table.montoMora, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => ColumnFilters(column));

  $$PagosTableFilterComposer get pagoId {
    final $$PagosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pagoId,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableFilterComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CuotasTableFilterComposer get cuotaId {
    final $$CuotasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cuotaId,
        referencedTable: $db.cuotas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CuotasTableFilterComposer(
              $db: $db,
              $table: $db.cuotas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DetallePagosTableOrderingComposer
    extends Composer<_$AppDatabase, $DetallePagosTable> {
  $$DetallePagosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoAplicado => $composableBuilder(
      column: $table.montoAplicado,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get montoMora => $composableBuilder(
      column: $table.montoMora, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro,
      builder: (column) => ColumnOrderings(column));

  $$PagosTableOrderingComposer get pagoId {
    final $$PagosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pagoId,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableOrderingComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CuotasTableOrderingComposer get cuotaId {
    final $$CuotasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cuotaId,
        referencedTable: $db.cuotas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CuotasTableOrderingComposer(
              $db: $db,
              $table: $db.cuotas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DetallePagosTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetallePagosTable> {
  $$DetallePagosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get montoAplicado => $composableBuilder(
      column: $table.montoAplicado, builder: (column) => column);

  GeneratedColumn<double> get montoMora =>
      $composableBuilder(column: $table.montoMora, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => column);

  $$PagosTableAnnotationComposer get pagoId {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pagoId,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableAnnotationComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CuotasTableAnnotationComposer get cuotaId {
    final $$CuotasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cuotaId,
        referencedTable: $db.cuotas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CuotasTableAnnotationComposer(
              $db: $db,
              $table: $db.cuotas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DetallePagosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DetallePagosTable,
    DetallePago,
    $$DetallePagosTableFilterComposer,
    $$DetallePagosTableOrderingComposer,
    $$DetallePagosTableAnnotationComposer,
    $$DetallePagosTableCreateCompanionBuilder,
    $$DetallePagosTableUpdateCompanionBuilder,
    (DetallePago, $$DetallePagosTableReferences),
    DetallePago,
    PrefetchHooks Function({bool pagoId, bool cuotaId})> {
  $$DetallePagosTableTableManager(_$AppDatabase db, $DetallePagosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetallePagosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetallePagosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetallePagosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> pagoId = const Value.absent(),
            Value<int> cuotaId = const Value.absent(),
            Value<double> montoAplicado = const Value.absent(),
            Value<double> montoMora = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
          }) =>
              DetallePagosCompanion(
            id: id,
            pagoId: pagoId,
            cuotaId: cuotaId,
            montoAplicado: montoAplicado,
            montoMora: montoMora,
            fechaRegistro: fechaRegistro,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int pagoId,
            required int cuotaId,
            required double montoAplicado,
            Value<double> montoMora = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
          }) =>
              DetallePagosCompanion.insert(
            id: id,
            pagoId: pagoId,
            cuotaId: cuotaId,
            montoAplicado: montoAplicado,
            montoMora: montoMora,
            fechaRegistro: fechaRegistro,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DetallePagosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({pagoId = false, cuotaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (pagoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pagoId,
                    referencedTable:
                        $$DetallePagosTableReferences._pagoIdTable(db),
                    referencedColumn:
                        $$DetallePagosTableReferences._pagoIdTable(db).id,
                  ) as T;
                }
                if (cuotaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cuotaId,
                    referencedTable:
                        $$DetallePagosTableReferences._cuotaIdTable(db),
                    referencedColumn:
                        $$DetallePagosTableReferences._cuotaIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DetallePagosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DetallePagosTable,
    DetallePago,
    $$DetallePagosTableFilterComposer,
    $$DetallePagosTableOrderingComposer,
    $$DetallePagosTableAnnotationComposer,
    $$DetallePagosTableCreateCompanionBuilder,
    $$DetallePagosTableUpdateCompanionBuilder,
    (DetallePago, $$DetallePagosTableReferences),
    DetallePago,
    PrefetchHooks Function({bool pagoId, bool cuotaId})>;
typedef $$MovimientosTableCreateCompanionBuilder = MovimientosCompanion
    Function({
  Value<int> id,
  required String codigo,
  required int cajaId,
  required String tipo,
  required double monto,
  required String categoria,
  required String descripcion,
  Value<int?> prestamoId,
  Value<int?> pagoId,
  Value<int?> cajaDestinoId,
  required DateTime fecha,
  Value<String?> observaciones,
  Value<DateTime> fechaRegistro,
});
typedef $$MovimientosTableUpdateCompanionBuilder = MovimientosCompanion
    Function({
  Value<int> id,
  Value<String> codigo,
  Value<int> cajaId,
  Value<String> tipo,
  Value<double> monto,
  Value<String> categoria,
  Value<String> descripcion,
  Value<int?> prestamoId,
  Value<int?> pagoId,
  Value<int?> cajaDestinoId,
  Value<DateTime> fecha,
  Value<String?> observaciones,
  Value<DateTime> fechaRegistro,
});

final class $$MovimientosTableReferences
    extends BaseReferences<_$AppDatabase, $MovimientosTable, Movimiento> {
  $$MovimientosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CajasTable _cajaIdTable(_$AppDatabase db) => db.cajas
      .createAlias($_aliasNameGenerator(db.movimientos.cajaId, db.cajas.id));

  $$CajasTableProcessedTableManager get cajaId {
    final $_column = $_itemColumn<int>('caja_id')!;

    final manager = $$CajasTableTableManager($_db, $_db.cajas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cajaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PrestamosTable _prestamoIdTable(_$AppDatabase db) =>
      db.prestamos.createAlias(
          $_aliasNameGenerator(db.movimientos.prestamoId, db.prestamos.id));

  $$PrestamosTableProcessedTableManager? get prestamoId {
    final $_column = $_itemColumn<int>('prestamo_id');
    if ($_column == null) return null;
    final manager = $$PrestamosTableTableManager($_db, $_db.prestamos)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prestamoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PagosTable _pagoIdTable(_$AppDatabase db) => db.pagos
      .createAlias($_aliasNameGenerator(db.movimientos.pagoId, db.pagos.id));

  $$PagosTableProcessedTableManager? get pagoId {
    final $_column = $_itemColumn<int>('pago_id');
    if ($_column == null) return null;
    final manager = $$PagosTableTableManager($_db, $_db.pagos)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pagoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CajasTable _cajaDestinoIdTable(_$AppDatabase db) =>
      db.cajas.createAlias(
          $_aliasNameGenerator(db.movimientos.cajaDestinoId, db.cajas.id));

  $$CajasTableProcessedTableManager? get cajaDestinoId {
    final $_column = $_itemColumn<int>('caja_destino_id');
    if ($_column == null) return null;
    final manager = $$CajasTableTableManager($_db, $_db.cajas)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cajaDestinoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MovimientosTableFilterComposer
    extends Composer<_$AppDatabase, $MovimientosTable> {
  $$MovimientosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get codigo => $composableBuilder(
      column: $table.codigo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monto => $composableBuilder(
      column: $table.monto, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => ColumnFilters(column));

  $$CajasTableFilterComposer get cajaId {
    final $$CajasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableFilterComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PrestamosTableFilterComposer get prestamoId {
    final $$PrestamosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prestamoId,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableFilterComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PagosTableFilterComposer get pagoId {
    final $$PagosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pagoId,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableFilterComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CajasTableFilterComposer get cajaDestinoId {
    final $$CajasTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaDestinoId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableFilterComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MovimientosTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimientosTable> {
  $$MovimientosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get codigo => $composableBuilder(
      column: $table.codigo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipo => $composableBuilder(
      column: $table.tipo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monto => $composableBuilder(
      column: $table.monto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoria => $composableBuilder(
      column: $table.categoria, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observaciones => $composableBuilder(
      column: $table.observaciones,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro,
      builder: (column) => ColumnOrderings(column));

  $$CajasTableOrderingComposer get cajaId {
    final $$CajasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableOrderingComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PrestamosTableOrderingComposer get prestamoId {
    final $$PrestamosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prestamoId,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableOrderingComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PagosTableOrderingComposer get pagoId {
    final $$PagosTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pagoId,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableOrderingComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CajasTableOrderingComposer get cajaDestinoId {
    final $$CajasTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaDestinoId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableOrderingComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MovimientosTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimientosTable> {
  $$MovimientosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
      column: $table.observaciones, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaRegistro => $composableBuilder(
      column: $table.fechaRegistro, builder: (column) => column);

  $$CajasTableAnnotationComposer get cajaId {
    final $$CajasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableAnnotationComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PrestamosTableAnnotationComposer get prestamoId {
    final $$PrestamosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.prestamoId,
        referencedTable: $db.prestamos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PrestamosTableAnnotationComposer(
              $db: $db,
              $table: $db.prestamos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PagosTableAnnotationComposer get pagoId {
    final $$PagosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pagoId,
        referencedTable: $db.pagos,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagosTableAnnotationComposer(
              $db: $db,
              $table: $db.pagos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CajasTableAnnotationComposer get cajaDestinoId {
    final $$CajasTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cajaDestinoId,
        referencedTable: $db.cajas,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CajasTableAnnotationComposer(
              $db: $db,
              $table: $db.cajas,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MovimientosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MovimientosTable,
    Movimiento,
    $$MovimientosTableFilterComposer,
    $$MovimientosTableOrderingComposer,
    $$MovimientosTableAnnotationComposer,
    $$MovimientosTableCreateCompanionBuilder,
    $$MovimientosTableUpdateCompanionBuilder,
    (Movimiento, $$MovimientosTableReferences),
    Movimiento,
    PrefetchHooks Function(
        {bool cajaId, bool prestamoId, bool pagoId, bool cajaDestinoId})> {
  $$MovimientosTableTableManager(_$AppDatabase db, $MovimientosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovimientosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MovimientosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> codigo = const Value.absent(),
            Value<int> cajaId = const Value.absent(),
            Value<String> tipo = const Value.absent(),
            Value<double> monto = const Value.absent(),
            Value<String> categoria = const Value.absent(),
            Value<String> descripcion = const Value.absent(),
            Value<int?> prestamoId = const Value.absent(),
            Value<int?> pagoId = const Value.absent(),
            Value<int?> cajaDestinoId = const Value.absent(),
            Value<DateTime> fecha = const Value.absent(),
            Value<String?> observaciones = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
          }) =>
              MovimientosCompanion(
            id: id,
            codigo: codigo,
            cajaId: cajaId,
            tipo: tipo,
            monto: monto,
            categoria: categoria,
            descripcion: descripcion,
            prestamoId: prestamoId,
            pagoId: pagoId,
            cajaDestinoId: cajaDestinoId,
            fecha: fecha,
            observaciones: observaciones,
            fechaRegistro: fechaRegistro,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String codigo,
            required int cajaId,
            required String tipo,
            required double monto,
            required String categoria,
            required String descripcion,
            Value<int?> prestamoId = const Value.absent(),
            Value<int?> pagoId = const Value.absent(),
            Value<int?> cajaDestinoId = const Value.absent(),
            required DateTime fecha,
            Value<String?> observaciones = const Value.absent(),
            Value<DateTime> fechaRegistro = const Value.absent(),
          }) =>
              MovimientosCompanion.insert(
            id: id,
            codigo: codigo,
            cajaId: cajaId,
            tipo: tipo,
            monto: monto,
            categoria: categoria,
            descripcion: descripcion,
            prestamoId: prestamoId,
            pagoId: pagoId,
            cajaDestinoId: cajaDestinoId,
            fecha: fecha,
            observaciones: observaciones,
            fechaRegistro: fechaRegistro,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MovimientosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {cajaId = false,
              prestamoId = false,
              pagoId = false,
              cajaDestinoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (cajaId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cajaId,
                    referencedTable:
                        $$MovimientosTableReferences._cajaIdTable(db),
                    referencedColumn:
                        $$MovimientosTableReferences._cajaIdTable(db).id,
                  ) as T;
                }
                if (prestamoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.prestamoId,
                    referencedTable:
                        $$MovimientosTableReferences._prestamoIdTable(db),
                    referencedColumn:
                        $$MovimientosTableReferences._prestamoIdTable(db).id,
                  ) as T;
                }
                if (pagoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pagoId,
                    referencedTable:
                        $$MovimientosTableReferences._pagoIdTable(db),
                    referencedColumn:
                        $$MovimientosTableReferences._pagoIdTable(db).id,
                  ) as T;
                }
                if (cajaDestinoId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cajaDestinoId,
                    referencedTable:
                        $$MovimientosTableReferences._cajaDestinoIdTable(db),
                    referencedColumn:
                        $$MovimientosTableReferences._cajaDestinoIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MovimientosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MovimientosTable,
    Movimiento,
    $$MovimientosTableFilterComposer,
    $$MovimientosTableOrderingComposer,
    $$MovimientosTableAnnotationComposer,
    $$MovimientosTableCreateCompanionBuilder,
    $$MovimientosTableUpdateCompanionBuilder,
    (Movimiento, $$MovimientosTableReferences),
    Movimiento,
    PrefetchHooks Function(
        {bool cajaId, bool prestamoId, bool pagoId, bool cajaDestinoId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$CajasTableTableManager get cajas =>
      $$CajasTableTableManager(_db, _db.cajas);
  $$PrestamosTableTableManager get prestamos =>
      $$PrestamosTableTableManager(_db, _db.prestamos);
  $$CuotasTableTableManager get cuotas =>
      $$CuotasTableTableManager(_db, _db.cuotas);
  $$PagosTableTableManager get pagos =>
      $$PagosTableTableManager(_db, _db.pagos);
  $$DetallePagosTableTableManager get detallePagos =>
      $$DetallePagosTableTableManager(_db, _db.detallePagos);
  $$MovimientosTableTableManager get movimientos =>
      $$MovimientosTableTableManager(_db, _db.movimientos);
}
