import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:neo_ai_app/firestore/user_model.dart';

class AddData extends GetxController {
  UserModel? user;
  RxInt _credits = 0.obs;

  RxInt get getCreditValue => _credits;

  addUserData(UserModel user) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("User")
        .where("Email", isEqualTo: user.email)
        .get();
    if (querySnapshot.size == 0) {
      FirebaseFirestore.instance.collection("User").add(user.toJson());
      _credits.value = 50;
    } else {
      _credits.value = querySnapshot.docs[0].get("Credits").toInt();
    }
  }

  updateUserData(String email, bool creditsBought) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection("User")
        .where("Email", isEqualTo: email)
        .get();
    int credits = querySnapshot.docs[0].get("Credits").toInt();
    await FirebaseFirestore.instance
        .collection("User")
        .doc(querySnapshot.docs[0].id)
        .update({"Credits": creditsBought ? credits + 50 : credits - 1});
    querySnapshot = await FirebaseFirestore.instance
        .collection("User")
        .where("Email", isEqualTo: email)
        .get();
    _credits.value = querySnapshot.docs[0].get("Credits").toInt();
  }
}
