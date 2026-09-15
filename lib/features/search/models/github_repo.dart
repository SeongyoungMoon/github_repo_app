import 'owner.dart';

class GithubRepo {
  final int id;
  final String fullName;
  final Owner owner;
  final int? subscribersCount;

  const GithubRepo({
    required this.id,
    required this.fullName,
    required this.owner,
    this.subscribersCount,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      owner: Owner.fromJson(json['owner'] as Map<String, dynamic>? ?? {}),
      subscribersCount: json['subscribers_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'owner': owner.toJson(),
      if (subscribersCount != null) 'subscribers_count': subscribersCount,
    };
  }

  GithubRepo copyWith({
    int? id,
    String? fullName,
    Owner? owner,
    int? subscribersCount,
  }) {
    return GithubRepo(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      owner: owner ?? this.owner,
      subscribersCount: subscribersCount ?? this.subscribersCount,
    );
  }
}