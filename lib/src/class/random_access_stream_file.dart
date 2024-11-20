import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class RandomAccessStreamFile implements RandomAccessFile {
  int _offset = 0;
  Uint8List _listOfBytes;
  late String _path;

  RandomAccessStreamFile() : _listOfBytes = Uint8List(0);
  RandomAccessStreamFile.from({required Uint8List bytes}) : _listOfBytes = bytes;

  @override
  int positionSync() => _offset;

  @override
  int lengthSync() => _listOfBytes.length;

  bool get isEmpty => _listOfBytes.isEmpty;

  bool get isNotEmpty => _listOfBytes.isNotEmpty;

  @override
  void setPositionSync([int position = 0]) {
    if (position < 0) {
      position = 0;
    }

    if (position > _listOfBytes.length) {
      position = _listOfBytes.length;
    }

    _offset = position;
  }

  @override
  Uint8List readSync([int length = 0]) {
    if (length == 0) length = _listOfBytes.length;

    if (length + _offset > _listOfBytes.length) {
      length = _listOfBytes.length - _offset;
    }

    final Uint8List value = _listOfBytes.sublist(_offset, _offset + length);
    _offset += length;
    return value;
  }

  void replace(int start, Uint8List value) =>
      _changeListOfBytes(value, start, ChangeList.replace);

  void insert(int start, Uint8List value) =>
      _changeListOfBytes(value, start, ChangeList.insert);

  void writeSync(Uint8List value) =>
      _changeListOfBytes(value, 0, ChangeList.add);

  void _changeListOfBytes(Uint8List value, int start, ChangeList type) {
    switch (type) {
      case ChangeList.insert:
        _listOfBytes = (BytesBuilder()
                        ..add(_listOfBytes.sublist(0, start))
                        ..add(value)
                        ..add(_listOfBytes.sublist(start)))
                      .takeBytes();

        break;
      case ChangeList.replace:
        _listOfBytes.setRange(start, start + value.length, value);

        break;
      case ChangeList.add:
        _listOfBytes = (BytesBuilder()
              ..add(_listOfBytes)
              ..add(value))
            .takeBytes();
        break;
    }
  }
  
  @override
  Future<void> close() async {
    closeSync();
  }
  
  @override
  void closeSync() {
    _listOfBytes = Uint8List(0);
    _offset = 0;
  }
  
  @override
  Future<RandomAccessFile> flush() async {
    closeSync();
    return this;
  }
  
  @override
  void flushSync() {
    closeSync();
  }

  @override
  Future<int> length() async {
      return lengthSync();
  }
  
  @override
  Future<RandomAccessFile> lock([FileLock mode = FileLock.exclusive, int start = 0, int end = -1]) async {
    return this;
  }
  
  @override
  void lockSync([FileLock mode = FileLock.exclusive, int start = 0, int end = -1]) {  
  }
  
  @override
  String get path => _path;

  set path(String path) => _path = path;
  
  @override
  Future<int> position() async {
    return positionSync();
  }
  
  @override
  Future<Uint8List> read(int count) async {
    return readSync(count);
  }
  
  @override
  Future<int> readByte() async {
    return readByteSync();
  }
  
  @override
  int readByteSync() {
    return readSync(1).first;
  }
  
  @override
  Future<int> readInto(List<int> buffer, [int start = 0, int? end]) {
    readIntoSync(buffer, start, end);  
    return position();
  }
  
  @override
  int readIntoSync(List<int> buffer, [int start = 0, int? end]) {
    int bufferEnd = end ?? _listOfBytes.length;

    buffer.addAll(_listOfBytes.getRange(start, bufferEnd));
    _offset = start + bufferEnd;
    
    return positionSync();
  }
  
  @override
  Future<RandomAccessFile> setPosition(int position) async {
    setPositionSync(position);
    return this;
  }
  
  @override
  Future<RandomAccessFile> truncate(int length) async {
    _listOfBytes = Uint8List(length);  
    return this;
  }
  
  @override
  void truncateSync(int length) {
     _listOfBytes = Uint8List(length);       
  }
  
  @override
  Future<RandomAccessFile> unlock([int start = 0, int end = -1]) async {
    return this;
  }
  
  @override
  void unlockSync([int start = 0, int end = -1]) {
    throw UnimplementedError();
  }
  
  @override
  Future<RandomAccessFile> writeByte(int value) async {
    writeSync(Uint8List.fromList([value]));
    return this;
  }
  
  @override
  int writeByteSync(int value) {
    writeSync(Uint8List.fromList([value]));
    return value;
  }
  
  @override
  Future<RandomAccessFile> writeFrom(List<int> buffer, [int start = 0, int? end]) {
   return Future.delayed(Duration.zero, () {
      writeSync(Uint8List.fromList(buffer));
      return this;
    });
  }
  
  @override
  void writeFromSync(List<int> buffer, [int start = 0, int? end]) {
   writeSync(Uint8List.fromList(buffer));
  }
  
  @override
  Future<RandomAccessFile> writeString(String string, {Encoding encoding = utf8}) async {
    final value = encoding.encode(string);

    writeSync(Uint8List.fromList(value));

    return this;
  }
  
  @override
  void writeStringSync(String string, {Encoding encoding = utf8}) {

    final value = encoding.encode(string);

    writeSync(Uint8List.fromList(value));
  }
}

enum ChangeList {
  insert,
  replace,
  add,
}
