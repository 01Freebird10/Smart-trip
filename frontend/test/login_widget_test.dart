import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    // Provide an initial state for the mock bloc
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    // Use a dummy stream to satisfy the bloc interface
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('LoginScreen displays email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Verify presence of UI elements
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsAtLeast(1));
    expect(find.byIcon(Icons.travel_explore_rounded), findsOneWidget);
  });
}
