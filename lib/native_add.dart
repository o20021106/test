import 'dart:ffi';
import 'dart:io';

// Typedefs for FFI
typedef AddC = Int32 Function(Int32 a, Int32 b);
typedef AddDart = int Function(int a, int b);

class NativeAdd {
  late DynamicLibrary _lib;
  late AddDart add;

  NativeAdd() {
    // Load the shared library
    _lib = Platform.isMacOS
        ? DynamicLibrary.open('macos/NativeLibs/libadd.dylib')
        : throw UnsupportedError('This platform is not supported.');

    // Look up the 'add' function
    add = _lib.lookupFunction<AddC, AddDart>('add');
  }
}
