import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_core/features/auth/presentation/bloc/auth_login_form/auth_login_form_bloc.dart';

void main() {
  late AuthLoginFormBloc authLoginFormBloc;

  // Dữ liệu giả dùng chung
  const tEmail = 'test@gmail.com';
  const tPassword = 'password123';

  // setUp chạy TRƯỚC mỗi case test để đảm bảo môi trường sạch
  setUp(() {
    authLoginFormBloc = AuthLoginFormBloc();
  });

  // tearDown chạy SAU mỗi case test để đóng Bloc
  tearDown(() {
    authLoginFormBloc.close();
  });

  // -------------------------------------------------------------------
  // KIỂM TRA TRẠNG THÁI KHỞI TẠO
  // -------------------------------------------------------------------
  test(
    'State khởi tạo phải là LoginFormInitialState với email/password rỗng và isValid = false',
    () {
      expect(authLoginFormBloc.state, isA<LoginFormInitialState>());
      expect(authLoginFormBloc.state.email, '');
      expect(authLoginFormBloc.state.password, '');
      expect(authLoginFormBloc.state.isValid, false);
    },
  );

  // -------------------------------------------------------------------
  // CÁC KỊCH BẢN TEST CHO EVENT THAY ĐỔI EMAIL
  // -------------------------------------------------------------------
  group('AuthLoginFormBloc - LoginFormEmailChangedEvent', () {
    blocTest<AuthLoginFormBloc, LoginFormState>(
      'Nên emit LoginFormDataState với email mới khi email thay đổi',
      build: () => authLoginFormBloc,
      act: (bloc) => bloc.add(LoginFormEmailChangedEvent(tEmail)),
      expect: () => [
        isA<LoginFormDataState>()
            .having((s) => s.email, 'email', tEmail)
            .having((s) => s.password, 'password', '')
            .having((s) => s.isValid, 'isValid', false),
      ],
    );

    blocTest<AuthLoginFormBloc, LoginFormState>(
      'Nên emit LoginFormDataState với isValid = false khi chỉ có email (password rỗng)',
      build: () => authLoginFormBloc,
      act: (bloc) => bloc.add(LoginFormEmailChangedEvent(tEmail)),
      expect: () => [
        isA<LoginFormDataState>().having((s) => s.isValid, 'isValid', false),
      ],
    );
  });

  // -------------------------------------------------------------------
  // CÁC KỊCH BẢN TEST CHO EVENT THAY ĐỔI PASSWORD
  // -------------------------------------------------------------------
  group('AuthLoginFormBloc - LoginFormPasswordChangedEvent', () {
    blocTest<AuthLoginFormBloc, LoginFormState>(
      'Nên emit LoginFormDataState với password mới khi password thay đổi',
      build: () => authLoginFormBloc,
      act: (bloc) => bloc.add(LoginFormPasswordChangedEvent(tPassword)),
      expect: () => [
        isA<LoginFormDataState>()
            .having((s) => s.password, 'password', tPassword)
            .having((s) => s.email, 'email', '')
            .having((s) => s.isValid, 'isValid', false),
      ],
    );

    blocTest<AuthLoginFormBloc, LoginFormState>(
      'Nên emit LoginFormDataState với isValid = false khi chỉ có password (email rỗng)',
      build: () => authLoginFormBloc,
      act: (bloc) => bloc.add(LoginFormPasswordChangedEvent(tPassword)),
      expect: () => [
        isA<LoginFormDataState>().having((s) => s.isValid, 'isValid', false),
      ],
    );
  });

  // -------------------------------------------------------------------
  // CÁC KỊCH BẢN TEST KIỂM TRA inputValidator (LUỒNG NHẬP ĐẦY ĐỦ)
  // -------------------------------------------------------------------
  group('AuthLoginFormBloc - Validation (email + password)', () {
    blocTest<AuthLoginFormBloc, LoginFormState>(
      'Nên emit isValid = true khi cả email và password đều không rỗng',
      build: () => authLoginFormBloc,
      // ACT: bắn 2 event theo thứ tự
      act: (bloc) {
        bloc.add(LoginFormEmailChangedEvent(tEmail));
        bloc.add(LoginFormPasswordChangedEvent(tPassword));
      },
      expect: () => [
        // Sau email: password vẫn rỗng → isValid = false
        isA<LoginFormDataState>()
            .having((s) => s.email, 'email', tEmail)
            .having((s) => s.isValid, 'isValid', false),
        // Sau password: cả hai đều có → isValid = true
        isA<LoginFormDataState>()
            .having((s) => s.email, 'email', tEmail)
            .having((s) => s.password, 'password', tPassword)
            .having((s) => s.isValid, 'isValid', true),
      ],
    );

    blocTest<AuthLoginFormBloc, LoginFormState>(
      'Nên emit isValid = false khi email bị xoá sau khi đã nhập đủ',
      build: () => authLoginFormBloc,
      act: (bloc) {
        bloc.add(LoginFormEmailChangedEvent(tEmail));
        bloc.add(LoginFormPasswordChangedEvent(tPassword));
        // Xoá email đi
        bloc.add(const LoginFormEmailChangedEvent(''));
      },
      expect: () => [
        isA<LoginFormDataState>().having((s) => s.isValid, 'isValid', false),
        isA<LoginFormDataState>().having((s) => s.isValid, 'isValid', true),
        isA<LoginFormDataState>().having((s) => s.isValid, 'isValid', false),
      ],
    );
  });
}
