Pod::Spec.new do |s|
  s.name             = 'rss_it_library'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for parsing RSS/Atom/JSON feeds, powered by Go-based gofeed package'
  s.description      = <<-DESC
Flutter plugin for parsing RSS/Atom/JSON feeds, powered by Go-based gofeed package
                       DESC
  s.homepage         = 'https://github.com/sunderee/rss-it'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Peter Aleksander Bizjak' => 'peter.aleksander@bizjak.dev' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '18.0'
  s.script_phase = {
    :name => 'update go library',
    :script => 'touch ${BUILT_PRODUCTS_DIR}/prebuild.touch',
    :execution_position=> :before_compile,
    :input_files => ['${PODS_TARGET_SRCROOT}/../prebuild/${PLATFORM_FAMILY_NAME}/'],
    :output_files => ["${BUILT_PRODUCTS_DIR}/prebuild.touch"],
  }

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => "-force_load ${PODS_TARGET_SRCROOT}/../prebuild/${PLATFORM_FAMILY_NAME}/${PLATFORM_NAME}/${CURRENT_ARCH}/lib#{s.name}.a",
  }

  s.swift_version = '5.0'
end
