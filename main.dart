import 'dart:io';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';

Future<void> downloadAndEncryptVideo(
    String url, String savePath, String encryptedPath) async {
  var dio = Dio();

  try {
    print("Starting download...");

    // Download the file
    var response = await dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print(
              "Download progress: ${(received / total * 100).toStringAsFixed(0)}%");
        }
      },
    );

    // Encrypt the file's byte array
    print("Starting encryption...");
    final encryptedBytes = encryptFile(response.data!);
    File(encryptedPath).writeAsBytesSync(encryptedBytes);

    print("Encryption completed! Encrypted file saved to $encryptedPath");
  } catch (e) {
    print("Error occurred: $e");
  }
}

List<int> encryptFile(List<int> fileBytes) {
  // Define a key and IV (initialization vector) for AES
  final key = Key.fromLength(32); // 256-bit key
  final iv = IV.fromLength(16); // 128-bit IV

  // Initialize the AES encrypter
  final encrypter = Encrypter(AES(key));

  // Encrypt the file bytes
  final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);

  return encrypted.bytes;
}

void main() async {
  // URL of the video to download
  String videoUrl =
      'https://www.sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4';

  // Local paths
  String savePath = 'downloaded_video.mp4'; // Raw file
  String encryptedPath = 'encrypted_video.enc'; // Encrypted file

  // Start the download and encryption process
  await downloadAndEncryptVideo(videoUrl, savePath, encryptedPath);
}
