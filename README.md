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

### 5- [We used get_it package to create service locators for api service and home repo implementation](https://github.com/MagdKamaldev/bookly/blob/main/lib/core/utils/functions/setup_service_locator.dart)

``` dart
//function
final getit = GetIt.instance;
void setupServiceLocator() {
  getit.registerSingleton<ApiService>(ApiService(Dio()));
  getit.registerSingleton<HomeRepoImplementaion>(HomeRepoImplementaion(
      homeRemoteDataSource:
          HomeRemoteDataSourceImplementation(getit.get<ApiService>()),
      homeLocalDataSource: HomeLocalDataSourceImplementation()));
}

//in main function
setupServiceLocator();

//in providers
 return FeaturedBooksCubit(
                FetchFeaturedBooksUseCase(getit.get<HomeRepoImplementaion>()));
  ```

### 6- [We created a simple bloc observer to notice state changes](https://github.com/MagdKamaldev/bookly/blob/main/lib/core/utils/simple_bloc_observer.dart) 

``` dart
//class 
class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    log(change.toString());
    super.onChange(bloc, change);
  }
}

//in main function
Bloc.observer = SimpleBlocObserver();
```

### 7- [We wrapped the Featured books listView with a block builder](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/presentation/views/widgets/featured_books_lisr_view_block_builder.dart)
``` dart
class FeaturedBooksListViewBlockBuilder extends StatelessWidget {
  const FeaturedBooksListViewBlockBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeaturedBooksCubit, FeaturedBooksState>(
      builder: (context, state) {
        if (state is FeaturedBooksSuccess) {
          return FeaturedBooksListView();
        } else if (state is FeaturedBooksFailure) {
          return Text(state.errorMessage); 
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
```

### 8- [We dislpayed the image by updating the featured list view and custom book image as follows](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/presentation/views/widgets/custom_book_item.dart)
``` dart
class FeaturedBooksListView extends StatelessWidget {
  const FeaturedBooksListView({Key? key, required this.books})
      : super(key: key);
  final List<BookEntity> books;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .3,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: books.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CustomBookImage(
                imageUrl: books[index].image ?? "",
              ),
            );
          }),
    );
  }
}

class CustomBookImage extends StatelessWidget {
  final String imageUrl;
  const CustomBookImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.6 / 4,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.fill,
          )),
    );
  }
}

```

### 9- We started pagination by updating : cubit , use cases , repo implementation , remote data source , to accept the value of page number and updates will be as follows

``` dart
// remote data source
stract class HomeRemoteDataSource {
  Future<List<BookEntity>> fecthFeaturedBooks({int pageNumber = 0});
  Future<List<BookEntity>> fetchNewestBooks();
}

class HomeRemoteDataSourceImplementation extends HomeRemoteDataSource {
  final ApiService apiService;
  HomeRemoteDataSourceImplementation(this.apiService);

  @override
  Future<List<BookEntity>> fecthFeaturedBooks({
    int pageNumber = 0,
  }) async {
    var data = await apiService.get(
        endpoint:
            "volumes?q=computer science&Filtering=free-ebooks&key=AIzaSyAxT34xJRaWTN84cubUJqFs-CoN9HjUzPc&startIndex=${pageNumber * 10}}");

    List<BookEntity> books = getBooksList(data);
    saveBooksData(books, kFeaturedBox);
    return books;
  }
}

//repo implementation

class HomeRepoImplementaion extends HomeRepo {
  final HomeRemoteDataSource homeRemoteDataSource;
  final HomeLocalDataSource homeLocalDataSource;

  HomeRepoImplementaion(
      {required this.homeRemoteDataSource, required this.homeLocalDataSource});

  @override
  Future<Either<Failure, List<BookEntity>>> fecthFeaturedBooks({ int pageNumber = 0}) async {
    try {
      List<BookEntity> books = homeLocalDataSource.fetchFeaturedBooks();
      if (books.isNotEmpty) {
        return right(books);
      }
      books = await homeRemoteDataSource.fecthFeaturedBooks();
      return right(books);
    } on Exception catch (e) {
      if (e is DioError) {
        return left(ServerFailure.fromDioError(e));
      } 
        return left(ServerFailure(e.toString()));
      
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> fecthNewestBooks() async {
    try {
      List<BookEntity> books;
      books = homeLocalDataSource.fetchNewestBooks();
      if (books.isNotEmpty) {
        return right(books);
      }
      books = await homeRemoteDataSource.fetchNewestBooks();
      return right(books);
    } on Exception catch (e) {
      if (e is DioError) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }
}

abstract class HomeRepo {
  Future<Either<Failure, List<BookEntity>>> fecthFeaturedBooks({int pageNumber = 0});
  Future<Either<Failure, List<BookEntity>>> fecthNewestBooks();
}

//use case


class FetchFeaturedBooksUseCase extends UseCase<List<BookEntity>, int> {
  final HomeRepo homeRepo;
  FetchFeaturedBooksUseCase(this.homeRepo);

  @override
  Future<Either<Failure, List<BookEntity>>> call(
      [int ? parameter = 0]) async {
    return await homeRepo.fecthFeaturedBooks(pageNumber: parameter!);
  }
}


  Future<void> fetchFeaturedBooks({int pageNumber = 0,}) async {
    emit(FeaturedBooksLoading());

    var result = await fetchFeaturedBooksUseCase.call(pageNumber);

    result.fold((failure) {
      emit(FeaturedBooksFailure(failure.message));
    }, (books) {
      emit(FeaturedBooksSuccess(books));
    });
  }

```
  
### 10- [We updated featured list view to handle pagination](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/presentation/views/widgets/featured_list_view.dart)

``` dart

class FeaturedBooksListView extends StatefulWidget {
  const FeaturedBooksListView({Key? key, required this.books})
      : super(key: key);

  final List<BookEntity> books;

  @override
  State<StatefulWidget> createState() => _FeaturedBooksListViewState();
}

class _FeaturedBooksListViewState extends State<FeaturedBooksListView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    var currentPositions = _scrollController.position.pixels;
    var maxScrollLength = _scrollController.position.maxScrollExtent;
    if (currentPositions >= 0.7 * maxScrollLength) {
      BlocProvider.of<FeaturedBooksCubit>(context)
          .fetchFeaturedBooks();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .3,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.books.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CustomBookImage(
              imageUrl: widget.books[index].image ?? '',
            ),
          );
        },
      ),
    );
  }
}
  
  ```

### 11- [We Add Pagination in local data source implementation to be like](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/data/data_sources/home_local_data_source.dart)

``` dart
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
}

```

### 12- [We updated the featured list view logic to be like](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/presentation/views/widgets/featured_list_view.dart)

``` dart
class _FeaturedBooksListViewState extends State<FeaturedBooksListView> {
  late final ScrollController _scrollController;

  var nextPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    var currentPositions = _scrollController.position.pixels;
    var maxScrollLength = _scrollController.position.maxScrollExtent;
    if (currentPositions >= 0.7 * maxScrollLength) {
      BlocProvider.of<FeaturedBooksCubit>(context).fetchFeaturedBooks(pageNumber: nextPage++);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .3,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.books.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CustomBookImage(
              imageUrl: widget.books[index].image ?? '',
            ),
          );
        },
      ),
    );
  }
}
```

### 13- [We update scrollListener function to reduce the number of requests being triggered](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/presentation/views/widgets/featured_list_view.dart)

``` dart
  void _scrollListener() async{
    var currentPositions = _scrollController.position.pixels;
    var maxScrollLength = _scrollController.position.maxScrollExtent;
    if (currentPositions >= 0.7 * maxScrollLength) {
      if (!isLoading) {
        isLoading = true;
        await BlocProvider.of<FeaturedBooksCubit>(context)
            .fetchFeaturedBooks(pageNumber: nextPage++);
        isLoading = false;
      }
    }
  }
```
### 14- [We added a new state class to handle pagination Loading State and we used it in cubit like this](https://github.com/MagdKamaldev/bookly/tree/main/lib/Features/home/presentation/manager/feartured_books_cubit)

``` dart
 
class FeaturedBooksPaginationLoading extends FeaturedBooksState {}

 if (pageNumber == 0){
      emit(FeaturedBooksLoading());
    }else{
      emit(FeaturedBooksPaginationLoading());
    }
    
```

### 15- [We updated the featured list view block builder (which will be a block consumer not builder) to handle pagination loading state and new new books to listview ](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/presentation/views/widgets/featured_books_lisr_view_block_builder.dart)
``` dart
class FeaturedBooksListViewBlockBuilder extends StatefulWidget {
  const FeaturedBooksListViewBlockBuilder({
    super.key,
  });

  @override
  State<FeaturedBooksListViewBlockBuilder> createState() =>
      _FeaturedBooksListViewBlockBuilderState();
}

class _FeaturedBooksListViewBlockBuilderState
    extends State<FeaturedBooksListViewBlockBuilder> {
  List<BookEntity> books = [];
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeaturedBooksCubit, FeaturedBooksState>(
       listener: (BuildContext context, FeaturedBooksState state) {  
        if (state is FeaturedBooksSuccess) {
            books.addAll(state.books);
        }
       },
      builder: (context, state) {
        if (state is FeaturedBooksSuccess ||
            state is FeaturedBooksPaginationLoading) {
          return FeaturedBooksListView(
            books: books,
          );
        } else if (state is FeaturedBooksFailure) {
          return Text(state.errorMessage);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
```

### 16- [We Created an errorSnackBar Builder widget  And Error State for Pagination to handle errors of pagination as follows](https://github.com/MagdKamaldev/bookly/blob/main/lib/core/utils/functions/build_error_snack_bar.dart)
``` dart

class FeaturedBooksPaginationFailure extends FeaturedBooksState {
  final String errorMessage;

  FeaturedBooksPaginationFailure(this.errorMessage);
}

 result.fold((failure) {
      if (pageNumber == 0) {
        emit(FeaturedBooksFailure(failure.message));
      }
      emit(FeaturedBooksPaginationFailure(failure.message));
    }, (books) {
      emit(FeaturedBooksSuccess(books));
    });

void errorSnackbar(BuildContext context, String  errorMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        content: Text(
          errorMessage,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

 listener: (BuildContext context, FeaturedBooksState state) {
        if (state is FeaturedBooksSuccess) {
          books.addAll(state.books);
        }

        if (state is FeaturedBooksPaginationFailure) {
          errorSnackbar(context, state.errorMessage);
        }
      },

```      

### 17- [We created a custom fading animation waidget for the loading state](https://github.com/MagdKamaldev/bookly/blob/main/lib/core/widgets/custom_fading_widget.dart)

``` dart
import 'package:flutter/material.dart';

class CustomFadingWidget extends StatefulWidget {
  final Widget child;
  const CustomFadingWidget({super.key, required this.child});

  @override
  State<CustomFadingWidget> createState() => _CustomFadingWidgetState();
}

class _CustomFadingWidgetState extends State<CustomFadingWidget>
    with SingleTickerProviderStateMixin {
  late Animation _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation =
        Tween<double>(begin: 0.2, end: 0.8).animate(_animationController);
    _animationController.addListener(() {
      setState(() {
        // The state that has changed here is the animation object's value.
      });
    });
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: _animation.value, child: widget.child);
  }
}
```

### 18- [We created custom indicator as replacement for book image and fetch featured books listview replacement for loading state ](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/presentation/views/widgets/custom_book_image_loading_indicator.dart)

``` dart
class CustomBookImageLoadingIndicator extends StatelessWidget {
  const CustomBookImageLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.6 / 4,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: const SizedBox()),
    );
  }
}

class FeaturedBooksListViewLoadingIndicator extends StatelessWidget {
  const FeaturedBooksListViewLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return  CustomFadingWidget(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .3,
        child: ListView.builder(     
          itemCount: 15,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: CustomBookImageLoadingIndicator(),
            );
          },
        ),
      ),
    );
  }
}

```

### 19- [We updated the featured list view Bloc Consumer to handle loading state as follows](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/presentation/views/widgets/featured_books_lisr_view_block_builder.dart)
``` dart
  Widget build(BuildContext context) {
    return BlocConsumer<FeaturedBooksCubit, FeaturedBooksState>(
      listener: (BuildContext context, FeaturedBooksState state) {
        if (state is FeaturedBooksSuccess) {
          books.addAll(state.books);
        }

        if (state is FeaturedBooksPaginationFailure) {
          errorSnackbar(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        if (state is FeaturedBooksSuccess ||
            state is FeaturedBooksPaginationLoading ||
            state is FeaturedBooksPaginationFailure) {
          return FeaturedBooksListView(
            books: books,
          );
        } else if (state is FeaturedBooksFailure) {
          return Text(state.errorMessage);
        } else {
         return const FeaturedBooksListViewLoadingIndicator();
        }
      },
    );
  }

```


