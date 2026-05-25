import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'academy_category.dart';
import 'player.dart';

class AcademyData {
  static final categoriesList = [
    AcademyCategory(
      title: "Training",
      count: 8,
      icon: FontAwesomeIcons.dumbbell,
    ),
    AcademyCategory(
      title: "Matches",
      count: 5,
      icon: FontAwesomeIcons.trophy,
    ),
    AcademyCategory(
      title: "Skills",
      count: 12,
      icon: FontAwesomeIcons.futbol,
    ),
    AcademyCategory(
      title: "Progress",
      count: 7,
      icon: FontAwesomeIcons.chartLine,
    ),
  ];


}


