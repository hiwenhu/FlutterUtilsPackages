abstract class CloudApi {
  Future<void> saveFile(Stream stream);
  Future<void> deleteFile(String fileName);
  Future<List?> listFile();
}
