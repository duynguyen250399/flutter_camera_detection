# camera_detection

A Flutter's Plugin integrating with OpenCV Library (C++) using Dart FFI (Foreign Function Interface).
This plugin also implement `google_ml_kit` package for face detection and using plugin `camera` to control the live camera while detection happening

This plugin was inspired by an article on **Medium**

Article's link here: [https://medium.com/flutter-community/integrating-c-library-in-a-flutter-app-using-dart-ffi-38a15e16bc14]()

Thanks for your awesome article **Igor Kharakhordin**!

## Getting Started
To run the plugin, you need to complete the following steps below (Both Android & iOS)
### Android
1. Download OpenCV Android SDK (version `4.5.5`) at [here](https://sourceforge.net/projects/opencvlibrary/files/4.5.5/opencv-4.5.5-android-sdk.zip/download)
2. Unzip the download `.zip` file
3. Go to `/android` directory and create foler named `opencv`
or run `cd ./android && mkdir opencv`
4. In the downloaded folder (unzipped in step 2), copy `include` folder in `OpenCV-android-sdk/sdk/native/jni` to dir `/android/opencv/` created in step 3
### iOS

