Pod::Spec.new do |s|
  s.name             = 'Diffing'
  s.version          = '1.0.0'
  s.summary          = 'A small framework designed to determine the differences between two collections.'

  s.description      = <<-DESC
Diffing is a small framework designed to make determining the differences, or edits, between two collections as simple as possible.
                       DESC

  s.homepage         = 'https://github.com/wmcginty/Diffing'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'William McGinty' => 'mcgintw@gmail.com' }
  s.source           = { :git => 'https://github.com/wmcginty/Diffing.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.macos.deployment_target = '10.12'
  
  s.swift_version = '5.5'
  s.source_files = 'Sources/**/*'
  s.frameworks = 'Foundation', 'UIKit'
end
