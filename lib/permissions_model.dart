class Permissionsmodel {
  final int? id;
  final String module;
  final int? sequence;
  late String name;
  final String guard_name;
  final String created_at;
  final String updated_at;

  Permissionsmodel(this.id, this.module, this.sequence, this.name,
      this.guard_name, this.created_at, this.updated_at);

  factory Permissionsmodel.fromJson(Map<String, dynamic> json) {
    return Permissionsmodel(
        json['id'] as int,
        json['module'] as String,
        json['sequence'] ?? '' as int,
        json['name'] ?? '',
        json['guard_name'] ?? '',
        json['created_at'] ?? '',
        json['updated_at'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module,
      'sequence': sequence,
      'name': name,
      'guard_name': guard_name,
      'created_at': created_at,
      'updated_at': updated_at
    };
  }
}
