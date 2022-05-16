import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Book extends Equatable {
  const Book(this.title, this.author);

  final String title;
  final String author;

  @override
  List<Object> get props => [title, author];
}

const defaultBooks = <Book>[
  Book('Left Hand of Darkness', 'Ursula K. Le Guin'),
  Book('Too Like the Lightning', 'Ada Palmer'),
  Book('Kindred', 'Octavia E. Butler'),
];

class BookState extends Equatable {
  const BookState({this.selectedBook, this.books = defaultBooks});

  final Book? selectedBook;
  final List<Book> books;

  @override
  List<Object?> get props => [selectedBook, books];

  BookState copyWith({
    ValueGetter<Book?>? selectedBook,
    ValueGetter<List<Book>>? books,
  }) {
    return BookState(
      selectedBook: selectedBook != null ? selectedBook() : this.selectedBook,
      books: books != null ? books() : this.books,
    );
  }
}

abstract class BookEvent extends Equatable {
  const BookEvent();

  @override
  List<Object> get props => [];
}

class BookSelected extends BookEvent {
  const BookSelected({required this.book});

  final Book book;

  @override
  List<Object> get props => [book];
}

class BookDeselected extends BookEvent {
  const BookDeselected();
}

class BookBloc extends Bloc<BookEvent, BookState> {
  BookBloc() : super(BookState()) {
    on<BookSelected>((event, emit) {
      emit(state.copyWith(selectedBook: () => event.book));
    });
    on<BookDeselected>((event, emit) {
      emit(state.copyWith(selectedBook: () => null));
    });
  }
}

void main() {
  runApp(
    BlocProvider(
      create: (_) => BookBloc(),
      child: BooksApp(),
    ),
  );
}

class BooksApp extends StatelessWidget {
  const BooksApp({Key? key}) : super(key: key);

  List<Page> onGeneratePages(BookState state, List<Page> pages) {
    final selectedBook = state.selectedBook;
    return [
      BooksListPage.page(books: state.books),
      if (selectedBook != null) BookDetailsPage.page(book: selectedBook)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books App',
      home: FlowBuilder(
        state: context.watch<BookBloc>().state,
        onGeneratePages: onGeneratePages,
      ),
    );
  }
}

class BooksListPage extends StatelessWidget {
  const BooksListPage({Key? key, required this.books}) : super(key: key);

  static Page page({required List<Book> books}) {
    return MaterialPage<void>(
      child: BooksListPage(books: books),
    );
  }

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Books')),
      body: ListView(
        children: [
          for (final book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () {
                context.read<BookBloc>().add(BookSelected(book: book));
              },
            )
        ],
      ),
    );
  }
}

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({Key? key, required this.book});

  static Page page({required Book book}) {
    return MaterialPage<void>(
      child: BookDetailsPage(book: book),
    );
  }

  final Book book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        context.read<BookBloc>().add(BookDeselected());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, style: theme.textTheme.headline6),
              Text(book.author, style: theme.textTheme.subtitle1),
            ],
          ),
        ),
      ),
    );
  }
}