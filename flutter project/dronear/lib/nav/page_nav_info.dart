import 'package:flutter/material.dart';

abstract class NavPage {
  Widget get page;
  String get pageLabel;
  IconData get pageIcon;
}
