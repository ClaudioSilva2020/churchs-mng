import 'package:equatable/equatable.dart';

/// RF-012: mensagem do chat de um ministério.
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.sentAt,
    this.isMine = false,
  });

  final String id;
  final String author;
  final String text;
  final DateTime sentAt;
  final bool isMine;

  @override
  List<Object?> get props => [id, author, text, sentAt, isMine];
}
