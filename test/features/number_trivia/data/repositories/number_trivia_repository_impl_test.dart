import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateMocks(
    [NumberTriviaRemoteDataSource, NumberTriviaLocalDataSource, NetworkInfo])
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDataSource mockNumberTriviaRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockNumberTriviaLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNumberTriviaRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockNumberTriviaLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
        remoteDataSource: mockNumberTriviaRemoteDataSource,
        localDataSource: mockNumberTriviaLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    const tNumberTriviaModel =
        NumberTriviaModel(text: "test trivia", number: tNumber);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should check is the device is online',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);
        repository.getConcreteNumberTrivia(tNumber);
        verify(mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        'should return remote data when call to remote data source is successful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);
          final result = await repository.getConcreteNumberTrivia(tNumber);
          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally  when call to remote data source is successful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);

          await repository.getConcreteNumberTrivia(tNumber);

          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          verify(mockNumberTriviaLocalDataSource
              .cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when call to remote data source is unsuccessful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(any))
              .thenThrow(ServerException());

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockNumberTriviaLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return cache failure when there is no cached data present',
        () async {
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(text: "test trivia", number: 123);
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should check is the device is online',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        repository.getRandomNumberTrivia();
        verify(mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        'should return remote data when call to remote data source is successful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          final result = await repository.getRandomNumberTrivia();
          verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally  when call to remote data source is successful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          await repository.getRandomNumberTrivia();

          verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
          verify(mockNumberTriviaLocalDataSource
              .cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when call to remote data source is unsuccessful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());

          final result = await repository.getRandomNumberTrivia();

          verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockNumberTriviaLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          final result = await repository.getRandomNumberTrivia();

          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return cache failure when there is no cached data present',
        () async {
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());

          final result = await repository.getRandomNumberTrivia();

          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
