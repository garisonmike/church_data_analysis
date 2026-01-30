import 'file_storage_interface.dart';
import 'file_storage_mobile.dart' if (dart.library.html) 'file_storage_web.dart';

FileStorage getFileStorage() => FileStorageImpl();
