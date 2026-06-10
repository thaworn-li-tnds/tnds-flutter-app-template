import 'package:flutter/material.dart';

/// Constant sizes to be used in the app (paddings, gaps, rounded corners etc.)
class Sizes {
  static const kP0 = 0.0;
  static const kP1 = 1.0;
  static const kP2 = 2.0;
  static const kP4 = 4.0;
  static const kP6 = 6.0;
  static const kP8 = 8.0;
  static const kP12 = 12.0;
  static const kP16 = 16.0;
  static const kP20 = 20.0;
  static const kP24 = 24.0;
  static const kP28 = 28.0;
  static const kP32 = 32.0;
  static const kP36 = 36.0;
  static const kP40 = 40.0;
  static const kP48 = 48.0;
  static const kP56 = 56.0;
  static const kP60 = 60.0;
  static const kP64 = 64.0;
  static const kP72 = 72.0;
  static const kP80 = 80.0;
  static const kP96 = 96.0;
  static const kP104 = 104.0;
  static const kP112 = 112.0;
  static const kP120 = 120.0;
  static const kP128 = 128.0;
  static const kP132 = 132.0;
  static const kP148 = 148.0;
  static const kP156 = 156.0;
}

/// Constant gap widths
const kGapW1 = SizedBox(width: Sizes.kP1);
const kGapW2 = SizedBox(width: Sizes.kP2);
const kGapW4 = SizedBox(width: Sizes.kP4);
const kGapW6 = SizedBox(width: Sizes.kP6);
const kGapW8 = SizedBox(width: Sizes.kP8);
const kGapW12 = SizedBox(width: Sizes.kP12);
const kGapW16 = SizedBox(width: Sizes.kP16);
const kGapW20 = SizedBox(width: Sizes.kP20);
const kGapW24 = SizedBox(width: Sizes.kP24);
const kGapW28 = SizedBox(width: Sizes.kP28);
const kGapW32 = SizedBox(width: Sizes.kP32);
const kGapW36 = SizedBox(width: Sizes.kP36);
const kGapW40 = SizedBox(width: Sizes.kP40);
const kGapW48 = SizedBox(width: Sizes.kP48);
const kGapW56 = SizedBox(width: Sizes.kP56);
const kGapW64 = SizedBox(width: Sizes.kP64);
const kGapW72 = SizedBox(width: Sizes.kP72);
const kGapW80 = SizedBox(width: Sizes.kP80);
const kGapW96 = SizedBox(width: Sizes.kP96);
const kGapW104 = SizedBox(width: Sizes.kP104);
const kGapW112 = SizedBox(width: Sizes.kP112);
const kGapW128 = SizedBox(width: Sizes.kP128);
const kGapW132 = SizedBox(width: Sizes.kP132);
const kGapW148 = SizedBox(width: Sizes.kP148);
const kGapW156 = SizedBox(width: Sizes.kP156);

/// Constant gap heights
const kGapH1 = SizedBox(height: Sizes.kP1);
const kGapH2 = SizedBox(height: Sizes.kP2);
const kGapH4 = SizedBox(height: Sizes.kP4);
const kGapH6 = SizedBox(height: Sizes.kP6);
const kGapH8 = SizedBox(height: Sizes.kP8);
const kGapH12 = SizedBox(height: Sizes.kP12);
const kGapH16 = SizedBox(height: Sizes.kP16);
const kGapH20 = SizedBox(height: Sizes.kP20);
const kGapH24 = SizedBox(height: Sizes.kP24);
const kGapH28 = SizedBox(height: Sizes.kP28);
const kGapH32 = SizedBox(height: Sizes.kP32);
const kGapH36 = SizedBox(height: Sizes.kP36);
const kGapH40 = SizedBox(height: Sizes.kP40);
const kGapH48 = SizedBox(height: Sizes.kP48);
const kGapH56 = SizedBox(height: Sizes.kP56);
const kGapH64 = SizedBox(height: Sizes.kP64);
const kGapH72 = SizedBox(height: Sizes.kP72);
const kGapH80 = SizedBox(height: Sizes.kP80);
const kGapH96 = SizedBox(height: Sizes.kP96);
const kGapH104 = SizedBox(height: Sizes.kP104);
const kGapH112 = SizedBox(height: Sizes.kP112);
const kGapH128 = SizedBox(height: Sizes.kP128);
const kGapH132 = SizedBox(height: Sizes.kP132);
const kGapH148 = SizedBox(height: Sizes.kP148);
const kGapH156 = SizedBox(height: Sizes.kP156);

// Radius constants
const kRadius2 = Radius.circular(2);
const kRadius4 = Radius.circular(4);
const kRadius8 = Radius.circular(8);
const kRadius12 = Radius.circular(12);
const kRadius16 = Radius.circular(16);
const kRadius24 = Radius.circular(24);
const kRadius32 = Radius.circular(32);
const kRadiusFull = Radius.circular(9999);

const kMinFontSize = 12.0;

/// XS Shadow
final kShadowXs = [
  const BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 0),
    blurRadius: 2,
    spreadRadius: -1,
  ),
  const BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 0,
  ),
];

/// SM Shadow
final kShadowSm = [
  const BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 0),
    blurRadius: 4,
    spreadRadius: -2,
  ),
  const BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 4),
    blurRadius: 6,
    spreadRadius: -1,
  ),
];

/// MD Shadow
final kShadowMd = [
  const BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 0),
    blurRadius: 6,
    spreadRadius: -4,
  ),
  const BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 10),
    blurRadius: 15,
    spreadRadius: -3,
  ),
];

/// LG Shadow
final kShadowLg = [
  const BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 0),
    blurRadius: 10,
    spreadRadius: -6,
  ),
  const BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    offset: Offset(0, 20),
    blurRadius: 25,
    spreadRadius: -5,
  ),
];

/// XL Shadow
final kShadowXl = [
  const BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.25),
    offset: Offset(0, 25),
    blurRadius: 50,
    spreadRadius: -12,
  ),
];
