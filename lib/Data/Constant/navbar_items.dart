import 'package:flutter/material.dart';
import '../../Config/config.dart';
import '../../Ui/Screen/Course/AllCourses/view/view.dart';
import '../../Ui/Screen/Events/CalendarEvents/view/view.dart';
import '../../Ui/Screen/Home/view/view.dart';
import '../../Ui/Screen/Profile/ProfileDetails/view/view.dart';
import '../Model/basic/root_page.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Control data of nav bar elements
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
List<RootPageX> navBarItems = [
  RootPageX(
    view: const HomeView(),
    label: 'Home',
    icon: const Icon(IconX.home),
  ),
  RootPageX(
    view: const AllCoursesView(),
    label: 'Courses',
    icon: const Icon(IconX.clinical_notes),
  ),
  RootPageX(
    view: const CalendarView(),
    label: 'Calendar',
    icon: const Icon(IconX.today),
  ),
  RootPageX(
    view: const ProfileDetailsView(),
    label: 'Profile',
    icon: const Icon(IconX.person),
  ),
];
