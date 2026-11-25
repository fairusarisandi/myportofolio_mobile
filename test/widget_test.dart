import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> pickDay(WidgetTester tester, String label, int day) async {
  await tapVisible(tester, field(label));
  expect(find.byType(DatePickerDialog), findsOneWidget);
  await tester.tap(find.text('$day').last);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Widget appWithApi(ApiClient api, Widget home, {String? initialToken}) {
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: api),
      ChangeNotifierProvider(
        create: (_) => AuthState(api, initialToken: initialToken),
      ),
    ],
    child: MaterialApp(home: home),
  );
}

Future<void> login(WidgetTester tester) async {
  expect(find.byType(LoginScreen), findsOneWidget);
  await tester.enterText(field('Username'), 'owner');
  await tester.enterText(field('Password'), 'test-password');
  await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Login'));
}

Future<void> enterProject(WidgetTester tester, {required String url}) async {
  await tester.enterText(field('Title'), '  Portfolio  ');
  await tester.enterText(field('Description'), 'A mobile app.');
  await tester.enterText(field('Tech Stack'), 'Flutter, Django');
  await tester.enterText(field('Project URL'), url);
}

void main() {
  testWidgets('Experience card pushes a form and system Back returns home', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tapVisible(tester, find.text('Tambah Pengalaman'));
    expect(find.byType(ExperienceFormPage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ExperienceFormPage), findsNothing);
  });

  testWidgets(
    'Shared drawer guards the project action and updates after logout',
    (tester) async {
      final paths = <String>[];
      final api = ApiClient(
        client: MockClient((request) async {
          paths.add(request.url.path);
          if (request.url.path == '/api/v1/auth/token/') {
            return http.Response('{"token":"test-token"}', 200);
          }
          expect(request.headers['Authorization'], 'Token test-token');
          return http.Response('', 204);
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(appWithApi(api, MyHomePage()));
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
      await tapVisible(tester, find.text('Add Experience'));
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Home'));
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ExperienceFormPage), findsNothing);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.widgetWithText(ListTile, 'Login'));
      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsNothing);

      await tapVisible(
        tester,
        find.widgetWithText(ListTile, 'Add Project'),
      );
      await login(tester);
      expect(find.byType(ProjectFormPage), findsOneWidget);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Login'), findsNothing);
      await tapVisible(tester, find.widgetWithText(ListTile, 'Logout'));
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Logout'), findsNothing);
      expect(paths, ['/api/v1/auth/token/', '/api/v1/auth/logout/']);
    },
  );

  testWidgets('Home card signs in and submits a validated project', (
    tester,
  ) async {
    http.Request? createRequest;
    var logoutRequests = 0;
    final api = ApiClient(
      client: MockClient((request) async {
        switch (request.url.path) {
          case '/api/v1/auth/token/':
            return http.Response('{"token":"test-token"}', 200);
          case '/api/v1/auth/logout/':
            logoutRequests++;
            return http.Response('', 204);
          case '/api/v1/projects/':
            createRequest = request;
            return http.Response(request.body, 201);
          default:
            throw StateError('Unexpected request ${request.url}');
        }
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(appWithApi(api, MyHomePage()));
    await tapVisible(tester, find.text('Tambah Proyek'));
    await login(tester);
    expect(find.byType(ProjectFormPage), findsOneWidget);

    await enterProject(tester, url: 'portfolio.example.com');
    await tapVisible(tester, find.text('Save'));
    expect(
      find.text('Masukkan URL HTTP atau HTTPS yang valid.'),
      findsOneWidget,
    );
    expect(createRequest, isNull);

    await tester.enterText(
      field('Project URL'),
      'https://example.com/portfolio',
    );
    await tester.enterText(
      field('Project Image URL (Optional)'),
      'https://example.com/cover.png',
    );
    await tapVisible(tester, find.text('Save'));
    expect(createRequest!.method, 'POST');
    expect(createRequest!.headers['Authorization'], 'Token test-token');
    expect(jsonDecode(createRequest!.body), {
      'title': 'Portfolio',
      'description': 'A mobile app.',
      'tech_stack': 'Flutter, Django',
      'project_url': 'https://example.com/portfolio',
      'project_image_url': 'https://example.com/cover.png',
    });
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    await tapVisible(tester, find.text('OK'));
    expect(tester.widget<TextField>(field('Title')).controller!.text, isEmpty);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Logout'));
    expect(logoutRequests, 1);
    expect(find.text('Berhasil logout.'), findsOneWidget);
  });

  testWidgets(
    'Expired token prompts login and preserves draft after API errors',
    (tester) async {
      final tokens = <String?>[];
      final api = ApiClient(
        client: MockClient((request) async {
          switch (request.url.path) {
            case '/api/v1/auth/token/':
              return http.Response('{"token":"new-token"}', 200);
            case '/api/v1/auth/logout/':
              expect(request.headers['Authorization'], 'Token expired-token');
              return http.Response('{}', 401);
            case '/api/v1/projects/':
              tokens.add(request.headers['Authorization']);
              expect(jsonDecode(request.body)['project_image_url'], isEmpty);
              return http.Response('{}', tokens.length == 1 ? 401 : 500);
            default:
              throw StateError('Unexpected request ${request.url}');
          }
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(
        appWithApi(api, const ProjectFormPage(), initialToken: 'expired-token'),
      );
      await enterProject(tester, url: 'https://example.com/portfolio');
      await tapVisible(tester, find.text('Save'));
      await login(tester);
      expect(tokens, ['Token expired-token']);
      expect(
        tester.widget<TextField>(field('Title')).controller!.text,
        '  Portfolio  ',
      );

      await tapVisible(tester, find.text('Save'));
      expect(tokens, ['Token expired-token', 'Token new-token']);
      expect(find.text('Gagal menyimpan proyek (500).'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('Required fields reject empty and whitespace-only input', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    await tester.enterText(field('Nama Pengalaman'), '   ');
    await tester.enterText(field('Deskripsi'), '   ');
    await tapVisible(tester, find.text('Simpan'));
    expect(find.text('Nama pengalaman wajib diisi.'), findsOneWidget);
    expect(find.text('Deskripsi wajib diisi.'), findsOneWidget);
    expect(find.text('Tanggal mulai wajib diisi.'), findsOneWidget);
    expect(find.text('Tanggal selesai wajib diisi.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'Dates are ordered and valid data appears in a closable summary',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
      await tester.enterText(field('Nama Pengalaman'), '  Flutter Developer  ');
      await tester.enterText(
        field('Deskripsi'),
        '  Membangun aplikasi mobile.  ',
      );
      await tapVisible(tester, find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.text('Internship').last);
      await tester.pumpAndSettle();
      await pickDay(tester, 'Tanggal Mulai', 20);
      await pickDay(tester, 'Tanggal Selesai', 10);
      await tapVisible(tester, find.text('Simpan'));
      expect(
        find.text('Tanggal selesai tidak boleh sebelum tanggal mulai.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
      await pickDay(tester, 'Tanggal Selesai', 20);
      await tapVisible(tester, find.text('Simpan'));
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Nama Pengalaman: Flutter Developer'), findsOneWidget);
      expect(
        find.text('Deskripsi: Membangun aplikasi mobile.'),
        findsOneWidget,
      );
      expect(find.text('Kategori: Internship'), findsOneWidget);
      final now = DateTime.now();
      final date = '20/${now.month.toString().padLeft(2, '0')}/${now.year}';
      expect(find.text('Tanggal Mulai: $date'), findsOneWidget);
      expect(find.text('Tanggal Selesai: $date'), findsOneWidget);
      await tapVisible(tester, find.text('Tutup'));
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.text('  Flutter Developer  '), findsOneWidget);
    },
  );

  testWidgets('Ongoing experience requires start date but not end date', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));
    await tester.enterText(field('Nama Pengalaman'), 'Flutter Developer');
    await tester.enterText(field('Deskripsi'), 'Membangun aplikasi mobile.');
    // A previously selected end date must not leak into an ongoing experience.
    await pickDay(tester, 'Tanggal Selesai', 10);
    await tapVisible(tester, find.text('Masih berlangsung (Ongoing)'));
    expect(field('Tanggal Selesai'), findsNothing);
    await tapVisible(tester, find.text('Simpan'));
    expect(find.text('Tanggal mulai wajib diisi.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await pickDay(tester, 'Tanggal Mulai', 20);
    await tapVisible(tester, find.text('Simpan'));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text('Tanggal Selesai: Masih berlangsung (Ongoing)'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('Tutup'));
    await tapVisible(tester, find.text('Masih berlangsung (Ongoing)'));
    expect(field('Tanggal Selesai'), findsOneWidget);
    await tapVisible(tester, find.text('Simpan'));
    expect(find.text('Tanggal selesai wajib diisi.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await pickDay(tester, 'Tanggal Selesai', 20);
    await tapVisible(tester, find.text('Simpan'));
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Form remains scrollable on a narrow screen with keyboard open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MyApp());
    await tapVisible(tester, find.text('Tambah Pengalaman'));
    await tester.enterText(field('Nama Pengalaman'), 'Developer');
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Simpan'));
    expect(find.text('Deskripsi wajib diisi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
