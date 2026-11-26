export 'xml_downloader_stub.dart'
    if (dart.library.html) 'xml_downloader_web.dart'
    if (dart.library.io) 'xml_downloader_io.dart';
