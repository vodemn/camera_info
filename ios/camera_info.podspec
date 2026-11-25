#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint camera_info.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'camera_info'
  s.version          = '0.4.0'
  s.summary          = 'Exposes per-camera optical metadata on iOS and Android.'
  s.description      = <<-DESC
    A Flutter plugin that surfaces per-camera optical metadata not available in
    the standard camera plugin: focal length, aperture, field of view, zoom range,
    and exposure offset step size.
  DESC
  s.homepage         = 'https://github.com/Vodemn/camera_info'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Vodemn' => 'vodemn@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.source_files = 'camera_info/Sources/camera_info/**/*.swift'
  s.resource_bundles = { 'camera_info_privacy' => ['camera_info/Sources/camera_info/PrivacyInfo.xcprivacy'] }
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
