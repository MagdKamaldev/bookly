import 'package:bookly/Features/home/domain/entities/book_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/use_cases/fetch_newest_books.dart';
part 'newest_books_state.dart';

class NewestBooksCubit extends Cubit<NewestBooksState> {
  NewestBooksCubit(this.fetchNewestBooksUseCase) : super(NewestBooksInitial());

  final FetchNewestBooksUseCase fetchNewestBooksUseCase;
  
  Future<void> fetchNewestBooks() async {
    emit(NewestBooksLoading());

    var result = await fetchNewestBooksUseCase.call();

    result.fold((failure) {
      emit(NewestBooksFailure(failure.message));
    }, (books) {
      emit(NewestBooksSuccess(books));
    });
  }
}
