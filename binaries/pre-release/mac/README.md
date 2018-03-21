# PigeonBinaries Mac Download Instructions

1) Download and copy pigeon.dmg to desired folder 

2) Double click the pigeon.dmg

3) Drag Pigeon Core icon to the Applications 

4) Launch Pigeon Core

Note: On Pigeon Core launch if you get this error

```
Dyld Error Message:
  Library not loaded: @loader_path/libboost_system-mt.dylib
  Referenced from: /Applications/Pigeon-Qt.app/Contents/Frameworks/libboost_thread-mt.dylib
  Reason: image not found
```
You will need to copy libboost_system.dylib to libboost_system-mt.dylib in the /Applications/Pigeon-Qt.app/Contents/Frameworks folder  
  