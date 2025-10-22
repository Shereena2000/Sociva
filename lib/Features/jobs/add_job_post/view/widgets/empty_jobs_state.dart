import 'package:flutter/material.dart';
import '../../../../../Settings/common/widgets/custom_elevated_button.dart';
import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../../../../Settings/utils/p_colors.dart';

class EmptyJobsState extends StatelessWidget {
  final VoidCallback onAddJob;

  const EmptyJobsState({
    super.key,
    required this.onAddJob,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: PColors.darkGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work_outline,
                size: 80,
                color: PColors.primaryColor,
              ),
            ),
            SizeBoxH(24),

            // Title
            Text(
              "No Jobs Posted Yet",
              style: PTextStyles.displayMedium.copyWith(
                color: PColors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizeBoxH(12),

           

            // Add Job Button
            CustomElavatedTextButton(
              text: "Post Your First Job",
              onPressed: onAddJob,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}

