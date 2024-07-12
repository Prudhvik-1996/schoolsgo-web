class ModuleAction {

  String? action;
  String? guidedView;
  String? stepByStepGuide;
  bool? defaultToStepByStep;

  ModuleAction({
    this.action,
    this.guidedView,
    this.stepByStepGuide,
    this.defaultToStepByStep,
  });
  ModuleAction.fromJson(Map<String, dynamic> json) {
    action = json['action']?.toString();
    guidedView = json['guidedView']?.toString();
    stepByStepGuide = json['stepByStepGuide']?.toString();
    defaultToStepByStep = json['defaultToStepByStep'];
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['action'] = action;
    data['guidedView'] = guidedView;
    data['stepByStepGuide'] = stepByStepGuide;
    data['defaultToStepByStep'] = defaultToStepByStep;
    return data;
  }
}

class SubModule {

  String? subModule;
  List<ModuleAction?>? actions;

  SubModule({
    this.subModule,
    this.actions,
  });
  SubModule.fromJson(Map<String, dynamic> json) {
    subModule = json['subModule']?.toString();
    if (json['actions'] != null) {
      final v = json['actions'];
      final arr0 = <ModuleAction>[];
      v.forEach((v) {
        arr0.add(ModuleAction.fromJson(v));
      });
      actions = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['subModule'] = subModule;
    if (actions != null) {
      final v = actions;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['actions'] = arr0;
    }
    return data;
  }
}

class DemoModule {

  String? module;
  String? imageAsset;
  List<SubModule?>? subModules;

  DemoModule({
    this.module,
    this.imageAsset,
    this.subModules,
  });
  DemoModule.fromJson(Map<String, dynamic> json) {
    module = json['module']?.toString();
    imageAsset = json['imageAsset']?.toString();
    if (json['subModules'] != null) {
      final v = json['subModules'];
      final arr0 = <SubModule>[];
      v.forEach((v) {
        arr0.add(SubModule.fromJson(v));
      });
      subModules = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['module'] = module;
    data['imageAsset'] = imageAsset;
    if (subModules != null) {
      final v = subModules;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['subModules'] = arr0;
    }
    return data;
  }
}

class DemoObject {

  List<DemoModule?>? modules;

  DemoObject({
    this.modules,
  });
  DemoObject.fromJson(Map<String, dynamic> json) {
    if (json['modules'] != null) {
      final v = json['modules'];
      final arr0 = <DemoModule>[];
      v.forEach((v) {
        arr0.add(DemoModule.fromJson(v));
      });
      modules = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (modules != null) {
      final v = modules;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['modules'] = arr0;
    }
    return data;
  }
}
