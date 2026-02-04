Pod::Spec.new do |s|
  s.name             = 'SwiftCodeGen'
  s.version          = '1.0.0'
  s.summary          = 'Code generation tools for Swift boilerplate reduction'
  s.description      = 'Code generation tools for Swift boilerplate reduction. Built with modern Swift.'
  s.homepage         = 'https://github.com/muhittincamdali/SwiftCodeGen'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/SwiftCodeGen.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
end
