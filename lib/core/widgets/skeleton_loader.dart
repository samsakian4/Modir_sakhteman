import 'package:flutter/material.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 16, this.borderRadius = 8});
  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(borderRadius)),
    );
  }
}

class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({super.key});
  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: SkeletonBox(height: 72, borderRadius: 12));
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 5});
  final int count;
  @override
  Widget build(BuildContext context) => ListView.builder(padding: const EdgeInsets.all(16), itemCount: count, itemBuilder: (context, index) => const ListRowSkeleton());
}
