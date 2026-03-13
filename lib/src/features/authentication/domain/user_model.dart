class UserModel {
  final String uid;
  final String email;
  final String ime;
  final String prezime;
  final String? telefon;
  final String? spol;
  final DateTime? datumRodjenja;
  final String? bio;
  final String? profilnaSlika;
  final DateTime createdAt;
  final double avgRating;
  final int reviewCount;

  UserModel({
    required this.uid,
    required this.email,
    required this.ime,
    required this.prezime,
    this.telefon,
    this.spol,
    this.datumRodjenja,
    this.bio,
    this.profilnaSlika,
    required this.createdAt,
    this.avgRating = 0.0,
    this.reviewCount = 0,
  });

  String get punoIme => '$ime $prezime'.trim();

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      ime: map['ime'] ?? '',
      prezime: map['prezime'] ?? '',
      telefon: map['telefon'],
      spol: map['spol'],
      datumRodjenja: map['datumRodjenja'] != null
          ? DateTime.tryParse(map['datumRodjenja'])
          : null,
      bio: map['bio'],
      profilnaSlika: map['profilnaSlika'],
      avgRating: (map['avgRating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] ?? 0) as int,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'ime': ime,
      'prezime': prezime,
      'telefon': telefon,
      'spol': spol,
      'datumRodjenja': datumRodjenja?.toIso8601String(),
      'bio': bio,
      'profilnaSlika': profilnaSlika,
      'avgRating': avgRating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? ime,
    String? prezime,
    String? telefon,
    String? spol,
    DateTime? datumRodjenja,
    String? bio,
    String? profilnaSlika,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      ime: ime ?? this.ime,
      prezime: prezime ?? this.prezime,
      telefon: telefon ?? this.telefon,
      spol: spol ?? this.spol,
      datumRodjenja: datumRodjenja ?? this.datumRodjenja,
      bio: bio ?? this.bio,
      profilnaSlika: profilnaSlika ?? this.profilnaSlika,
      createdAt: createdAt,
    );
  }
}