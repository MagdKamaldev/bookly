import 'package:bookly/constants.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/book_entity.dart';


abstract class HomeLocalDataSource {
  List<BookEntity> fecthFeaturedBooks();
  List<BookEntity> fecthNewestBooks();
}

class HomeLocalDataSourceImplementation extends HomeLocalDataSource {
  @override
  List<BookEntity> fecthFeaturedBooks() {
    var box = Hive.box<BookEntity>(kFeaturedBox);
    return box.values.toList();
  }

  @override
  List<BookEntity> fecthNewestBooks() {
    // TODO: implement fecthNewestBooks
    throw UnimplementedError();
  }
}
