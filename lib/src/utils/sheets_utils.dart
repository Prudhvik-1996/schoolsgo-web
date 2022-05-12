import 'package:googleapis/drive/v3.dart' as drive;
import 'package:gsheets/gsheets.dart';
import 'package:http/http.dart';

class SheetsUtils {
  late String sheetId;

  SheetsUtils({required this.sheetName});

  final String sheetName;

  final _authenticateClient = _GoogleAuthClient({
    "Authorization":
        "Bearer ya29.A0ARrdaM9lTHTHRxn4qs1XHPPf_FPMaJrZEbpyj8qDBDtmcbUMZuErw1AsaIF9pAbOYspQL5EGTqAkitcyCWA2t-eYWwVTYK0l4SpQEaKMU7s-8OOgzybcu59qyPatDQcc_XtjfJCS4U6k4f0Y10If79sgJsH4sw",
    "X-Goog-AuthUser": "0",
  });

  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "schoolsgo-283018",
  "private_key_id": "e7ccb4c3ea33777540783ab3bc9fc97a9c5c3d6d",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDIR4p6pfvVfAeX\nyg+p0FKjwnHSWiZV6biOmCtlq/0dLnvez4XdvEx6NCdcWC8RjR736Mws3Ytklow0\n6YfjpQa3IhcusDwQzarexuIhEncHsV2KLQDrwbjlV+xdf5fZfpsM25EpIz+T4Lov\nTin2ZV9e2xHS1/xc/RFAqi0WROMaxEfSOfrmrv2NiO1VCcnOl0n1fSf31Py3Cbcu\nzc+YzaFtULwg5jd7YdGba22ck9pFzBF/zuxh9vBIFlyPv4SBnPjzb6XBVY5pZGJl\nBo4644mHCsxqS64a05CAqT/QVOVdPF5THpDtPhKaLwJLCVuuNuLxkGWUePSnARn4\nj9edw/mvAgMBAAECggEABhYu9UMnyPzFQvhoCx+it8JbxjFpTEpXX+56TkU3xlQY\nmfgRl+6Z5YQzsV1DKkWqD6nv0T8+Lvqvo8/Nw2GgmwIW8bewMdrCt3iipsxSXMBv\nA3zZpdCUGTg7Oh40vpkClPkQZ+vRmDb5luge1SHkHkYnH684KkOF+cKgddL2r0fJ\n8LelDjvY9PAxk+ehsLVesP6eKKHLr4nIwvwAcEnFwYsutyYfHeYgkzY8Km17Fppa\nsKTOAqdcp0bvZi2H4TzW1pUlJj41IjHjXVriw6WARj88x1Fn45eNBizKvGYwLV6j\nXTALDHHBthd19noIjrheF5D9VGA0ex2MgAvhRhS7zQKBgQDjTZyRUQtfE2i3TDoJ\nFspPq7+c77qKoxGSrP56uxdnzjdSa/92MO4xvuiNufFeYCzCLGCMtaPP3BI1iWHc\nDUgSyTTjghwjSm4FSfL2kR/Kv+Or1mSzrDBUdAGXnJK68Vtm9YD2iHCR1IK5LVjb\nTA2WCO4kisGBXYxU52KSPyBEYwKBgQDhkIdkKLEykPiMvO3o7u7k+e6qWq07LGFF\nk6CxAfWSRmm4ICzVyCrbdrlaJfWguZJgTK0/t4QqOsjDJewdMPPlzb7qveWLt2Jb\nzbCDwDWXhbqB3oxqRtYN1acPwMK6Jf7R5krytguzGtMhh23NpDNg7OS37QkFtTvH\nkYC7lqK5RQKBgQCfgSX+X1XQeQlBny8Wk7SSZd5HXX6UrMu3FshZDZLmGDKAFyMk\nKD/uDp6YXcQ/ytN9yrBR7WCviyoIAYj3ZyaNcD457GKcbS15bqQdXEdn+nHkcsUl\nxA4CJYm8f3YD0zylql++II6F9w9orKau9NaP02JxqCEUC7ZfGiP0pnGZKwKBgC4q\nK1uXbHTB8Oy0+igzRpd8g5lAB7ZVpe7cgQXZNc5jNN3nT+XNGuBh0xudK0Fi2Y92\nAftJbvZJo681ArcSvsgorMtUZDeNJ8dMOLUuUImbaAmOZ8SUjNi2AoQZ2oDIp/eD\nn5E/KvPUKKPzGMj+szlCIql2DOOrLPnyUJuT/+fVAoGAJ8emaqpKoeuEY2+kemSN\n8tsPvhWbZuIbFOjZ9rLn4/99GP9ulsBru1E0ut1ijma897r1PGcqtOew9xqASugy\n46QDdSbTC8jRhPQJDe0Jpbn/JCScWfjJBJDeWkIGO4Phbxj6r5v1HtJ3mBlufBHQ\nDSUA9xXceHvv6d8SN4siF+Q=\n-----END PRIVATE KEY-----\n",
  "client_email": "epsilon-diary-sheets@schoolsgo-283018.iam.gserviceaccount.com",
  "client_id": "116884205406396008309",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/epsilon-diary-sheets%40schoolsgo-283018.iam.gserviceaccount.com"
}
''';

  static final _gsheets = GSheets(_credentials);

  Future<void> init() async {
    sheetId = await _createSpreadSheet();
  }

  Future _createSpreadSheet() async {
    try {
      final driveApi = drive.DriveApi(_authenticateClient);
      var driveFile = drive.File();
      driveFile.name = sheetName;
      driveFile.mimeType = 'application/vnd.google-apps.spreadsheet';
      driveFile.parents = ["1I9iupad7LRucZDi9xnKZnOfPqpcsY6di"];
      final result = await driveApi.files.create(driveFile);
      return result.id;
    } catch (e) {
      print(e);
    }
  }

  Future<void> writeIntoSheet(String sheetName, {List<List<String>> rows = const []}) async {
    final Spreadsheet spreadsheet = await _gsheets.spreadsheet(sheetId);
    Worksheet sheet = await getWorkSheet(spreadsheet);
    for (int i = 0; i < rows.length; i++) {
      sheet.values.insertRow(i + 1, rows[i]);
    }
  }

  Future<Worksheet> getWorkSheet(Spreadsheet spreadsheet, {String sheetName = "Sheet1"}) async {
    try {
      return await spreadsheet.addWorksheet(sheetName);
    } catch (e) {
      return spreadsheet.worksheetByTitle(sheetName)!;
    }
  }
}

class _GoogleAuthClient extends BaseClient {
  final Map<String, String> _headers;
  final Client _client = Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
