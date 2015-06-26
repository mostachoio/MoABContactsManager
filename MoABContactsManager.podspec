#
# Be sure to run `pod lib lint MoABContactsManager.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MoABContactsManager"
  s.version          = "1.0.2"
  s.summary          = "Simple address book contacts manager."
  s.description      = <<-DESC
                      MoABContactsManager is a wrapper of AddressBook.framework which allows you to get, create, update or delete contacts in an easy way.
                       DESC
  s.homepage         = "https://github.com/mostachoio/MoABContactsManager"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Diego Pais" => "diego@mostacho.io" }
  s.source           = { :git => "https://github.com/mostachoio/MoABContactsManager.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/mostachoio'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'MoABContactsManager' => ['Pod/Assets/*.png']
  }

end
