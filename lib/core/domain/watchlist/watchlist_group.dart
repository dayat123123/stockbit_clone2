import 'package:equatable/equatable.dart';

class WatchlistGroup extends Equatable {
  final String id;
  final String title;
  final List<String> symbols;

  const WatchlistGroup({
    required this.id,
    required this.title,
    required this.symbols,
  });

  WatchlistGroup copyWith({
    String? id,
    String? title,
    List<String>? symbols,
  }) {
    return WatchlistGroup(
      id: id ?? this.id,
      title: title ?? this.title,
      symbols: symbols ?? this.symbols,
    );
  }

  @override
  List<Object?> get props => [id, title, symbols];
}
