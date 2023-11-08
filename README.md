# clean_arch_bookly_app

## A- Domain Layer


### [1-The first step is the entity which is the core business object](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/domain/entities/book_entity.dart)

``` dart
BookEntity(
      {required this.bookId,
     required this.image,
    required this.title,
   required this.authorName,
  required this.price,});
``` 

### [2-Then we create a repo for each feature which just determines what is going to happen not how ](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/domain/repos/home_repo.dart)

``` dart
abstract class HomeRepo {
  Future <List<BookEntity>> fecthFeaturedBooks();
  Future <List<BookEntity>> fecthNewestBooks();
}
``` 

### [3-We created a failure class to handle errors](https://github.com/MagdKamaldev/bookly/blob/main/lib/core/errors/failure.dart)

``` dart
class Failure{}
```

### [4-Then we import dartz package to use Either class to handle success or failure cases and update the repo to be like](https://github.com/MagdKamaldev/bookly/blob/main/pubspec.yaml)

``` dart
abstract class HomeRepo {
  Future<Either<Failure, List<BookEntity>>> fecthFeaturedBooks();
  Future<Either<Failure, List<BookEntity>>> fecthNewestBooks();
}
```


### 5- [Then we create a usecase for each feature](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/domain/use_cases/fetch_featured_books_use_case.dart)

```dart 

class FetchFeaturedBooksUseCase {
  final HomeRepo homeRepo;

  FetchFeaturedBooksUseCase({required this.homeRepo});

  Future<Either<Failure, List<BookEntity>>> call() async {
    return await homeRepo.fecthFeaturedBooks();
  }
}
```

### 6- We use generic use case to handle use case shape

```dart
abstract class UseCase<Type, Param> {
  Future<Either<Failure, Type>> call([Param param]);
}

class NoParam{}

```

 ### The fetch featured books use case will be like :

``` dart
class FetchFeaturedBooksUseCase extends UseCase<List<BookEntity>, NoParameter> {
  final HomeRepo homeRepo;
  FetchFeaturedBooksUseCase(this.homeRepo);

  @override
  Future<Either<Failure, List<BookEntity>>> call(
      [NoParameter? parameter]) async {
    return await homeRepo.fecthFeaturedBooks();
  }
}

```
### 7- fetch newest books use case will be like :

``` dart
class FetchNewestBooksUseCase extends UseCase<List<BookEntity>, NoParameter> {
  final HomeRepo homeRepo;
  FetchNewestBooksUseCase(this.homeRepo);

  @override
  Future<Either<Failure, List<BookEntity>>> call(
      [NoParameter? parameter]) async {
    return await homeRepo.fecthNewestBooks();
  }
}

```

## B- Data Layer

### 1- [We create the model using the vs code extention Json to Dart Model](https://marketplace.visualstudio.com/items?itemName=hirantha.json-to-dart)

### 2- [Then we make the relation between book Model and book Entity](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/data/models/book_model/book_model.dart)

``` dart
class BookModel extends BookEntity {
  String? kind;
  String? id;
  String? etag;
  String? selfLink;
  VolumeInfo? volumeInfo;
  SaleInfo? saleInfo;
  AccessInfo? accessInfo;
  SearchInfo? searchInfo;

  BookModel({
    this.kind,
    this.id,
    this.etag,
    this.selfLink,
    this.volumeInfo,
    this.saleInfo,
    this.accessInfo,
    this.searchInfo,
  }) : super(
          bookId: id!,
          image: volumeInfo!.imageLinks!.thumbnail ?? '',
          title: volumeInfo.title!,
          authorName: volumeInfo.authors!.first,
          price: 0.0,
        );
}
```
### 3- [We created the api service class to handle get requests using dio](https://github.com/MagdKamaldev/bookly/blob/main/lib/core/utils/api_services.dart)
``` dart 
class ApiService {
  final Dio _dio;
  final baseUrl = "https://www.googleapis.com/books/v1/";
  ApiService(this._dio);

  Future<Map<String, dynamic>> get({required String endpoint}) async {
    var response = await _dio.get("$baseUrl$endpoint");
    return response.data;
  }
}
```

### 4- [We create the Home Remote Data Source abstract class to handle API calls](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/data/data_sources/home_remote_data_source.dart)

``` dart 
abstract class HomeRemoteDataSource {
  Future<List<BookModel>> fetchFeaturedBooks();
  Future<List<BookModel>> fetchNewestBooks();
}
```







