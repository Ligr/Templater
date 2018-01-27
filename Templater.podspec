#
# Be sure to run `pod lib lint Templater.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Templater'
  s.version          = '0.1.4'
  s.summary          = 'Framework that process data using templates.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#   s.description      = <<-DESC
# TODO: Add long description of the pod here.
#                        DESC

  s.homepage         = 'https://github.com/Ligr/Templater'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ligr' => 'aliaksandr.huryn@gmail.com' }
  s.source           = { :git => 'https://github.com/Ligr/Templater.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.default_subspecs = 'TemplaterCore', 'TemplaterActions'

  s.subspec 'TemplaterCore' do |sp|
    sp.source_files = 'Templater/Classes/TemplaterCore/**/*'
  end

  s.subspec 'TemplaterActions' do |sp|
    sp.source_files = 'Templater/Classes/TemplaterActions/**/*'
    sp.dependency 'Templater/TemplaterCore'
    sp.dependency 'CryptoSwift', '~> 0.8'
    sp.dependency 'LPXML', '~> 0.1'
    sp.dependency 'Alamofire', '~> 4.0'
  end

  # s.source_files = 'Templater/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Templater' => ['Templater/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
