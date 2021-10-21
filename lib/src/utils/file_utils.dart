import 'package:download/download.dart';
import 'package:http/http.dart' as http;

enum MediaFileType {
  AUDIO_FILES,
  COMPRESSED_FILES,
  DISC_FILES,
  DB_FILES,
  EMAIL_FILES,
  EXECUTABLE_FILES,
  FONT_FILES,
  IMAGE_FILES,
  INTERNET_FILES,
  PRESENTATION_FILES,
  PROGRAMMING_FILES,
  NOTES_FILES,
  SYSTEM_FILES,
  VIDEO_FILES,
  WORD_FILES,
  PDF_FILES,
  OTHER_FILES,
  AVATAR
}

MediaFileType getFileTypeForExtension(String extension) {
  print("Extension Request For: $extension");
  switch (extension) {
    // Audio file formats by file extensions
    case "aif":
    case "cda":
    case "mid":
    case "midi":
    case "mp3":
    case "mpa":
    case "ogg":
    case "wav":
    case "wma":
    case "wpl":
      return MediaFileType.AUDIO_FILES;
    // return "assets/images/mp3_blue_default.png";
    // Compressed file extensions
    case "7z":
    case "arj":
    case "deb":
    case "pkg":
    case "rar":
    case "rpm":
    case "tar.gz":
    case "z":
    case "zip":
      return MediaFileType.COMPRESSED_FILES;
    // return "assets/images/blue_doc.png";
    // Disc and media file extensions
    case "bin":
    case "dmg":
    case "iso":
    case "toast":
    case "vcd":
      return MediaFileType.DISC_FILES;
    // return "assets/images/blue_doc.png";
    // Data and database file extensions
    case "csv":
    case "dat":
    case "db":
    case "dbf":
    case "log":
    case "mdb":
    case "sav":
    case "sql":
    case "tar":
    case "xml":
      return MediaFileType.DB_FILES;
    // return "assets/images/blue_doc.png";
    // E-mail file extensions
    case "email":
    case "eml":
    case "emlx":
    case "msg":
    case "oft":
    case "ost":
    case "pst":
    case "vcf":
      return MediaFileType.EMAIL_FILES;
    // return "assets/images/blue_doc.png";
    // Executable file extensions
    case "apk":
    case "bat":
    case "bin":
    case "cgi":
    case "pl":
    case "com":
    case "exe":
    case "gadget":
    case "jar":
    case "msi":
    case "py":
    case "wsf":
      return MediaFileType.EXECUTABLE_FILES;
    // return "assets/images/blue_doc.png";
    // Font file extensions
    case "fnt":
    case "fon":
    case "otf":
    case "ttf":
      return MediaFileType.FONT_FILES;
    // return "assets/images/blue_doc.png";
    // Image file formats by file extension
    case "ai":
    case "bmp":
    case "gif":
    case "ico":
    case "jpeg":
    case "jpg":
    case "png":
    case "ps":
    case "psd":
    case "svg":
    case "tif":
    case "tiff":
      return MediaFileType.IMAGE_FILES;
    // return "assets/images/image_black_default.jpg";
    // Internet related file extensions
    case "asp":
    case "aspx":
    case "cer":
    case "cfm":
    case "cgi":
    case "pl":
    case "css":
    case "htm":
    case "html":
    case "js":
    case "jsp":
    case "part":
    case "php":
    case "py":
    case "rss":
    case "xhtml":
      return MediaFileType.INTERNET_FILES;
    // return "assets/images/blue_doc.png";
    // Presentation file formats by file extension
    case "key":
    case "odp":
    case "pps":
    case "ppt":
    case "pptx":
      return MediaFileType.PRESENTATION_FILES;
    // return "assets/images/blue_doc.png";
    // Programming files by file extensions
    case "c":
    case "cgi":
    case "pl":
    case "class":
    case "cpp":
    case "cs":
    case "h":
    case "java":
    case "php":
    case "py":
    case "sh":
    case "swift":
    case "vb":
      return MediaFileType.PROGRAMMING_FILES;
    // return "assets/images/blue_doc.png";
    // Note
    case "ods":
    case "xls":
    case "xlsm":
    case "xlsx":
      return MediaFileType.NOTES_FILES;
    // return "assets/images/blue_doc.png";
    // System related file formats and file extensions
    case "bak":
    case "cab":
    case "cfg":
    case "cpl":
    case "cur":
    case "dll":
    case "dmp":
    case "drv":
    case "icns":
    case "ico":
    case "ini":
    case "lnk":
    case "msi":
    case "sys":
    case "tmp":
      return MediaFileType.SYSTEM_FILES;
    // return "assets/images/blue_doc.png";
    // Video file formats by file extension
    case "3g2":
    case "3gp":
    case "avi":
    case "flv":
    case "h264":
    case "m4v":
    case "mkv":
    case "mov":
    case "mp4":
    case "mpg":
    case "mpeg":
    case "rm":
    case "swf":
    case "vob":
    case "wmv":
      return MediaFileType.VIDEO_FILES;
    // return "assets/images/mp4_blue_default.png";
    case "pdf":
      return MediaFileType.PDF_FILES;
    // return "assets/images/pdf_default.png";
    // Word processor and text file formats by file extension
    case "doc":
    case "docx":
    case "odt":
    case "rtf":
    case "tex":
    case "txt":
    case "wpd":
      return MediaFileType.WORD_FILES;
    // return "assets/images/blue_doc.png";
  }
  return MediaFileType.OTHER_FILES;
  // return "assets/images/blue_doc.png";
}

String getAssetImageForFileType(MediaFileType fileType) {
  switch (fileType) {
    case MediaFileType.AUDIO_FILES:
      return "assets/images/mp3_blue_default.png";
    case MediaFileType.COMPRESSED_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.DISC_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.DB_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.EMAIL_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.EXECUTABLE_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.FONT_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.IMAGE_FILES:
      return "assets/images/image_black_default.jpg";
    case MediaFileType.INTERNET_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.PRESENTATION_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.PROGRAMMING_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.NOTES_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.SYSTEM_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.VIDEO_FILES:
      return "assets/images/mp4_blue_default.png";
    case MediaFileType.PDF_FILES:
      return "assets/images/pdf_default.png";
    case MediaFileType.WORD_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.OTHER_FILES:
      return "assets/images/blue_doc.png";
    case MediaFileType.AVATAR:
      return "assets/images/avatar.png";
    default:
      return "assets/images/blue_doc.png";
  }
}

downloadFile(String url, {String? filename}) async {
  print(url);

  // TODO should find an alternative for this
  String allowCORSEndPoint = "https://api.allorigins.win/raw?url=";

  http.Response response = await http.get(
    Uri.parse(allowCORSEndPoint + url),
  );

  final stream = Stream.fromIterable(response.bodyBytes);
  download(stream, filename!);
}
