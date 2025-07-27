class KYCModel {
  bool? success;
  List<Data>? data;

  KYCModel({this.success, this.data});

  KYCModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  String? fatherName;
  int? cnic;
  String? criminalRecord;
  String? dob;
  String? city;
  String? state;
  String? address;
  String? profilePicture;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.name,
    this.fatherName,
    this.cnic,
    this.criminalRecord,
    this.dob,
    this.city,
    this.state,
    this.address,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    fatherName = json['fatherName'];
    cnic = json['cnic'];
    criminalRecord = json['criminalRecord'];
    dob = json['dob'];
    city = json['city'];
    state = json['state'];
    address = json['address'];
    profilePicture = json['profilePicture'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['fatherName'] = fatherName;
    data['cnic'] = cnic;
    data['criminalRecord'] = criminalRecord;
    data['dob'] = dob;
    data['city'] = city;
    data['state'] = state;
    data['address'] = address;
    data['profilePicture'] = profilePicture;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}