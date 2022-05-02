import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolsgo_web/src/circulars/modal/circulars.dart';

List<String> rolesPerCircularType(String circularType) {
  switch (circularType) {
    case 'A':
      return ["Admins", "Teachers", "Non-teaching staff", "Drivers"];
    case 'B':
      return ["Teachers", "Non-teaching staff", "Drivers"];
    case 'C':
      return ["Admins", "Non-teaching staff", "Drivers"];
    case 'D':
      return ["Admins", "Teachers", "Drivers"];
    case 'E':
      return ["Admins", "Teachers", "Non-teaching staff"];
    case 'F':
      return ["Non-teaching staff", "Drivers"];
    case 'G':
      return ["Teachers", "Drivers"];
    case 'H':
      return ["Teachers", "Non-teaching staff"];
    case 'I':
      return ["Admins", "Drivers"];
    case 'J':
      return ["Admins", "Non-teaching staff"];
    case 'K':
      return ["Admins", "Teachers"];
    case 'L':
      return ["Drivers"];
    case 'M':
      return ["Non-teaching staff"];
    case 'N':
      return ["Teachers"];
    case 'O':
      return ["Admins"];
    default:
      return [""];
  }
}

Widget getRoleWidget(role) {
  return SizedBox(
    height: 50,
    width: 150,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 35,
          width: 35,
          padding: const EdgeInsets.all(5),
          child: Center(
            child: Image.asset(
              "assets/images/avatar.png",
              fit: BoxFit.scaleDown,
              height: 25,
              width: 25,
            ),
          ),
        ),
        Container(
          height: 50,
          width: 115,
          padding: const EdgeInsets.all(5),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              role,
            ),
          ),
        ),
      ],
    ),
  );
}

bool isAppliedForAdmin(CircularBean circular) => ['A', 'C', 'D', 'E', 'I', 'J', 'K', 'O'].contains(circular.circularType);
bool isAppliedForTeacher(CircularBean circular) => ['A', 'B', 'D', 'E', 'G', 'H', 'K', 'N'].contains(circular.circularType);
bool isAppliedForNonTeachingStaff(CircularBean circular) => ['A', 'B', 'C', 'E', 'F', 'H', 'J', 'M'].contains(circular.circularType);
bool isAppliedForDriver(CircularBean circular) => ['A', 'B', 'C', 'D', 'F', 'G', 'I', 'L'].contains(circular.circularType);

void changeCircularType(CircularBean circular, bool newValue, String role) {
  bool isAppliedForAdmin = ['A', 'C', 'D', 'E', 'I', 'J', 'K', 'O'].contains(circular.circularType);
  bool isAppliedForTeacher = ['A', 'B', 'D', 'E', 'G', 'H', 'K', 'N'].contains(circular.circularType);
  bool isAppliedForNonTeachingStaff = ['A', 'B', 'C', 'E', 'F', 'H', 'J', 'M'].contains(circular.circularType);
  bool isAppliedForDriver = ['A', 'B', 'C', 'D', 'F', 'G', 'I', 'L'].contains(circular.circularType);
  if (role == "Admins") {
    isAppliedForAdmin = newValue;
  } else if (role == "Teachers") {
    isAppliedForTeacher = newValue;
  } else if (role == "Non-teaching staff") {
    isAppliedForNonTeachingStaff = newValue;
  } else if (role == "Drivers") {
    isAppliedForDriver = newValue;
  }
  if (isAppliedForAdmin && isAppliedForTeacher && isAppliedForNonTeachingStaff && isAppliedForDriver) {
    circular.circularType = "A";
  } else if (!isAppliedForAdmin && isAppliedForTeacher && isAppliedForNonTeachingStaff && isAppliedForDriver) {
    circular.circularType = "B";
  } else if (isAppliedForAdmin && !isAppliedForTeacher && isAppliedForNonTeachingStaff && isAppliedForDriver) {
    circular.circularType = "C";
  } else if (isAppliedForAdmin && isAppliedForTeacher && !isAppliedForNonTeachingStaff && isAppliedForDriver) {
    circular.circularType = "D";
  } else if (isAppliedForAdmin && isAppliedForTeacher && isAppliedForNonTeachingStaff && !isAppliedForDriver) {
    circular.circularType = "E";
  } else if (!isAppliedForAdmin && !isAppliedForTeacher && isAppliedForNonTeachingStaff && isAppliedForDriver) {
    circular.circularType = "F";
  } else if (!isAppliedForAdmin && isAppliedForTeacher && !isAppliedForNonTeachingStaff && isAppliedForDriver) {
    circular.circularType = "G";
  } else if (!isAppliedForAdmin && isAppliedForTeacher && isAppliedForNonTeachingStaff && !isAppliedForDriver) {
    circular.circularType = "H";
  } else if (isAppliedForAdmin && !isAppliedForTeacher && !isAppliedForNonTeachingStaff && isAppliedForDriver) {
    circular.circularType = "I";
  } else if (isAppliedForAdmin && !isAppliedForTeacher && isAppliedForNonTeachingStaff && !isAppliedForDriver) {
    circular.circularType = "J";
  } else if (isAppliedForAdmin && isAppliedForTeacher && !isAppliedForNonTeachingStaff && !isAppliedForDriver) {
    circular.circularType = "K";
  } else if (!isAppliedForAdmin && !isAppliedForTeacher && !isAppliedForNonTeachingStaff && isAppliedForDriver) {
    circular.circularType = "L";
  } else if (!isAppliedForAdmin && !isAppliedForTeacher && isAppliedForNonTeachingStaff && !isAppliedForDriver) {
    circular.circularType = "M";
  } else if (!isAppliedForAdmin && isAppliedForTeacher && !isAppliedForNonTeachingStaff && !isAppliedForDriver) {
    circular.circularType = "N";
  } else if (isAppliedForAdmin && !isAppliedForTeacher && !isAppliedForNonTeachingStaff && !isAppliedForDriver) {
    circular.circularType = "O";
  } else if (!isAppliedForAdmin && !isAppliedForTeacher && !isAppliedForNonTeachingStaff && !isAppliedForDriver) {
    circular.circularType = "P";
  }
}

bool checkValueForCircular(String role, CircularBean circular) {
  switch (role) {
    case "Admins":
      return isAppliedForAdmin(circular);
    case "Teachers":
      return isAppliedForTeacher(circular);
    case "Non-teaching staff":
      return isAppliedForNonTeachingStaff(circular);
    case "Drivers":
      return isAppliedForDriver(circular);
    default:
      return false;
  }
}
