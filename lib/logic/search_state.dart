abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchResult extends SearchState {
  final String? textLocation;
  final double? timestamp;
  final String? transcribedText;

  SearchResult({this.textLocation, this.timestamp, this.transcribedText});
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}