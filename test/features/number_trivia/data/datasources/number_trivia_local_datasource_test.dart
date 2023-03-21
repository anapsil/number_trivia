import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_datasource_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences mockSharedPreferences;
  late NumberTriviaLocalDataSource localDataSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    localDataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test(
      'should return NumberTrivia from sharedPreferences when there is one in the cache',
      () async {
        when(mockSharedPreferences.getString(any))
            .thenReturn(fixture('trivia_cached.json'));

        final result = await localDataSource.getLastNumberTrivia();

        verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a CacheException when there is not a cached value',
      () async {
        when(mockSharedPreferences.getString(any)).thenReturn(null);

        final call = localDataSource.getLastNumberTrivia;

        expect(() => call(), throwsA(TypeMatcher<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(text: "Test text", number: 123);
    final expectedJsonString = json.encode(tNumberTriviaModel.toJson());

    test(
      'should call SharedPreferences to cache the data',
      () async {
        when(mockSharedPreferences.setString(any, any))
            .thenAnswer((_) async => true);

        localDataSource.cacheNumberTrivia(tNumberTriviaModel);

        verify(mockSharedPreferences.setString(
            CACHED_NUMBER_TRIVIA, expectedJsonString));
      },
    );
  });
}
