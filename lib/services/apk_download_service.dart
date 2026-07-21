import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ApkDownloadService {
   static Future<String> downloadApk(
     String url,
     Function(double) onProgress,
   ) async {
     try {
       if (Platform.isAndroid) {
         final status = await Permission.requestInstallPackages.request();
         if (!status.isGranted) {
           throw Exception('INSTALL_PERMISSION_DENIED');
         }
       }

       final dio = Dio();
       final directory = await getExternalStorageDirectory();
       if (directory == null) throw Exception('Storage not available');
       
       final filePath = '${directory.path}/app-update-${DateTime.now().millisecondsSinceEpoch}.apk';

       if (await File(filePath).exists()) {
         await File(filePath).delete();
       }

       await dio.download(
         url,
         filePath,
         onReceiveProgress: (received, total) {
           if (total != -1) {
             final progress = (received / total);
             onProgress(progress);
           }
         },
       );

       final file = File(filePath);
       if (!await file.exists()) {
         throw Exception('Downloaded file not found');
       }
       
       final stat = await file.stat();
       if (stat.size == 0) {
         await file.delete();
         throw Exception('Downloaded file is empty');
       }

       return filePath;
     } catch (e) {
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionTimeout || 
              e.type == DioExceptionType.receiveTimeout) {
            throw Exception('Download timeout');
          }
          throw Exception('Network error');
        }
       rethrow;
     }
   }

  static Future<void> installApk(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      throw Exception('INSTALL_FAILED: $e');
    }
  }
}
