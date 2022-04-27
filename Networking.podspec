Pod::Spec.new do |spec|
	spec.name = 'Networking'
	spec.version = '0.0.1'
	spec.summary = 'Networking layer'
	spec.homepage = 'https://github.com/vasiliyzaycev/Networking.git'
	spec.authors = { 'Vailiy Zaycev' => 'vas-zaycev@yandex.ru' }
	spec.license = 'MIT'
	spec.source = { :path => '.' } #{ :git => 'https://github.com/vasiliyzaycev/Networking.git' }
	spec.platform = :ios, '13.0'
	spec.requires_arc = true
	spec.swift_version = '5.3'
  spec.source_files = 'Sources/**/*.swift'
end
