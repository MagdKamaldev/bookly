# clean_arch_bookly_app

## A) Domain Layer


### [1-the first step is the entity which is the core business object](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/domain/entities/book_entity.dart)

``` dart
BookEntity(
      {required this.bookId,
     required this.image,
    required this.title,
   required this.authorName,
  required this.price,});
``` 

### [2-then we create a repo for each feature which just determines what is going to happen not how ](https://github.com/MagdKamaldev/bookly/blob/main/lib/Features/home/domain/repos/home_repo.dart)

``` dart
abstract class HomeRepo {
  Future <List<BookEntity>> fecthFeaturedBooks();
  Future <List<BookEntity>> fecthNewestBooks();
}
``` 

### [3-we created a failure class to handle errors](https://github.com/MagdKamaldev/bookly/blob/main/lib/core/errors/failure.dart)

``` dart
class Failure{}
```

### [4-then we import dartz package to use Either class to handle success or failure cases and update the repo to be like](https://github.com/MagdKamaldev/bookly/blob/main/pubspec.yaml)

``` dart
abstract class HomeRepo {
  Future<Either<Failure, List<BookEntity>>> fecthFeaturedBooks();
  Future<Either<Failure, List<BookEntity>>> fecthNewestBooks();
}
```


### 5-





