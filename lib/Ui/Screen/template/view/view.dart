import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../controller/controller.dart';

class View extends GetView<Controller> {
  const View({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: ''),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: StyleX.paddingApp,
          child: Column(children: []),
        ),
      ),
    );
  }
}
