import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

Future<String> myGoogleSheet() async {
  var authenticateClient = await signInWithGoogle();
  var sheetID = await createSpreadSheet(authenticateClient);
  writeToSheet(authenticateClient, sheetID);
  return sheetID;
}

Future signInWithGoogle() async {
  // final GoogleSignInAccount? googleUser =
  //     await GoogleSignIn(clientId: "480997552358-t9ir5mnb6t91gcemhdmdivh3a1uo3208.apps.googleusercontent.com", scopes: [
  //   'https://www.googleapis.com/auth/drive',
  // ]).signIn();
  // final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
  //
  // //final GoogleAuthCredential credential = GoogleAuthProvider.credential(
  // //  accessToken: googleAuth.accessToken,
  // //  idToken: googleAuth.idToken,
  // //);
  // //var auth = FirebaseAuth.instance;
  // //await auth.signInWithCredential(credential);
  // final authHeaders = await googleUser.authHeaders;
  // googleUser.authHeaders.then((value) {
  //   print("29: ${value.entries}");
  // });
  final authenticateClient = GoogleAuthClient({
    "Authorization":
        "Bearer ya29.A0ARrdaM9E9LERfRuG_tSzLwRqjJhDzXYKMs7Nk2p88BvdBB-0zyPpaK913Y-JY1aapu_uHVv-bHgvqOowjxAiDqZIugnzlMMuPup0mifwsw1fkgZL1Q2O6OAs7kAzY9nYAlN6cPMTDHixlQtAiWnmxKs1SVRj",
    "X-Goog-AuthUser": "0",
  });
  return authenticateClient;
}

Future createSpreadSheet(GoogleAuthClient authenticateClient) async {
  final driveApi = drive.DriveApi(authenticateClient);
  var driveFile = new drive.File();
  driveFile.name = "hello_spreadsheet";
  driveFile.mimeType = 'application/vnd.google-apps.spreadsheet';
  driveFile.parents = ["1wIQ8JU3cTcu4FjGHOhws7FOIrIMPpSyq"];
  final result = await driveApi.files.create(driveFile);
  print("37: ${result.webViewLink}");
  print("38: ${result.id}");
  print("39: ${result.driveId}");
  return result.id;
}

writeToSheet(GoogleAuthClient authenticateClient, String sheetID) {
  final sheetsApi = sheets.SheetsApi(authenticateClient);
  sheets.ValueRange vr = new sheets.ValueRange.fromJson({
    "values": [
      ["2021/04/05", "via API", "5", "3", "3", "3", "3", "3", "3", "3"]
    ]
  });
  sheetsApi.spreadsheets.values.append(vr, sheetID, 'A:J', valueInputOption: 'USER_ENTERED').then((sheets.AppendValuesResponse r) {
    print('append completed');
  });
}

class GoogleAuthClient extends http.BaseClient {
  Map<String, String> _headers;
  final http.Client _client = new http.Client();
  GoogleAuthClient(this._headers);
  Future<StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
