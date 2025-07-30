import 'package:flutter/material.dart';

import '../../../Config/config.dart';
import '../../../Data/Model/user/user_statistics.dart';
import '../../Widget/Custom/Card/statistics_card.dart';

class UserStatisticsSection extends StatelessWidget {
  const UserStatisticsSection({super.key, required this.statistics});

  final UserStatisticsX statistics;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Flexible(
                child: StatisticsCardX(
                  title: "Courses I've completed 🥳",
                  subValue: "courses",
                  value: statistics.completedCourses,
                  icon: IconX.school,
                ),
              ),
              SizedBox(width: 12),
              Flexible(
                child: StatisticsCardX(
                  title: "Minutes I learned",
                  subValue: "minute",
                  value: statistics.minutes,
                  icon: IconX.schedule,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            children: [
              Flexible(
                child: StatisticsCardX(
                  title: "Grades Rate",
                  subValue: "%",
                  value: statistics.points,
                  icon: IconX.trophy,
                ),
              ),
              SizedBox(width: 12),
              Flexible(
                child: StatisticsCardX(
                  title: "Your certificates",
                  subValue: "certificate",
                  value: statistics.certificates,
                  icon: IconX.verified,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
