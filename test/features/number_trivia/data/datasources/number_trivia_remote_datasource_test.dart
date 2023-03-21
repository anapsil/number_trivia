import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_datasource_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late NumberTriviaRemoteDataSource remoteDatasource;

  setUp(() {
    mockClient = MockClient();
    remoteDatasource = NumberTriviaRemoteDataSourceImpl(client: mockClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number
       being the endpoint and with application/json header''',
      () async {
        setUpMockHttpClientSuccess200();

        remoteDatasource.getConcreteNumberTrivia(tNumber);

        verify(
          mockClient.get(Uri.parse('http://numbersapi.com/$tNumber'),
              headers: {'Content-Type': 'application/json'}),
        );
      },
    );

    test(
      'should return NumberTriviaModel when the response code is 200 (success)',
      () async {
        setUpMockHttpClientSuccess200();

        final result = await remoteDatasource.getConcreteNumberTrivia(tNumber);

        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is an error code',
      () async {
        setUpMockHttpClientFailure404();

        final call = remoteDatasource.getConcreteNumberTrivia;

        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number
       being the endpoint and with application/json header''',
      () async {
        setUpMockHttpClientSuccess200();

        remoteDatasource.getRandomNumberTrivia();

        verify(
          mockClient.get(Uri.parse('http://numbersapi.com/random'),
              headers: {'Content-Type': 'application/json'}),
        );
      },
    );

    test(
      'should return NumberTriviaModel when the response code is 200 (success)',
      () async {
        setUpMockHttpClientSuccess200();

        final result = await remoteDatasource.getRandomNumberTrivia();

        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is an error code',
      () async {
        setUpMockHttpClientFailure404();

        final call = remoteDatasource.getRandomNumberTrivia;

        expect(() => call(), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });
}
