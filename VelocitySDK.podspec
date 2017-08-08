Pod::Spec.new do |s|
  s.name              = "VelocitySDK"
  s.version           = "1.2"
  s.summary           = "The open source library for Velocity SDK."
  s.homepage          = "https://www.vlcty.net/"
  s.license           = 'MIT'
  s.author            = { "Concrete Interactive" => "start@concreteinteractive.com" }
  s.source            = { :git => "https://github.com/concreteinteractive/velocity-sdk-ios.git", :tag => s.version, :submodules => true }

  s.platform      = :ios, '8.0'
  s.requires_arc  = true

  s.public_header_files = [
    'Framework/VelocitySDK.h',
    'VelocitySDK/VLTErrors.h',
    'VelocitySDK/VLTManager.h',
  ]
  s.source_files        = [
    'Framework/VelocitySDK.h',
    'VelocitySDK/**/*.{h,m}',
    'vendor/velocity-protobuf/lib/objc/*.{h,m}',
  ]

  s.frameworks    = 'UIKit', 'CoreData'
  s.module_name   = 'VelocitySDK'

  s.dependency 'AFNetworking/NSURLSession'
  s.dependency 'ProtocolBuffers'
end