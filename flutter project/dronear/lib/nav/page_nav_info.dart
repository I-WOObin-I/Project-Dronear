import 'package:flutter/material.dart';

abstract class NavPage {
  Widget get page;
  IconData get pageIcon;
  String get pageLabel;
}
