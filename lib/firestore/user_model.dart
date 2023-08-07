class UserModel{
  String? email;
  int? credits;
  UserModel({required this.email, required this.credits});
  toJson(){
    return {
      "Email" : email,
      "Credits" : credits
    };
  }
}