/// An immutable text chunk with source metadata.
class Chunk {
  const Chunk({
    required this.chunkId,
    required this.documentId,
    required this.text,
    required this.startOffset,
    required this.endOffset,
    this.section,
    this.category,
  });

  final String chunkId;
  final String documentId;
  final String text;
  final int startOffset;
  final int endOffset;
  final String? section;
  final String? category;

  int get tokenEstimate => (text.length / 4).ceil();

  Chunk copyWith({
    String? chunkId,
    String? documentId,
    String? text,
    int? startOffset,
    int? endOffset,
    String? section,
    String? category,
  }) {
    return Chunk(
      chunkId: chunkId ?? this.chunkId,
      documentId: documentId ?? this.documentId,
      text: text ?? this.text,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      section: section ?? this.section,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chunk &&
        other.chunkId == chunkId &&
        other.documentId == documentId;
  }

  @override
  int get hashCode => Object.hash(chunkId, documentId);
}
