import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final int id;
  final String quote;
  final String author;

  const Quote({required this.id, required this.quote, required this.author});

  @override
  List<Object?> get props => [id, quote, author];
}
