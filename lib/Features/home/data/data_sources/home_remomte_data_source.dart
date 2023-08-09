import 'package:bookly/Features/home/data/models/book_model/book_model.dart';
import 'package:bookly/Features/home/domain/entities/book_entity.dart';
import '../../../../core/utils/api_services.dart';

abstract class HomeRemoteDataSource {
  Future<List<BookEntity>> fecthFeaturedBooks();
  Future<List<BookEntity>> fecthNewestBooks();
}

class HomeRemoteDataSourceImplementation extends HomeRemoteDataSource {
  final ApiService apiService;
  HomeRemoteDataSourceImplementation(this.apiService);

  @override
  Future<List<BookEntity>> fecthFeaturedBooks() async {
    var data = await apiService.get(endpoint: "volumes?q=computer science&Filtering=free-ebooks&key=AIzaSyAxT34xJRaWTN84cubUJqFs-CoN9HjUzPc");
  
    List<BookEntity> books = getBooksList(data);
    return books;
  }

  
  @override
  Future<List<BookEntity>> fecthNewestBooks() async{
     var data = await apiService.get(endpoint: "volumes?q=computer science&Filtering=free-ebooks&Sorting=newest&key=AIzaSyAxT34xJRaWTN84cubUJqFs-CoN9HjUzPc");
  
    List<BookEntity> books = getBooksList(data);
    return books;
  
  }

  List<BookEntity> getBooksList(Map<String, dynamic> data) {
      List<BookEntity> books = [];
    for (var bookMap in data["items"]) {
      books.add(BookModel.fromJson(bookMap));
    }
    return books;
  }

}
