import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AnalyticsSkeletonLoader extends StatelessWidget {
  const AnalyticsSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKeyMetricsSkeleton(),
          const SizedBox(height: 16),
          _buildCallActivitySkeleton(),
          const SizedBox(height: 16),
          _buildChartSkeleton(),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildShimmerBox(height: 70)),
              const SizedBox(width: 10),
              Expanded(child: _buildShimmerBox(height: 70)),
              const SizedBox(width: 10),
              Expanded(child: _buildShimmerBox(height: 70)),
            ],
          ),
          const SizedBox(height: 12),
          _buildShimmerBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildCallActivitySkeleton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildShimmerBox(height: 16, width: 120),
          ),
          ...List.generate(
            7,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _buildShimmerBox(height: 16, width: 16, isCircle: true),
                  const SizedBox(width: 10),
                  _buildShimmerBox(height: 14, width: 100),
                  const Spacer(),
                  _buildShimmerBox(height: 14, width: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildShimmerBox(height: 12, width: 12),
              const SizedBox(width: 6),
              _buildShimmerBox(height: 10, width: 100),
              const SizedBox(width: 16),
              _buildShimmerBox(height: 12, width: 12),
              const SizedBox(width: 6),
              _buildShimmerBox(height: 10, width: 100),
            ],
          ),
          const SizedBox(height: 12),
          _buildShimmerBox(height: 140),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double height,
    double? width,
    bool isCircle = false,
  }) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isCircle
              ? BorderRadius.circular(height / 2)
              : BorderRadius.circular(4),
        ),
      ),
    );
  }
}
