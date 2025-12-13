import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PollutantChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const PollutantChip({
    super.key,
    required this.label,
    required this.value,
    this.unit = 'μg/m³',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: unit == '%' ? '%' : '', 
                  // Simplified display logic, can be enhanced
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
