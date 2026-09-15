class Owner {
  final String avatarUrl;
  final String login;

  const Owner({
    required this.avatarUrl,
    required this.login,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      avatarUrl: json['avatar_url'] as String? ?? '',
      login: json['login'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_url': avatarUrl,
      'login': login,
    };
  }
}