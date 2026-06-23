import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scheme_model.dart';
import '../theme/app_theme.dart';

/// Scheme Detail Screen
/// Shows detailed information about a government scheme
class SchemeDetailScreen extends StatelessWidget {
  final SchemeModel scheme;

  const SchemeDetailScreen({
    super.key,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheme Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            if (scheme.imageUrl != null && scheme.imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: scheme.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 220,
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: const Icon(Icons.account_balance, 
                      size: 80, color: AppTheme.primaryColor),
                ),
              )
            else
              Container(
                height: 180,
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: const Center(
                  child: Icon(Icons.account_balance, 
                      size: 80, color: AppTheme.primaryColor),
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
                    scheme.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Overview Section
                  _buildSection(
                    icon: Icons.info_outline,
                    title: 'Overview',
                    content: scheme.overview,
                  ),
                  const SizedBox(height: 20),
                  
                  // Eligibility Section
                  _buildSection(
                    icon: Icons.check_circle_outline,
                    title: 'Eligibility',
                    content: scheme.eligibility,
                    iconColor: AppTheme.successColor,
                  ),
                  const SizedBox(height: 20),
                  
                  // Benefits Section
                  _buildSection(
                    icon: Icons.star_outline,
                    title: 'Benefits',
                    content: scheme.benefits,
                    iconColor: AppTheme.secondaryColor,
                  ),
                  const SizedBox(height: 32),
                  
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(scheme.applyLink),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text(
                        'Apply Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Last Updated
                  if (scheme.lastUpdated != null)
                    Center(
                      child: Text(
                        'Last updated: ${_formatDate(scheme.lastUpdated!)}',
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? AppTheme.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      // Handle error silently
    }
  }
}
