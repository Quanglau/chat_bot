
class UserCustom {
  var id;
  var email;
  var name;
  var photoURL;
  var sex;
  var phoneNumber;
  var birth;
  var file;
  var address;

  UserCustom(
      this.id,
      this.email,
      this.name,
      this.photoURL
      );


  UserCustom.fullInfo(
      this.id,
      this.email,
      this.name,
      this.photoURL,
      this.sex,
      this.phoneNumber,
      this.birth,
      this.address
      );

  factory UserCustom.fromJson(Map<dynamic, dynamic> json) {
    return UserCustom.fullInfo(json['id'], json['email'], json['fullName'],
        json['imagePath'], json['sex'], json['phoneNumber'], json['birthDay'], json['address']);
  }

  String toString() {
    return 'id: $id, email: $email, fullName: $name, imagePath: $photoURL,'
        ' sex: $sex, phoneNumber: $phoneNumber, birthDay: $birth, address: $address';
  }


}