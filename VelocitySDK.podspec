Pod::Spec.new do |s|
  s.name                = "VelocitySDK"
  s.version             = "1.3.3"
  s.summary             = "The open source library for Velocity SDK."
  s.homepage            = "https://www.vlcty.net/"
  s.license             = 'MIT'
  s.author              = { "Concrete Interactive" => "start@concreteinteractive.com" }
  s.source              = { :git => "git@github.com:velocity-inc/velocity-sdk-ios.git", :tag => s.version, :submodules => true }
  s.platform            = :ios, '8.0'
  s.requires_arc        = true
  s.public_header_files = [
    'Framework/VelocitySDK.h',
    'VelocitySDK/VLTErrors.h',
    'VelocitySDK/VLTManager.h',
    'VelocitySDK/VLTGPS.h',
    'VelocitySDK/Core/VLTMotionDetectResult.h',
  ]
  s.source_files        = [
    'Framework/VelocitySDK.h',
    'VelocitySDK/**/*.{h,m}',
  ]
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1' }
  s.subspec 'no-arc' do |ss|
    ss.requires_arc = false
    ss.source_files = 'vendor/velocity-protobuf/lib/objc/*.{h,m}'
  end
  s.frameworks          = 'UIKit', 'CoreData'
  s.module_name         = 'VelocitySDK'
  s.dependency  'AFNetworking/NSURLSession'
  s.dependency  'Protobuf', '~> 3.4.0'
  s.dependency  'SocketRocket', '0.6.0-vlcty'
end
