import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/ai_service.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final AiService aiService;

  SearchCubit(this.aiService) : super(SearchInitial());

  Future<void> search(File file, String keyword, String fileType) async {
    emit(SearchLoading());
    try {
      if (fileType == 'text') {
        final text = await file.readAsString();
        final result = await aiService.searchInText(text, keyword);
        emit(SearchResult(textLocation: result));
      } else {
        final result = await aiService.searchInMedia(file, keyword);
        if (result == null) {
          emit(SearchError('Could not process the media file.'));
          return;
        }

        final timestamp = result['timestamp'] as double?;
        final fullTranscript = result['fullTranscript'] as String?;

        if (timestamp != null) {
          emit(SearchResult(
            timestamp: timestamp,
          ));
        } else {
          emit(SearchResult(
            textLocation:
            '"$keyword" was not found in the $fileType.\n\nFull transcript:\n${fullTranscript ?? ""}',
          ));
        }
      }
    } catch (e) {
      emit(SearchError('Error: $e'));
    }
  }

  void reset() => emit(SearchInitial());
}