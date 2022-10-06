@echo off
flutter build apk --target-platform android-arm64,android-arm --split-debug-info=build/tableau_debug_build_info/ --tree-shake-icons