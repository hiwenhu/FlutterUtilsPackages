import 'dart:io';
import 'package:rxdart/subjects.dart';
import 'package:cloud_api/cloud_api.dart';

class FileCloudRepository<CA extends CloudApi> {
  FileCloudRepository({required this.cloudApi}) {
    _init();
  }
  final CA cloudApi;
  final _todoStreamController = BehaviorSubject<List<File>>.seeded(const []);

  void _init() {
    cloudApi.listFile().then((files) {
      _todoStreamController.add(files);
    }).onError((error, stackTrace) {
      _todoStreamController.add(const []);
    });
  }

  Stream<List<File>> getFiles() => _todoStreamController.asBroadcastStream();

  Future saveFile(File file) async {
    final files = [..._todoStreamController.value];
    final index = files.indexWhere((t) => t.path == file.path);
    if (index >= 0) {
      files[index] = file;
    } else {
      files.add(file);
    }

    _todoStreamController.add(files);

    return cloudApi.saveFile(file);
  }

  Future deleteFile(File file) async {
    final files = [..._todoStreamController.value];
    final index = files.indexWhere((t) => t.path == file.path);
    // if (index == -1) {
    //   throw TodoNotFoundException();
    // } else {
    if (index >= 0) {
      files.removeAt(index);
      _todoStreamController.add(files);
    }
    return cloudApi.deleteFile(file.absolute.path);
  }
}
