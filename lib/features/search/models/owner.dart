class Owner {
  final String avatarUrl;

  const Owner({
    required this.avatarUrl,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_url': avatarUrl,
    };
  }
}