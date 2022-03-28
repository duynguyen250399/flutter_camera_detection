#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint camera_detection.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'camera_detection'
  s.version          = '0.0.1'
  s.summary          = 'Camera Detection Plugin'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://nguyenkhanhduy.dev'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Nguyen Khanh Duy' => 'khanhduyx2@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # telling CocoaPods not to remove framework
  s.preserve_paths = 'opencv2.framework' 

  # telling linker to include opencv2 framework
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework opencv2' }

  # including OpenCV framework
  s.vendored_frameworks = 'opencv2.framework' 

  # including native framework
  s.frameworks = 'AVFoundation'

  # including C++ library
  s.library = 'c++'
end
