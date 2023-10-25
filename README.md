# clean_arch_bookly_app

- the first step is the entity which is the core business object 
# BookEntity(
#      {required this.bookId,
#     required this.image,
#    required this.title,
#   required this.authorName,
#  required this.price,});

-then we create a repo for each feature which just determines what is going to happen not how 

# abstract class HomeRepo {
  Future<Either<Failure, List<BookEntity>>> fecthFeaturedBooks();
  Future<Either<Failure, List<BookEntity>>> fecthNewestBooks();
}


