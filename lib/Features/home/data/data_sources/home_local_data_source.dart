import '../../domain/entities/book_entity.dart';

abstract class HomeLocalDataSource {
  List<BookEntity> fecthFeaturedBooks();
  List<BookEntity> fecthNewestBooks();
}

class HomeLocalDataSourceImplementation extends HomeLocalDataSource{
  @override
  List<BookEntity> fecthFeaturedBooks() {
    // TODO: implement fecthFeaturedBooks
    throw UnimplementedError();
  }

  @override
  List<BookEntity> fecthNewestBooks() {
    // TODO: implement fecthNewestBooks
    throw UnimplementedError();
  }

}