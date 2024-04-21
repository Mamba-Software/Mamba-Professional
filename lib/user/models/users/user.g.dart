// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usuario _$UsuarioFromJson(Map<String, dynamic> json) => Usuario(
      id: json['id'] as String? ?? '',
      notificationToken: json['notificationToken'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      nick: json['nick'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      noImageUrl: json['noImageUrl'] as String? ?? '',
      isFirst: json['isFirst'] as bool? ?? false,
      isTrainer: json['isTrainer'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? false,
      freeSession: json['freeSession'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isDark: json['isDark'] as bool? ?? false,
      gender: json['gender'] as int? ?? 0,
      dateJoined: json['dateJoined'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      testGroup: json['testGroup'] as String? ?? '',
      idioma: json['idioma'] as String? ?? '',
      brandID: json['brandID'] as String? ?? '',
      sessions: json['sessions'] as String? ?? '',
      active: json['active'] as bool? ?? false,
      purchaseId: json['purchaseId'] as String? ?? '',
    )
      ..lastEventAt = Usuario._fromJsonTimestamp(json['lastEventAt'])
      ..brandRole = json['brandRole'] as int? ?? 0;

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
      'id': instance.id,
      'notificationToken': instance.notificationToken,
      'email': instance.email,
      'name': instance.name,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'nick': instance.nick,
      'imageUrl': instance.imageUrl,
      'noImageUrl': instance.noImageUrl,
      'isFirst': instance.isFirst,
      'isTrainer': instance.isTrainer,
      'isPrivate': instance.isPrivate,
      'freeSession': instance.freeSession,
      'isAdmin': instance.isAdmin,
      'isDark': instance.isDark,
      'gender': instance.gender,
      'dateJoined': instance.dateJoined,
      'dateOfBirth': instance.dateOfBirth,
      'testGroup': instance.testGroup,
      'idioma': instance.idioma,
      'brandID': instance.brandID,
      'sessions': instance.sessions,
      'active': instance.active,
      'lastEventAt': Usuario._toJsonTimestamp(instance.lastEventAt),
      'purchaseId': instance.purchaseId,
      'brandRole': instance.brandRole,
    };
