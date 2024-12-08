class Group {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final List<String> members;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required List<String> members, // Use List<String> to allow modifications
  }) : members = _ensureCreatorInMembers(members, createdBy);

  // Ensures that the creator is always in the members list
  static List<String> _ensureCreatorInMembers(List<String> members, String createdBy) {
    if (!members.contains(createdBy)) {
      return [...members, createdBy]; // Create a new list with the creator added
    }
    return members;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'members': members,
    };
  }

  static Group fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdBy: map['createdBy'],
      members: List<String>.from(map['members']),
    );
  }
}
