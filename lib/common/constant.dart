
import 'package:flutter/material.dart';

const Color cGreenStrong = Color(0xFF0E403C);
const Color cGreenSoft = Color(0xFF98E49B);
const Color cGreenSofter = Color(0xFFBAEDBC);

const Color cYellowSoft = Color(0xFFF9D689);

const Color mainColor = Color(0xFF35A7C2);
const Color cBlueSoft = Color(0xFFA8CEEA);
const Color softBlueColor = Color(0xFF31B4AA);
const Color secondaryColor = Color(0xFF15434E);
const Color blueApkColor = Color(0xFF3997DA);

const Color whiteColor = Color(0xFFFFFFFF);
const Color redSoftColor = Color(0xFFE25C5C);
const Color blackColor = Color(0xFF2C3131);
const Color softBlackColor = Color(0xFF626262);
const List<Color> mainApkGradientList = [Color(0xFF3997DA), Color(0xFF31B4AA)];

const mainApkLinearGradient = LinearGradient(
  colors: [Color(0xFF3997DA), Color(0xFF31B4AA)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const TextStyle basicTextStyleBlack =
    TextStyle(fontWeight: FontWeight.w500, color: blackColor);

const TextStyle text14Black54 =
    TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black54);

const TextStyle text18cgs18 =
    TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: cGreenStrong);

BoxDecoration containerBorderWithRadius = BoxDecoration(
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: blueApkColor, width: 1.5),
  // gradient: mainApkLinearGradient
  color: Colors.white,
);
