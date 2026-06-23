import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/crop_model.dart';
import '../theme/app_theme.dart';

/// Crop Detail Screen
/// Shows detailed information about a crop
class CropDetailScreen extends StatelessWidget {
  final CropModel crop;

  const CropDetailScreen({
    super.key,
    required this.crop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crop.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            CachedNetworkImage(
              imageUrl: crop.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 250,
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.eco, 
                    size: 100, color: AppTheme.primaryColor),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    crop.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Climate & Soil Info (if available)
                  if (crop.climate != null || crop.soilType != null) ...[
                    _buildInfoRow(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Sowing Time
                  _buildSection(
                    icon: Icons.calendar_today_outlined,
                    title: 'Sowing Time',
                    content: crop.sowingTime,
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(height: 16),
                  
                  // Irrigation
                  _buildSection(
                    icon: Icons.water_drop_outlined,
                    title: 'Irrigation',
                    content: crop.irrigation,
                    color: AppTheme.rainColor,
                  ),
                  const SizedBox(height: 16),
                  
                  // Fertilizer
                  _buildSection(
                    icon: Icons.compost_outlined,
                    title: 'Fertilizer',
                    content: crop.fertilizer,
                    color: AppTheme.successColor,
                  ),
                  const SizedBox(height: 16),
                  
                  // Pest Control
                  _buildSection(
                    icon: Icons.pest_control_outlined,
                    title: 'Pest Control',
                    content: crop.pestControl,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  
                  // Harvest Time
                  _buildSection(
                    icon: Icons.agriculture_outlined,
                    title: 'Harvest Time',
                    content: crop.harvestTime,
                    color: AppTheme.secondaryColor,
                  ),
                  const SizedBox(height: 24),
                  
                  // Varieties (if available)
                  if (crop.varieties != null) ...[
                    _buildInfoCard(
                      icon: Icons.grass_outlined,
                      title: 'Popular Varieties',
                      content: crop.varieties!,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Market Price (if available)
                  if (crop.marketPrice != null) ...[
                    _buildInfoCard(
                      icon: Icons.currency_rupee,
                      title: 'Market Price',
                      content: crop.marketPrice!,
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Last Updated
                  if (crop.lastUpdated != null)
                    Center(
                      child: Text(
                        'Last updated: ${_formatDate(crop.lastUpdated!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        if (crop.climate != null)
          Expanded(
            child: _buildInfoChip(
              icon: Icons.wb_sunny_outlined,
              label: 'Climate',
              value: crop.climate!,
            ),
          ),
        if (crop.climate != null && crop.soilType != null)
          const SizedBox(width: 12),
        if (crop.soilType != null)
          Expanded(
            child: _buildInfoChip(
              icon: Icons.landscape_outlined,
              label: 'Soil Type',
              value: crop.soilType!,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.secondaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? AppTheme.secondaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
