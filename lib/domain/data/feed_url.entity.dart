import 'package:hive_ce/hive.dart';

final class FeedURLEntity extends HiveObject {
  final String url;
  final int order;
  final DateTime added;

  FeedURLEntity({required this.url, required this.order, required this.added});
}
