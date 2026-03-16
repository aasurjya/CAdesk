/// An immutable record of an embedded document chunk stored in the vector DB.
class EmbeddingRecord {
  EmbeddingRecord({
    required this.id,
    required this.documentId,
    required this.chunkId,
    required List<double> vector,
    required this.content,
    Map<String, dynamic> metadata = const {},
  }) : vector = List.unmodifiable(vector),
       metadata = Map.unmodifiable(metadata);

  final String id;
  final String documentId;
  final String chunkId;
  final List<double> vector;
  final String content;
  final Map<String, dynamic> metadata;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmbeddingRecord &&
        other.id == id &&
        other.documentId == documentId &&
        other.chunkId == chunkId;
  }

  @override
  int get hashCode => Object.hash(id, documentId, chunkId);
}
