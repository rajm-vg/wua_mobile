import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/shared/widgets/shimmer.dart';

void main() {
  group('Shimmer Widgets Tests', () {
    testWidgets('Shimmer renders child and applies ShaderMask when enabled',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Shimmer(
              child: Text('Loading Content'),
            ),
          ),
        ),
      );

      expect(find.text('Loading Content'), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('Shimmer renders child directly without ShaderMask when enabled is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Shimmer(
              enabled: false,
              child: Text('Content Ready'),
            ),
          ),
        ),
      );

      expect(find.text('Content Ready'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('ShimmerContainer renders standalone with dimensions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerContainer(
              width: 120,
              height: 24,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerContainer), findsOneWidget);
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      expect(container.constraints?.minWidth, 120.0);
      expect(container.constraints?.minHeight, 24.0);
    });

    testWidgets('ShimmerCircle renders circular shape with given size',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCircle(
              size: 48,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerCircle), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.shape, BoxShape.circle);
      expect(container.constraints?.minWidth, 48.0);
      expect(container.constraints?.minHeight, 48.0);
    });

    testWidgets('ShimmerText renders text line placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerText(
              width: 150,
              height: 16,
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerText), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.minWidth, 150.0);
      expect(container.constraints?.minHeight, 16.0);
    });

    testWidgets('ShimmerCard renders card styling and wraps child in Shimmer',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerCard(
              child: Column(
                children: [
                  ShimmerCircle(size: 40),
                  ShimmerText(width: 100),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerCard), findsOneWidget);
      expect(find.byType(ShimmerCircle), findsOneWidget);
      expect(find.byType(ShimmerText), findsOneWidget);
      // Both elements inside ShimmerCard share the single Shimmer ancestor
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('ShimmerList renders correct number of items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShimmerList(
              itemCount: 3,
              itemBuilder: (context, index) =>
                  ShimmerText(width: 80, key: ValueKey('item_$index')),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('item_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('item_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('item_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('item_3')), findsNothing);
    });

    testWidgets('ShimmerLoading displays skeleton when loading and content when loaded',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              isLoading: true,
              skeleton: Text('Skeleton View'),
              child: Text('Real Content'),
            ),
          ),
        ),
      );

      expect(find.text('Skeleton View'), findsOneWidget);
      expect(find.text('Real Content'), findsNothing);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerLoading(
              isLoading: false,
              skeleton: Text('Skeleton View'),
              child: Text('Real Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Skeleton View'), findsNothing);
      expect(find.text('Real Content'), findsOneWidget);
    });
  });
}

