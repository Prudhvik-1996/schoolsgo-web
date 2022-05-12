//import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

myGoogleSheet() async {
  var authenticateClient = await signInWithGoogle();
  var sheetID = await createSpreadSheet(authenticateClient);
  writeToSheet(authenticateClient, sheetID);
}

Future signInWithGoogle() async {
  final GoogleSignInAccount? googleUser =
      await GoogleSignIn(clientId: "480997552358-t9ir5mnb6t91gcemhdmdivh3a1uo3208.apps.googleusercontent.com", scopes: [
    'https://www.googleapis.com/auth/drive',
  ]).signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
  print("20: ${googleAuth.idToken}");
  print("21: ${googleAuth.accessToken}");

  //final GoogleAuthCredential credential = GoogleAuthProvider.credential(
  //  accessToken: googleAuth.accessToken,
  //  idToken: googleAuth.idToken,
  //);
  //var auth = FirebaseAuth.instance;
  //await auth.signInWithCredential(credential);
  final authHeaders = await googleUser.authHeaders;
  googleUser.authHeaders.then((value) {
    print("29: ${value.entries}");
  });
  final authenticateClient = GoogleAuthClient(authHeaders);
  return authenticateClient;
}

Future createSpreadSheet(GoogleAuthClient authenticateClient) async {
  final driveApi = drive.DriveApi(authenticateClient);
  var driveFile = new drive.File();
  driveFile.name = "hello_spreadsheet";
  driveFile.mimeType = 'application/vnd.google-apps.spreadsheet';
  final result = await driveApi.files.create(driveFile);
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
