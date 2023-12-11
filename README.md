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

### 4- [We create the Home Remote Data Source abstract class](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/data/data_sources/home_remote_data_source.dart)

``` dart 
abstract class HomeRemoteDataSource {
  Future<List<BookModel>> fetchFeaturedBooks();
  Future<List<BookModel>> fetchNewestBooks();
}
```

### 5- [Then we create the Home Remote Data Source implementation class to handle API calls with fetch featured and newest books](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/data/data_sources/home_remote_data_source.dart)

``` dart
class HomeRemoteDataSourceImplementation extends HomeRemoteDataSource {
  final ApiService apiService;
  HomeRemoteDataSourceImplementation(this.apiService);

  @override
  Future<List<BookEntity>> fecthFeaturedBooks() async {
    var data = await apiService.get(
        endpoint:
            "volumes?q=computer science&Filtering=free-ebooks&key=AIzaSyAxT34xJRaWTN84cubUJqFs-CoN9HjUzPc");

    List<BookEntity> books = getBooksList(data);
    saveBooksData(books, kFeaturedBox);
    return books;
  }

  @override
  Future<List<BookEntity>> fetchNewestBooks() async {
    var data = await apiService.get(
        endpoint:
            "volumes?q=computer science&Filtering=free-ebooks&Sorting=newest&key=AIzaSyAxT34xJRaWTN84cubUJqFs-CoN9HjUzPc");

    List<BookEntity> books = getBooksList(data);
    saveBooksData(books,kNewestBox);
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

```

### 6- [We create an adapter for the book entity and then register it in main and oppen box to save remote data source in it](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/domain/entities/book_entity.dart)

``` dart
import 'package:hive/hive.dart';
part 'book_entity.g.dart';

@HiveType(typeId: 0)
class BookEntity {
@HiveField(0)
  final String bookId;
@HiveField(1)
  final String? image;
@HiveField(2)
  final String title;
@HiveField(3)
  final String? authorName;
@HiveField(4)
  final num? price;

  BookEntity(
      {required this.bookId,
      required this.image,
      required this.title,
      required this.authorName,
      required this.price,});
}
```
``` dart 
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(BookEntityAdapter());
  await Hive.openBox<BookEntity>(kFeaturedBox);
  await Hive.openBox<BookEntity>(kNewestBox);
  runApp(const Bookly());
}
```

### 7-[we created a method to save books with hive and then implemented it in home remote data source](https://github.com/MagdKamaldev/bookly/blob/main/lib/core/utils/functions/save_books.dart)

``` dart
void saveBooksData(List<BookEntity> books, String boxName) async {
  var box = await Hive.openBox<BookEntity>(boxName);
  box.clear();
  box.addAll(books);
}
```
``` dart
  Future<List<BookEntity>> fecthFeaturedBooks() async {
    var data = await apiService.get(
        endpoint:
            "volumes?q=computer science&Filtering=free-ebooks&key=AIzaSyAxT34xJRaWTN84cubUJqFs-CoN9HjUzPc");

    List<BookEntity> books = getBooksList(data);
    saveBooksData(books, kFeaturedBox);
    return books;
  }
```
### 8- [We implement home local data source](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/data/data_sources/home_local_data_source.dart)

``` dart
class HomeLocalDataSourceImplementation extends HomeLocalDataSource {
  @override
  List<BookEntity> fetchFeaturedBooks() {
    var box = Hive.box<BookEntity>(kFeaturedBox);
    return box.values.toList();
  }

  @override
  List<BookEntity> fetchNewestBooks() {
     var box = Hive.box<BookEntity>(kNewestBox);
    return box.values.toList();
  }
}
```

### 9 - [we implemented home repo](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/data/repos/home_repo_implementation.dart)

``` dart 
class HomeRepoImplementation extends HomeRepo {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  HomeRepoImplementation(
      {required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, List<BookEntity>>> fecthFeaturedBooks() async {
    try {
      final books = await remoteDataSource.fecthFeaturedBooks();
      return Right(books);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> fecthNewestBooks() async {
    try {
      final books = await remoteDataSource.fetchNewestBooks();
      return Right(books);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
```
### 10- [We create a server exception class to handle errors](https://github.com/MagdKamaldev/bookly/blob/main/lib/core/errors/failure.dart)

``` dart 
  factory ServerFailure.fromDioError(DioError e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure("connection Timeout with api server");
      case DioExceptionType.sendTimeout:
        return ServerFailure("send Timeout with api server");
      case DioExceptionType.receiveTimeout:
        return ServerFailure("receive Timeout with api server");
      case DioExceptionType.badCertificate:
        return ServerFailure("bad Certificate with api server");
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            e.response!.statusCode!, e.response!.data);
      case DioExceptionType.cancel:
        return ServerFailure("Request cancelled with api server");
      case DioExceptionType.connectionError:
        return ServerFailure("No Connection with api server");
      case DioExceptionType.unknown:
        return ServerFailure("Unknown Error with api server");
    }
  }
  ```
### 11-[We update the failure class to handle all cases this way ](https://github.com/MagdKamaldev/bookly/blob/main/lib/core/errors/failure.dart)

``` dart
abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
  factory ServerFailure.fromDioError(DioError e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure("connection Timeout with api server");
      case DioExceptionType.sendTimeout:
        return ServerFailure("send Timeout with api server");
      case DioExceptionType.receiveTimeout:
        return ServerFailure("receive Timeout with api server");
      case DioExceptionType.badCertificate:
        return ServerFailure("bad Certificate with api server");
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            e.response!.statusCode!, e.response!.data);
      case DioExceptionType.cancel:
        return ServerFailure("Request cancelled with api server");
      case DioExceptionType.connectionError:
        return ServerFailure("No Connection with api server");
      case DioExceptionType.unknown:
        return ServerFailure("Unknown Error with api server");
    }
  }

  factory ServerFailure.fromResponse(int statusCode, dynamic response) {
    if (statusCode == 404) {
      return ServerFailure("request not found, Please try again later !");
    } else if (statusCode == 500) {
      return ServerFailure(
          "A problem occured within remote server, Please try again later !");
    } else if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return ServerFailure(response["error"]["message"]);
    } else {
      return ServerFailure(
          "An error occured, Please try again later !");
    }
  }
}
```
## C- Presentation Layer
 
### 1- [we created the fetch featured books states](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/presentation/manager/feartured_books_cubit/featured_books_state.dart)

``` dart
part of 'featured_books_cubit.dart';

@immutable
abstract class FeaturedBooksState {}

class FeaturedBooksInitial extends FeaturedBooksState {}

class FeaturedBooksLoading extends FeaturedBooksState {}

class FeaturedBooksSuccess extends FeaturedBooksState {
  final List<BookEntity> books;

  FeaturedBooksSuccess(this.books);
}

class FeaturedBooksFailure extends FeaturedBooksState {
  final String errorMessage;

  FeaturedBooksFailure(this.errorMessage);
}
```

### 2- [we created the fetch featured books cubit and added fetch faetured books function](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/presentation/manager/feartured_books_cubit/featured_books_cubit.dart) 

``` dart
 final FetchFeaturedBooksUseCase fetchFeaturedBooksUseCase;
  Future<void> fetchFeaturedBooks() async {
    emit(FeaturedBooksLoading());

    var result = await fetchFeaturedBooksUseCase.call();

    result.fold((failure) {
      emit(FeaturedBooksFailure(failure.message));
    }, (books) {
      emit(FeaturedBooksSuccess(books));
    });
  }
```

### 3- [And we do the same with fetch Newest books](https://github.com/MagdKamaldev/bookly/tree/main/lib/Features/home/presentation/manager/newest_books_cubit)

``` dart

 part of 'newest_books_cubit.dart';

@immutable
abstract class NewestBooksState {}

class NewestBooksInitial extends NewestBooksState {}

class NewestBooksLoading extends NewestBooksState {}

class NewestBooksSuccess extends NewestBooksState {
  final List<BookEntity> books;
  NewestBooksSuccess(this.books);
}

class NewestBooksFailure extends NewestBooksState {
  final String message;
  NewestBooksFailure(this.message);
}
 
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

```

### 4- [We created a MultiBloc provider and added the providers to it in the main file](https://github.com/MagdKamaldev/bookly/blob/main/lib/main.dart)

``` dart
 return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            return FeaturedBooksCubit(
                FetchFeaturedBooksUseCase(getit.get<HomeRepoImplementaion>()));
          },
        ),
        BlocProvider(
          create: (context) {
            return NewestBooksCubit(
                FetchNewestBooksUseCase(getit.get<HomeRepoImplementaion>()));
          },
        )
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: kPrimaryColor,
          textTheme:
              GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
        ),
      ),
    );
   
  ```

### 5- [We used get_it package to create service locators for api service and home repo implementation]()



  






