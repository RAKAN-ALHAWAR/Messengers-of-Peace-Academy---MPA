import 'package:flutter/material.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/animation.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

class ProfileDetailsLoading extends StatelessWidget {
  const ProfileDetailsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          /// Header Under Appbar
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: StyleX.hPaddingApp,
              right: StyleX.hPaddingApp,
              top: 2,
              bottom: 18,
            ),
            decoration: BoxDecoration(gradient: ColorX.primaryGradient),
            child: Column(
              children: [
                /// User image and name
                Row(
                  children: [
                    /// User image
                    ShimmerAnimationX.round(size: 60),

                    /// Spacer
                    SizedBox(width: 12),

                    /// User name and email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// User name
                        ShimmerAnimationShapeX.label(width: 100, height: 16),
                        SizedBox(height: 4),

                        /// User email
                        ShimmerAnimationShapeX.label(width: 150, height: 12),
                      ],
                    ),

                    /// Spacer
                    Spacer(),

                    /// Edit button
                    ShimmerAnimationX.round(size: 30),
                  ],
                ).fadeAnimation100,

                /// Spacer
                SizedBox(height: 16),

                /// Points Card
                ShimmerAnimationX(
                  height: 160,
                  width: double.infinity,
                ).fadeAnimation100,
              ],
            ),
          ),

          /// Content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: StyleX.hPaddingApp,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// My Progress label
                ShimmerAnimationShapeX.label().fadeAnimation150,

                /// Statistics
                Column(
                  children: [
                    /// Part 1
                    Row(
                      children: [
                        Expanded(child: ShimmerAnimationX(height: 137)),
                        SizedBox(width: 12),
                        Expanded(child: ShimmerAnimationX(height: 137)),
                      ],
                    ).fadeAnimation150,

                    /// Spacer
                    SizedBox(height: 12),

                    /// Part 2
                    Row(
                      children: [
                        Expanded(child: ShimmerAnimationX(height: 137)),
                        SizedBox(width: 12),
                        Expanded(child: ShimmerAnimationX(height: 137)),
                      ],
                    ).fadeAnimation150,
                  ],
                ),

                /// Spacer
                SizedBox(height: 24),

                /// My Account label
                ShimmerAnimationShapeX.label().fadeAnimation150,

                /// My Account options
                for (var i = 0; i < 6; i++)
                  ShimmerAnimationX(
                    height: 56,
                    margin: EdgeInsets.only(bottom: 12),
                  ).fadeAnimation200,

                /// Spacer
                SizedBox(height: 12),

                /// Application label
                ShimmerAnimationShapeX.label().fadeAnimation200,

                /// Application options
                for (var i = 0; i < 3; i++)
                  ShimmerAnimationX(
                    height: 56,
                    margin: EdgeInsets.only(bottom: 12),
                  ).fadeAnimation250,

                /// Spacer
                SizedBox(height: 12),

                /// Logout button
                ShimmerAnimationShapeX.button().fadeAnimation250,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
