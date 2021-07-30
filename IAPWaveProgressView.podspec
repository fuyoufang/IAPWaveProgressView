#
# Be sure to run `pod lib lint IAPWaveProgressView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IAPWaveProgressView'
  s.version          = '0.1.0'
  s.summary          = '内购水波过度动画.'

  s.description      = <<-DESC
  内购水波过度动画，分为三个过程，准备支付，支付中（验证中），支付完成，分别有对应的动画展示。
                       DESC

  s.homepage         = 'https://github.com/FuYouFang/IAPWaveProgressView.git'
  s.swift_version = '5.0'
  s.screenshots     = 'https://github.com/FuYouFang/IAPWaveProgressView/raw/master/Images/prapare.png', 'https://github.com/FuYouFang/IAPWaveProgressView/raw/master/Images/paying.png', 'https://github.com/FuYouFang/IAPWaveProgressView/raw/master/Images/complate.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fuyoufang@163.com' => 'fuyoufang@163.com' }
  s.source           = { :git => 'https://github.com/FuYouFang/IAPWaveProgressView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'IAPWaveProgressView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IAPWaveProgressView' => ['IAPWaveProgressView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Then'
  s.dependency 'SnapKit'
  
end
