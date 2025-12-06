// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  street: json['street'] as String?,
  city: json['city'] as String?,
  zipCode: json['zipCode'] as String?,
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'zipCode': instance.zipCode,
    };

PhoneNumberModel _$PhoneNumberModelFromJson(Map<String, dynamic> json) =>
    PhoneNumberModel(
      type: json['type'] as String?,
      number: json['number'] as String?,
    );

Map<String, dynamic> _$PhoneNumberModelToJson(PhoneNumberModel instance) =>
    <String, dynamic>{'type': instance.type, 'number': instance.number};

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  fullName: json['textField'] as String?,
  bio: json['multilineField'] as String?,
  email: json['emailField'] as String?,
  password: json['passwordField'] as String?,
  age: (json['intNumberField'] as num?)?.toInt(),
  weight: (json['doubleNumberField'] as num?)?.toDouble(),
  birthDate: UserModel._dateFromJson(json['dateField'] as String?),
  termsAccepted: json['booleanField'] as bool? ?? false,
  newsletter: json['checkboxField'] as bool? ?? false,
  gender: json['radioField'] as String?,
  country: json['dropdownField'] as String?,
  hobbies:
      (json['multiselectField'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  address: json['address'] == null
      ? null
      : AddressModel.fromJson(json['address'] as Map<String, dynamic>),
  phoneNumbers:
      (json['phoneNumbers'] as List<dynamic>?)
          ?.map((e) => PhoneNumberModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  preferredTime: json['timeField'] as String?,
  website: json['urlField'] as String?,
  phoneNumber: json['phoneField'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'textField': instance.fullName,
  'multilineField': instance.bio,
  'emailField': instance.email,
  'passwordField': instance.password,
  'intNumberField': instance.age,
  'doubleNumberField': instance.weight,
  'dateField': UserModel._dateToJson(instance.birthDate),
  'booleanField': instance.termsAccepted,
  'checkboxField': instance.newsletter,
  'radioField': instance.gender,
  'dropdownField': instance.country,
  'multiselectField': instance.hobbies,
  'address': instance.address,
  'phoneNumbers': instance.phoneNumbers,
  'timeField': instance.preferredTime,
  'urlField': instance.website,
  'phoneField': instance.phoneNumber,
};
