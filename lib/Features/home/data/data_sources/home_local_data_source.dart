import 'package:bookly/constants.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/book_entity.dart';
abstract class HomeLocalDataSource {
  List<BookEntity> fetchFeaturedBooks({int pageNumber = 0});
  List<BookEntity> fetchNewestBooks();
}

class HomeLocalDataSourceImplementation extends HomeLocalDataSource {
  @override
  List<BookEntity> fetchFeaturedBooks({
    int pageNumber = 0,
  }) {
    int startIndex = pageNumber * 10;
    int endIndex = (pageNumber + 1) * 10;

    var box = Hive.box<BookEntity>(kFeaturedBox);
    List<BookEntity> allBooks = box.values.toList();

    if (startIndex >= allBooks.length || endIndex > allBooks.length) {
      return [];
    }
    return allBooks.sublist(startIndex, endIndex);
  }

  @override
  List<BookEntity> fetchNewestBooks() {
    var box = Hive.box<BookEntity>(kNewestBox);
    return box.values.toList();
  }
}
