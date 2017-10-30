#
# Be sure to run `pod lib lint ArenaPay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ArenaPay'
  s.version          = '1.0.8'
  s.summary          = '集成了微信支付和支付宝'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/DingLe888/ArenaPay'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '18911755085@163.com' => '18911755085@163.com' }
  s.source           = { :git => 'https://github.com/DingLe888/ArenaPay.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ArenaPay/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ArenaPay' => ['ArenaPay/Assets/*.png']
  # }

  s.resource = '*.plist','*.bundle'

  s.frameworks = 'SystemConfiguration','Security','CoreTelephony','UIKit','Foundation','CFNetwork','QuartzCore','CoreText','CoreGraphics','CoreMotion'
 
  s.libraries = 'z','sqlite3.0','c++'

  s.vendored_frameworks = 'Frameworks/*'

  s.vendored_libraries = 'Libraries/*'

  s.pod_target_xcconfig = { 
    'OTHER_LDFLAGS' => ['-ObjC','-all_load'] 
  }
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
