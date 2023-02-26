class UserModel {
  String? name;
  String? email;
  String? id;
  String? image;
  String? token;

  UserModel({
    this.name,
    this.email,
    this.id,
    this.image,
    this.token,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    id = json['id'];
    image = json['image'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['id'] = id;
    data['image'] = image;
    data['token'] = token;
    return data;
  }
}
