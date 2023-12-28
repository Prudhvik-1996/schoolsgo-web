import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/constants/constants.dart';
import 'package:schoolsgo_web/src/utils/http_utils.dart';
import 'package:schoolsgo_web/src/utils/int_utils.dart';

class GetInventoryItemsRequest {
/*
{
  "isHostel": "",
  "itemId": 0,
  "schoolId": 0
}
*/

  String? isHostel;
  int? itemId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetInventoryItemsRequest({
    this.isHostel,
    this.itemId,
    this.schoolId,
  });

  GetInventoryItemsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    isHostel = json['isHostel']?.toString();
    itemId = json['itemId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['isHostel'] = isHostel;
    data['itemId'] = itemId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class InventoryItemBean {
/*
{
  "agent": 0,
  "availableStock": 0,
  "isHostel": "",
  "itemId": 0,
  "itemName": "string",
  "mediaType": "string",
  "mediaUrl": "string",
  "mediaUrlId": 0,
  "status": "initiated",
  "unit": "string"
}
*/

  int? agent;
  int? availableStock;
  String? isHostel;
  int? itemId;
  String? itemName;
  String? mediaType;
  String? mediaUrl;
  int? mediaUrlId;
  String? status;
  String? unit;
  Map<String, dynamic> __origJson = {};

  InventoryItemBean({
    this.agent,
    this.availableStock,
    this.isHostel,
    this.itemId,
    this.itemName,
    this.mediaType,
    this.mediaUrl,
    this.mediaUrlId,
    this.status,
    this.unit,
  });

  InventoryItemBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    availableStock = json['availableStock']?.toInt();
    isHostel = json['isHostel']?.toString();
    itemId = json['itemId']?.toInt();
    itemName = json['itemName']?.toString();
    mediaType = json['mediaType']?.toString();
    mediaUrl = json['mediaUrl']?.toString();
    mediaUrlId = json['mediaUrlId']?.toInt();
    status = json['status']?.toString();
    unit = json['unit']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['availableStock'] = availableStock;
    data['isHostel'] = isHostel;
    data['itemId'] = itemId;
    data['itemName'] = itemName;
    data['mediaType'] = mediaType;
    data['mediaUrl'] = mediaUrl;
    data['mediaUrlId'] = mediaUrlId;
    data['status'] = status;
    data['unit'] = unit;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetInventoryItemsResponse {
/*
{
  "errorCode": "INTERNAL_SERVER_ERROR",
  "errorMessage": "string",
  "httpStatus": "100",
  "inventoryItemBeans": [
    {
      "agent": 0,
      "availableStock": 0,
      "isHostel": "",
      "itemId": 0,
      "itemName": "string",
      "mediaType": "string",
      "mediaUrl": "string",
      "mediaUrlId": 0,
      "status": "initiated",
      "unit": "string"
    }
  ],
  "responseStatus": "success"
}
*/

  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<InventoryItemBean?>? inventoryItemBeans;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetInventoryItemsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.inventoryItemBeans,
    this.responseStatus,
  });

  GetInventoryItemsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['inventoryItemBeans'] != null) {
      final v = json['inventoryItemBeans'];
      final arr0 = <InventoryItemBean>[];
      v.forEach((v) {
        arr0.add(InventoryItemBean.fromJson(v));
      });
      inventoryItemBeans = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (inventoryItemBeans != null) {
      final v = inventoryItemBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['inventoryItemBeans'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetInventoryItemsResponse> getInventoryItems(GetInventoryItemsRequest getInventoryItemsRequest) async {
  debugPrint("Raising request to getInventoryItems with request ${jsonEncode(getInventoryItemsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_INVENTORY_ITEMS;

  GetInventoryItemsResponse getInventoryItemsResponse = await HttpUtils.post(
    _url,
    getInventoryItemsRequest.toJson(),
    GetInventoryItemsResponse.fromJson,
  );

  debugPrint("GetInventoryItemsResponse ${getInventoryItemsResponse.toJson()}");
  return getInventoryItemsResponse;
}

class GetInventoryItemsConsumptionRequest {
  String? isHostel;
  int? itemId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetInventoryItemsConsumptionRequest({
    this.isHostel,
    this.itemId,
    this.schoolId,
  });

  GetInventoryItemsConsumptionRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    isHostel = json['isHostel']?.toString();
    itemId = json['itemId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['isHostel'] = isHostel;
    data['itemId'] = itemId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class InventoryItemConsumptionBean {
  int? agent;
  String? date;
  int? inventoryConsumptionId;
  int? itemId;
  String? itemName;
  String? lastUpdated;
  double? quantityUsed;
  String? status;
  String? unit;
  Map<String, dynamic> __origJson = {};

  TextEditingController itemNameController = TextEditingController();

  InventoryItemConsumptionBean({
    this.agent,
    this.date,
    this.inventoryConsumptionId,
    this.itemId,
    this.itemName,
    this.lastUpdated,
    this.quantityUsed,
    this.status,
    this.unit,
  }) {
    itemNameController.text = itemName ?? "";
  }

  InventoryItemConsumptionBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    date = json['date']?.toString();
    inventoryConsumptionId = json['inventoryConsumptionId']?.toInt();
    itemId = json['itemId']?.toInt();
    itemName = json['itemName']?.toString();
    lastUpdated = json['lastUpdated']?.toString();
    quantityUsed = json['quantityUsed']?.toDouble();
    status = json['status']?.toString();
    unit = json['unit']?.toString();
    itemNameController.text = itemName ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['date'] = date;
    data['inventoryConsumptionId'] = inventoryConsumptionId;
    data['itemId'] = itemId;
    data['itemName'] = itemName;
    data['lastUpdated'] = lastUpdated;
    data['quantityUsed'] = quantityUsed;
    data['status'] = status;
    data['unit'] = unit;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetInventoryItemsConsumptionResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<InventoryItemConsumptionBean?>? inventoryItemConsumptionBeans;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetInventoryItemsConsumptionResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.inventoryItemConsumptionBeans,
    this.responseStatus,
  });

  GetInventoryItemsConsumptionResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['inventoryItemConsumptionBeans'] != null) {
      final v = json['inventoryItemConsumptionBeans'];
      final arr0 = <InventoryItemConsumptionBean>[];
      v.forEach((v) {
        arr0.add(InventoryItemConsumptionBean.fromJson(v));
      });
      inventoryItemConsumptionBeans = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (inventoryItemConsumptionBeans != null) {
      final v = inventoryItemConsumptionBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['inventoryItemConsumptionBeans'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetInventoryItemsConsumptionResponse> getInventoryItemsConsumption(
    GetInventoryItemsConsumptionRequest getInventoryItemsConsumptionRequest) async {
  debugPrint("Raising request to getInventoryItemsConsumption with request ${jsonEncode(getInventoryItemsConsumptionRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_INVENTORY_ITEM_CONSUMPTION;

  GetInventoryItemsConsumptionResponse getInventoryItemsConsumptionResponse = await HttpUtils.post(
    _url,
    getInventoryItemsConsumptionRequest.toJson(),
    GetInventoryItemsConsumptionResponse.fromJson,
  );

  debugPrint("GetInventoryItemsConsumptionResponse ${getInventoryItemsConsumptionResponse.toJson()}");
  return getInventoryItemsConsumptionResponse;
}

class GetInventoryPoRequest {
  String? isHostel;
  int? poId;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  GetInventoryPoRequest({
    this.isHostel,
    this.poId,
    this.schoolId,
  });

  GetInventoryPoRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    isHostel = json['isHostel']?.toString();
    poId = json['poId']?.toInt();
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['isHostel'] = isHostel;
    data['poId'] = poId;
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class InventoryPurchaseItemBean {
  int? agent;
  int? amount;
  int? itemTransactionId;
  int? itemId;
  String? itemName;
  int? poId;
  int? poItemId;
  double? quantity;
  String? status;
  Map<String, dynamic> __origJson = {};

  TextEditingController itemNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  InventoryPurchaseItemBean({
    this.agent,
    this.amount,
    this.itemTransactionId,
    this.itemId,
    this.itemName,
    this.poId,
    this.poItemId,
    this.quantity,
    this.status,
  }) {
    itemNameController.text = itemName ?? "";
    quantityController.text = quantity == null ? "" : doubleToStringAsFixed(quantity ?? 0);
    amountController.text = amount == null ? "" : doubleToStringAsFixed((amount ?? 0) / 100.0);
  }

  String? get errorTextForItem {
    if ((itemName ?? "").trim().isEmpty) {
      return "Item cannot be empty";
    }
    return null;
  }

  bool get isFilledCompletely => itemId != null && (quantity ?? 0) != 0 && (amount ?? 0) != 0;

  InventoryPurchaseItemBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agent = json['agent']?.toInt();
    amount = json['amount']?.toInt();
    itemTransactionId = json['itemTransactionId']?.toInt();
    itemId = json['itemId']?.toInt();
    itemName = json['itemName']?.toString();
    poId = json['poId']?.toInt();
    poItemId = json['poItemId']?.toInt();
    quantity = json['quantity']?.toDouble();
    status = json['status']?.toString();
    itemNameController.text = itemName ?? "";
    quantityController.text = quantity == null ? "" : doubleToStringAsFixed(quantity ?? 0);
    amountController.text = amount == null ? "" : doubleToStringAsFixed((amount ?? 0) / 100.0);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agent'] = agent;
    data['amount'] = amount;
    data['itemTransactionId'] = itemTransactionId;
    data['itemId'] = itemId;
    data['itemName'] = itemName;
    data['poId'] = poId;
    data['poItemId'] = poItemId;
    data['quantity'] = quantity;
    data['status'] = status;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class InventoryPoBean {
  int? amount;
  String? description;
  List<InventoryPurchaseItemBean?>? inventoryPurchaseItemBeans;
  String? mediaType;
  String? mediaUrl;
  int? mediaUrlId;
  String? modeOfPayment;
  int? poId;
  String? status;
  String? transactionDate;
  int? transactionId;
  Map<String, dynamic> __origJson = {};

  TextEditingController descriptionController = TextEditingController();
  ScrollController horizontalScrollController = ScrollController();

  InventoryPoBean({
    this.amount,
    this.description,
    this.inventoryPurchaseItemBeans,
    this.mediaType,
    this.mediaUrl,
    this.mediaUrlId,
    this.modeOfPayment,
    this.poId,
    this.status,
    this.transactionDate,
    this.transactionId,
  }) {
    descriptionController.text = description ?? "";
  }

  int get computeTotal => (inventoryPurchaseItemBeans??[]).map((e) => e?.amount ?? 0).fold(0, (int? a, b) => (a ?? 0) + b);

  InventoryPoBean.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    description = json['description']?.toString();
    if (json['inventoryPurchaseItemBeans'] != null) {
      final v = json['inventoryPurchaseItemBeans'];
      final arr0 = <InventoryPurchaseItemBean>[];
      v.forEach((v) {
        arr0.add(InventoryPurchaseItemBean.fromJson(v));
      });
      inventoryPurchaseItemBeans = arr0;
    }
    mediaType = json['mediaType']?.toString();
    mediaUrl = json['mediaUrl']?.toString();
    mediaUrlId = json['mediaUrlId']?.toInt();
    modeOfPayment = json['modeOfPayment']?.toString();
    poId = json['poId']?.toInt();
    status = json['status']?.toString();
    transactionDate = json['transactionDate']?.toString();
    transactionId = json['transactionId']?.toInt();
    descriptionController.text = description ?? "";
  }

  fromJson(Map<String, dynamic> json) {
    __origJson = json;
    amount = json['amount']?.toInt();
    description = json['description']?.toString();
    if (json['inventoryPurchaseItemBeans'] != null) {
      final v = json['inventoryPurchaseItemBeans'];
      final arr0 = <InventoryPurchaseItemBean>[];
      v.forEach((v) {
        arr0.add(InventoryPurchaseItemBean.fromJson(v));
      });
      inventoryPurchaseItemBeans = arr0;
    }
    mediaType = json['mediaType']?.toString();
    mediaUrl = json['mediaUrl']?.toString();
    mediaUrlId = json['mediaUrlId']?.toInt();
    modeOfPayment = json['modeOfPayment']?.toString();
    poId = json['poId']?.toInt();
    status = json['status']?.toString();
    transactionDate = json['transactionDate']?.toString();
    transactionId = json['transactionId']?.toInt();
    descriptionController.text = description ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['amount'] = amount;
    data['description'] = description;
    if (inventoryPurchaseItemBeans != null) {
      final v = inventoryPurchaseItemBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['inventoryPurchaseItemBeans'] = arr0;
    }
    data['mediaType'] = mediaType;
    data['mediaUrl'] = mediaUrl;
    data['mediaUrlId'] = mediaUrlId;
    data['modeOfPayment'] = modeOfPayment;
    data['poId'] = poId;
    data['status'] = status;
    data['transactionDate'] = transactionDate;
    data['transactionId'] = transactionId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class GetInventoryPoResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  List<InventoryPoBean?>? inventoryPoBeans;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  GetInventoryPoResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.inventoryPoBeans,
    this.responseStatus,
  });

  GetInventoryPoResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    if (json['inventoryPoBeans'] != null) {
      final v = json['inventoryPoBeans'];
      final arr0 = <InventoryPoBean>[];
      v.forEach((v) {
        arr0.add(InventoryPoBean.fromJson(v));
      });
      inventoryPoBeans = arr0;
    }
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    if (inventoryPoBeans != null) {
      final v = inventoryPoBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['inventoryPoBeans'] = arr0;
    }
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<GetInventoryPoResponse> getInventoryPo(GetInventoryPoRequest getInventoryPoRequest) async {
  debugPrint("Raising request to getInventoryPo with request ${jsonEncode(getInventoryPoRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + GET_INVENTORY_PO;

  GetInventoryPoResponse getInventoryPoResponse = await HttpUtils.post(
    _url,
    getInventoryPoRequest.toJson(),
    GetInventoryPoResponse.fromJson,
  );

  debugPrint("GetInventoryPoResponse ${getInventoryPoResponse.toJson()}");
  return getInventoryPoResponse;
}

class CreateOrUpdateInventoryItemsRequest {
  int? agentId;
  List<InventoryItemBean?>? inventoryItemBeans;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateInventoryItemsRequest({
    this.agentId,
    this.inventoryItemBeans,
    this.schoolId,
  });

  CreateOrUpdateInventoryItemsRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    if (json['inventoryItemBeans'] != null) {
      final v = json['inventoryItemBeans'];
      final arr0 = <InventoryItemBean>[];
      v.forEach((v) {
        arr0.add(InventoryItemBean.fromJson(v));
      });
      inventoryItemBeans = arr0;
    }
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    if (inventoryItemBeans != null) {
      final v = inventoryItemBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['inventoryItemBeans'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateInventoryItemsResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateInventoryItemsResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateInventoryItemsResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateInventoryItemsResponse> createOrUpdateInventoryItems(
    CreateOrUpdateInventoryItemsRequest createOrUpdateInventoryItemsRequest) async {
  debugPrint("Raising request to createOrUpdateInventoryItems with request ${jsonEncode(createOrUpdateInventoryItemsRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_INVENTORY_ITEMS;

  CreateOrUpdateInventoryItemsResponse createOrUpdateInventoryItemsResponse = await HttpUtils.post(
    _url,
    createOrUpdateInventoryItemsRequest.toJson(),
    CreateOrUpdateInventoryItemsResponse.fromJson,
  );

  debugPrint("CreateOrUpdateInventoryItemsResponse ${createOrUpdateInventoryItemsResponse.toJson()}");
  return createOrUpdateInventoryItemsResponse;
}

class CreateOrUpdateInventoryItemsConsumptionRequest {
  int? agentId;
  List<InventoryItemConsumptionBean?>? inventoryItemConsumptionBeans;
  int? schoolId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateInventoryItemsConsumptionRequest({
    this.agentId,
    this.inventoryItemConsumptionBeans,
    this.schoolId,
  });

  CreateOrUpdateInventoryItemsConsumptionRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    if (json['inventoryItemConsumptionBeans'] != null) {
      final v = json['inventoryItemConsumptionBeans'];
      final arr0 = <InventoryItemConsumptionBean>[];
      v.forEach((v) {
        arr0.add(InventoryItemConsumptionBean.fromJson(v));
      });
      inventoryItemConsumptionBeans = arr0;
    }
    schoolId = json['schoolId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    if (inventoryItemConsumptionBeans != null) {
      final v = inventoryItemConsumptionBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['inventoryItemConsumptionBeans'] = arr0;
    }
    data['schoolId'] = schoolId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateInventoryItemsConsumptionResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateInventoryItemsConsumptionResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateInventoryItemsConsumptionResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateInventoryItemsConsumptionResponse> createOrUpdateInventoryItemsConsumption(
    CreateOrUpdateInventoryItemsConsumptionRequest createOrUpdateInventoryItemsConsumptionRequest) async {
  debugPrint(
      "Raising request to createOrUpdateInventoryItemsConsumption with request ${jsonEncode(createOrUpdateInventoryItemsConsumptionRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_INVENTORY_ITEMS_CONSUMPTION;

  CreateOrUpdateInventoryItemsConsumptionResponse createOrUpdateInventoryItemsConsumptionResponse = await HttpUtils.post(
    _url,
    createOrUpdateInventoryItemsConsumptionRequest.toJson(),
    CreateOrUpdateInventoryItemsConsumptionResponse.fromJson,
  );

  debugPrint("CreateOrUpdateInventoryItemsConsumptionResponse ${createOrUpdateInventoryItemsConsumptionResponse.toJson()}");
  return createOrUpdateInventoryItemsConsumptionResponse;
}

class CreateOrUpdateInventoryPoRequest {
  int? agentId;
  int? amount;
  String? description;
  List<InventoryPurchaseItemBean?>? inventoryPurchaseItemBeans;
  String? isHostel;
  String? mediaType;
  String? mediaUrl;
  int? mediaUrlId;
  String? modeOfPayment;
  int? poId;
  int? schoolId;
  String? status;
  String? transactionDate;
  int? transactionId;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateInventoryPoRequest({
    this.agentId,
    this.amount,
    this.description,
    this.inventoryPurchaseItemBeans,
    this.isHostel,
    this.mediaType,
    this.mediaUrl,
    this.mediaUrlId,
    this.modeOfPayment,
    this.poId,
    this.schoolId,
    this.status,
    this.transactionDate,
    this.transactionId,
  });

  CreateOrUpdateInventoryPoRequest.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    agentId = json['agentId']?.toInt();
    amount = json['amount']?.toInt();
    description = json['description']?.toString();
    if (json['inventoryPurchaseItemBeans'] != null) {
      final v = json['inventoryPurchaseItemBeans'];
      final arr0 = <InventoryPurchaseItemBean>[];
      v.forEach((v) {
        arr0.add(InventoryPurchaseItemBean.fromJson(v));
      });
      inventoryPurchaseItemBeans = arr0;
    }
    isHostel = json['isHostel']?.toString();
    mediaType = json['mediaType']?.toString();
    mediaUrl = json['mediaUrl']?.toString();
    mediaUrlId = json['mediaUrlId']?.toInt();
    modeOfPayment = json['modeOfPayment']?.toString();
    poId = json['poId']?.toInt();
    schoolId = json['schoolId']?.toInt();
    status = json['status']?.toString();
    transactionDate = json['transactionDate']?.toString();
    transactionId = json['transactionId']?.toInt();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['agentId'] = agentId;
    data['amount'] = amount;
    data['description'] = description;
    if (inventoryPurchaseItemBeans != null) {
      final v = inventoryPurchaseItemBeans;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data['inventoryPurchaseItemBeans'] = arr0;
    }
    data['isHostel'] = isHostel;
    data['mediaType'] = mediaType;
    data['mediaUrl'] = mediaUrl;
    data['mediaUrlId'] = mediaUrlId;
    data['modeOfPayment'] = modeOfPayment;
    data['poId'] = poId;
    data['schoolId'] = schoolId;
    data['status'] = status;
    data['transactionDate'] = transactionDate;
    data['transactionId'] = transactionId;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

class CreateOrUpdateInventoryPoResponse {
  String? errorCode;
  String? errorMessage;
  String? httpStatus;
  String? responseStatus;
  Map<String, dynamic> __origJson = {};

  CreateOrUpdateInventoryPoResponse({
    this.errorCode,
    this.errorMessage,
    this.httpStatus,
    this.responseStatus,
  });

  CreateOrUpdateInventoryPoResponse.fromJson(Map<String, dynamic> json) {
    __origJson = json;
    errorCode = json['errorCode']?.toString();
    errorMessage = json['errorMessage']?.toString();
    httpStatus = json['httpStatus']?.toString();
    responseStatus = json['responseStatus']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errorCode'] = errorCode;
    data['errorMessage'] = errorMessage;
    data['httpStatus'] = httpStatus;
    data['responseStatus'] = responseStatus;
    return data;
  }

  Map<String, dynamic> origJson() => __origJson;
}

Future<CreateOrUpdateInventoryPoResponse> createOrUpdateInventoryPo(CreateOrUpdateInventoryPoRequest createOrUpdateInventoryPoRequest) async {
  debugPrint("Raising request to createOrUpdateInventoryPo with request ${jsonEncode(createOrUpdateInventoryPoRequest.toJson())}");
  String _url = SCHOOLS_GO_BASE_URL + CREATE_OR_UPDATE_INVENTORY_PO;

  CreateOrUpdateInventoryPoResponse createOrUpdateInventoryPoResponse = await HttpUtils.post(
    _url,
    createOrUpdateInventoryPoRequest.toJson(),
    CreateOrUpdateInventoryPoResponse.fromJson,
  );

  debugPrint("CreateOrUpdateInventoryPoResponse ${createOrUpdateInventoryPoResponse.toJson()}");
  return createOrUpdateInventoryPoResponse;
}
