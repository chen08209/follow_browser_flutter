import 'package:flutter/material.dart';

import '../components.dart';
import '../search/search_panel.dart';

class HomePanel extends StatefulWidget {
  const HomePanel({Key? key}) : super(key: key);

  @override
  State<HomePanel> createState() => _HomePanelState();
}

class _HomePanelState extends State<HomePanel> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SearchPanel(
      title: SearchTitle(),
    );
  }
}

