import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';

class DietaryChip extends StatelessWidget {
  final String label;
  final bool isAllergen;
  final VoidCallback? onTap;

  const DietaryChip({
    super.key,
    required this.label,
    this.isAllergen = false,
    this.onTap,
  });

  Color _getChipColor() {
    if (isAllergen) return AppColors.chipAllergen;

    switch (label.toLowerCase()) {
      case 'vegetarian':
      case 'vegan':
        return AppColors.chipVegetarian;
      case 'halal':
      case 'kosher':
        return AppColors.chipHalal;
      case 'spicy':
        return AppColors.chipSpicy;
      case 'seafood':
      case 'fish':
        return AppColors.chipSeafood;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _getChipColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          border: Border.all(color: chipColor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAllergen)
              Icon(
                Icons.warning,
                size: AppConstants.smallIconSize,
                color: chipColor,
              ),
            if (isAllergen) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: AppConstants.captionTextSize,
                fontWeight: FontWeight.w500,
                color: chipColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
