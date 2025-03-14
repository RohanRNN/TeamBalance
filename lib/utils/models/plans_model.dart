/* 
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var myRootNode = Root.fromJson(map);
*/ 
class Feature {
    int? id;
    int? planid;
    String? feature;

    Feature({this.id, this.planid, this.feature}); 

    Feature.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        planid = json['plan_id'];
        feature = json['feature'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['plan_id'] = planid;
        data['feature'] = feature;
        return data;
    }
}

class PlanModel {
    int? id;
    String? planname;
    String? plantitle;
    String? planidentifier;
    String? price;
    String? localprice;
    String? reward;
    bool? platformtype;
    bool? isactive;
    List<Feature?>? features;

    PlanModel({this.id, this.planname, this.plantitle, this.planidentifier, this.price, this.localprice, this.reward, this.platformtype, this.isactive, this.features}); 

    PlanModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        planname = json['plan_name'];
        plantitle = json['plan_title'];
        planidentifier = json['plan_identifier'] ?? '';
        price = json['price'];
        localprice = json['localprice'];
        reward = json['reward'];
        platformtype = json['platform_type'];
        isactive = json['is_active'];
        if (json['features'] != null) {
         features = <Feature>[];
         json['features'].forEach((v) {
         features!.add(Feature.fromJson(v));
        });
      }
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = Map<String, dynamic>();
        data['id'] = id;
        data['plan_name'] = planname;
        data['plan_title'] = plantitle;
        data['plan_identifier'] = planidentifier ?? '';
        data['price'] = price;
        data['localprice'] = localprice;
        data['reward'] = reward;
        data['platform_type'] = platformtype;
        data['is_active'] = isactive;
        data['features'] =features != null ? features!.map((v) => v?.toJson()).toList() : null;
        return data;
    }
}

