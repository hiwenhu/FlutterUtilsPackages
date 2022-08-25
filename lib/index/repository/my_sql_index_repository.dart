import 'package:rxdart/subjects.dart';

class MySqlTableIndexRepository {
  final List<String> allColumns = [
    'Column1',
    'Column2',
    'Column3',
    'Column4',
    'Column5',
    'Column6',
    'Column7',
    'Column8',
    'Column9',
    'Column10',
  ];
  final List<String> selected = [];

  final _selectedStreamController =
      BehaviorSubject<List<String>>.seeded(const []);

  void dispose() {
    _selectedStreamController.close();
  }

  Stream<List<String>> get selectedColumns {
    return _selectedStreamController.asBroadcastStream();
  }

  Stream<List<String>> get unselectedColumns async* {
    await for (final selected in selectedColumns) {
      yield allColumns.where((element) => !selected.contains(element)).toList();
    }
  }

  void selectColumn(String columnName) {
    if (selected.contains(columnName)) return;
    selected.add(columnName);
    _selectedStreamController.add(selected);
  }

  void unselectColumn(String columnName) {
    selected.remove(columnName);
    _selectedStreamController.add(selected);
  }

  void moveDownColumn(String columnName) {
    int index = selected.indexOf(columnName);
    if (index < selected.length - 1) {
      var next = selected[index + 1];
      selected[index + 1] = columnName;
      selected[index] = next;
    }
    _selectedStreamController.add(selected);
  }

  void moveUpColumn(String columnName) {
    int index = selected.indexOf(columnName);
    if (index > 0) {
      var next = selected[index - 1];
      selected[index - 1] = columnName;
      selected[index] = next;
    }
    _selectedStreamController.add(selected);
  }

  void reorder(String columnName, int toPosition) {
    selected.remove(columnName);
    selected.insert(toPosition, columnName);
    _selectedStreamController.add(selected);
  }

  List<String> getUnselected(List<String> selected) {
    return allColumns.where((element) => !selected.contains(element)).toList();
  }
}
