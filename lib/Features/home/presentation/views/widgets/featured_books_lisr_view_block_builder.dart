import 'package:bookly/Features/home/presentation/manager/feartured_books_cubit/featured_books_cubit.dart';
import 'package:bookly/Features/home/presentation/views/widgets/featured_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
