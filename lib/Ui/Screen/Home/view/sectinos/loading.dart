import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../Config/config.dart';
import '../../../../Animation/animation.dart';

class HomeLoading extends StatelessWidget {
  const HomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Level progress card
          Stack(
            children: [
              /// Background
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(gradient: ColorX.primaryGradient),
              ),

              /// Content
              Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  right: StyleX.hPaddingApp,
                  left: StyleX.hPaddingApp,
                ),
                child: ShimmerAnimationX(height: 126),
              ).fadeAnimation100,
            ],
          ),

          /// Spacer
          SizedBox(height: 20),

          /// Content
          Padding(
            padding: EdgeInsets.only(
              left: StyleX.hPaddingApp,
              right: StyleX.hPaddingApp,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Levels progress label
                ShimmerAnimationShapeX.label().fadeAnimation150,

                /// Levels progress content
                ShimmerAnimationX(height: 86).fadeAnimation150,

                /// Spacer
                SizedBox(height: 24),

                /// My progress label
                ShimmerAnimationShapeX.label().fadeAnimation150,

                /// My progress content part 1
                Row(
                  children: [
                    Expanded(child: ShimmerAnimationX(height: 137)),
                    SizedBox(width: 12),
                    Expanded(child: ShimmerAnimationX(height: 137)),
                  ],
                ).fadeAnimation150,

                /// Spacer
                SizedBox(height: 12),

                /// My progress content part 2
                Row(
                  children: [
                    Expanded(child: ShimmerAnimationX(height: 137)),
                    SizedBox(width: 12),
                    Expanded(child: ShimmerAnimationX(height: 137)),
                  ],
                ).fadeAnimation200,

                /// Spacer
                SizedBox(height: 24),

                /// Nav cards section
                Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Expanded(
                        child: ShimmerAnimationX(
                          height: 84,
                          margin: EdgeInsetsDirectional.only(
                            end: i == 3 ? 0 : 12,
                          ),
                        ),
                      ),
                  ],
                ).fadeAnimation200,
              ],
            ),
          ),

          /// Spacer
          SizedBox(height: 24),

          /// Content
          Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Current level courses section label
                ShimmerAnimationShapeX.label(width: 150).fadeAnimation250
                    .marginSymmetric(horizontal: StyleX.hPaddingApp),

                /// Current level courses section content
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
                  child: Row(
                    children: [
                      for (var i = 0; i < 4; i++)
                        ShimmerAnimationX(
                          height: 220,
                          width: 320,
                          margin: EdgeInsetsDirectional.only(
                            end: i == 3 ? 0 : 12,
                          ),
                        ),
                    ],
                  ),
                ).fadeAnimation250,

                /// Spacer
                SizedBox(height: 24),

                /// Meetings section label
                ShimmerAnimationShapeX.label(width: 100).fadeAnimation250
                    .marginSymmetric(horizontal: StyleX.hPaddingApp),

                /// Meetings section content
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
                  child: Row(
                    children: [
                      for (var i = 0; i < 4; i++)
                        ShimmerAnimationX(
                          height: 100,
                          width: 320,
                          margin: EdgeInsetsDirectional.only(
                            end: i == 3 ? 0 : 12,
                          ),
                        ),
                    ],
                  ),
                ).fadeAnimation250,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
