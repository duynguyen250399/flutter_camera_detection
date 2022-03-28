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
5. In `./android/src/main`, create folder named `jniLibs`
6. Go to OpenCV Android SDK folder then copy all folders in `OpenCV-android-sdk/sdk/native/libs` to `./android/src/main/jniLibs/`

All done!
### iOS
1. Download OpenCV iOS pack (version `4.5.5`) at [here](https://sourceforge.net/projects/opencvlibrary/files/4.5.5/opencv-4.5.5-ios-framework.zip/download)
2. Unzip the downloaded `.zip` file
3. After unzipping, you will get a folder named `opencv2.framework`, copy this folder to `./ios/`

All done!

## Platform required
### Android
```
ext.kotlin_version = '1.6.10'
minSdkVersion 21
compileSdkVersion 31
```

### iOS
In `./ios/Podfile`, set the target platform ios version to `12`
```
platform :ios, '12.0'
```

