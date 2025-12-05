import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class AddressModel {
  final String? street;
  final String? city;
  final String? zipCode;

  AddressModel({
    this.street,
    this.city,
    this.zipCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  AddressModel copyWith({
    String? street,
    String? city,
    String? zipCode,
  }) {
    return AddressModel(
      street: street ?? this.street,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
    );
  }

  @override
  String toString() {
    return 'AddressModel(street: $street, city: $city, zipCode: $zipCode)';
  }
}

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'textField')
  final String? fullName;

  @JsonKey(name: 'multilineField')
  final String? bio;

  @JsonKey(name: 'emailField')
  final String? email;

  @JsonKey(name: 'passwordField')
  final String? password;

  @JsonKey(name: 'intNumberField')
  final int? age;

  @JsonKey(name: 'doubleNumberField')
  final double? weight;

  @JsonKey(name: 'dateField', fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? birthDate;

  @JsonKey(name: 'booleanField')
  final bool termsAccepted;

  @JsonKey(name: 'checkboxField')
  final bool newsletter;

  @JsonKey(name: 'radioField')
  final String? gender;

  @JsonKey(name: 'dropdownField')
  final String? country;

  @JsonKey(name: 'multiselectField')
  final List<String> hobbies;

  @JsonKey(name: 'address')
  final AddressModel? address;

  UserModel({
    this.fullName,
    this.bio,
    this.email,
    this.password,
    this.age,
    this.weight,
    this.birthDate,
    this.termsAccepted = false,
    this.newsletter = false,
    this.gender,
    this.country,
    this.hobbies = const [],
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  static DateTime? _dateFromJson(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static String? _dateToJson(DateTime? date) {
    return date?.toIso8601String();
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? password,
    int? age,
    double? weight,
    DateTime? birthDate,
    bool? termsAccepted,
    String? country,
    List<String>? hobbies,
    AddressModel? address,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      weight: weight ?? this.weight,
    birthDate: birthDate ?? this.birthDate,
    termsAccepted: termsAccepted ?? this.termsAccepted,
    newsletter: newsletter ?? this.newsletter,
    gender: gender ?? this.gender,
    country: country ?? this.country,
      hobbies: hobbies ?? this.hobbies,
      address: address ?? this.address,
    );
  }

  static UserModel getExample() {
    return UserModel(
      fullName: 'Mario Rossi',
      bio: 'Software developer passionate about Flutter and mobile development. Love creating beautiful and functional applications.',
      email: 'mario.rossi@example.com',
      password: 'SecurePass123!',
      age: 30,
      weight: 75.5,
      birthDate: DateTime(1994, 5, 15),
      termsAccepted: true,
      newsletter: true,
      gender: 'male',
      country: 'IT',
      hobbies: ['reading', 'sports', 'music'],
      address: AddressModel(
        street: 'Via Roma 123',
        city: 'Milano',
        zipCode: '20100',
      ),
    );
  }

  @override
  String toString() {
    return 'UserModel(fullName: $fullName, bio: $bio, email: $email, age: $age, weight: $weight, birthDate: $birthDate, termsAccepted: $termsAccepted, newsletter: $newsletter, gender: $gender, country: $country, hobbies: $hobbies, address: $address)';
  }
}
