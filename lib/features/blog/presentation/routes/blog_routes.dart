import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/blog_list_view.dart';
import '../views/blog_detail_view.dart';

class BlogRoutes {
  static final List<GoRoute> routes = [
    // Blog list
    GoRoute(path: '/blog', builder: (context, state) => const BlogListView()),

    // Blog post with complex deeplink structure
    GoRoute(
      path: '/blog/:year/:month/:day/:slug',
      builder: (context, state) {
        final year = state.pathParameters['year']!;
        final month = state.pathParameters['month']!;
        final day = state.pathParameters['day']!;
        final slug = state.pathParameters['slug']!;
        final isPreview = state.uri.queryParameters['preview'] == 'true';

        return BlogDetailView(
          year: year,
          month: month,
          day: day,
          slug: slug,
          isPreview: isPreview,
        );
      },
    ),

    // Event booking with complex query parameters
    GoRoute(
      path: '/event/:eventId/booking',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        final step = state.uri.queryParameters['step'];
        final coupon = state.uri.queryParameters['coupon'];

        // This is a placeholder - you would create an EventBookingView
        return EventBookingPlaceholderView(
          eventId: eventId,
          step: step,
          coupon: coupon,
        );
      },
    ),
  ];
}

class EventBookingPlaceholderView extends StatelessWidget {
  final String eventId;
  final String? step;
  final String? coupon;

  const EventBookingPlaceholderView({
    super.key,
    required this.eventId,
    this.step,
    this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Booking'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Booking Demo',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Event ID: $eventId'),
            if (step != null) Text('Step: $step'),
            if (coupon != null) Text('Coupon: $coupon'),
            const SizedBox(height: 24),
            Text(
              'This demonstrates complex deeplink routing with multiple path parameters and query parameters.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Example URLs:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• /event/123/booking'),
            Text('• /event/123/booking?step=payment'),
            Text('• /event/123/booking?step=confirmation&coupon=SAVE20'),
          ],
        ),
      ),
    );
  }
}
