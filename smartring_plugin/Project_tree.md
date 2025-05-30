# Project Function Introduction
# smartring_plugin 
The project features the use of FFI technology to achieve mutual calling between Dart and C. The project provides a sleep algorithm library, an OEM library, and an algorithm library for resting heart rate, respiratory rate, blood oxygen saturation, heart rate immersion, etc

# smartring_plugin directory tree
├─src
|  └lib    
|    |└─Contains libringoem.so (OEM certification library), libringalgorithm.so (resting heart rate, respiratory rate, blood oxygen saturation, 
|    |    heart rate immersion,etc.) algorithm library, and libsleepstaging.so (sleep library)
|    |   
|    |         
|    └smartring_plugin.h  
|          └Provided header file definition for C library
├─lib
|  ├─sdk    
|  |  └This SDK provides the parsing of Bluetooth data, as well as the encapsulation of sending Bluetooth data and receiving Bluetooth APIs.
|  |   This SDK only needs to be called according to the documentation
|  |
|  ├─smartring_plugin_bindings_generated.dart
|  |             └Definition of ffi in Dart and C calls   
|  |
|  └smartring_plugin.dart
|                └Specific Implementation of Dart and C Calling Methods
|
├─ios
   └Classes
       └Contains liboem.a (OEM certification library), libringalgorithm.a (resting heart rate, respiratory rate, blood oxygen saturation, 
          heart rate immersion,etc.) algorithm library, and libsleepV4***.a (sleep library)。These libraries are designed for iOS development and use
          Note that. a static library needs to be added in the Target ->Build Phases ->Link Binary With Libraries section of xcode.
          Then Target->build Setting->Other Link Flags add -all_ Load
