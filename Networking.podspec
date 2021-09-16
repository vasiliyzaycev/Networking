Pod::Spec.new do |spec|
	spec.name = 'Networking'
	spec.version = '0.0.1'
	spec.summary = 'Networking layer'
	spec.homepage = 'https://github.com/Networking'
	spec.authors = { 'Vailiy Zaycev' => 'vas-zaycev@yandex.ru' }
	spec.license = 'MIT'
	spec.source = { :path => '.' } #{ :git => 'https://github.com/Networking.git' }
	spec.platform = :ios, '11.0'
	spec.requires_arc = true
	spec.swift_version = '5.3'
	spec.default_subspec = 'Swift'

	spec.subspec 'Swift' do |subspec|
		subspec.source_files = 'Sources/**/*.swift'
		subspec.dependency 'Networking/ObjcUtils'
	end

	spec.subspec 'ObjcUtils' do |subspec|
		subspec.source_files = 'Sources/ObjcUtils/**/*.{h,m}', 'Networking.h'
		subspec.exclude_files = 'Sources/ObjcUtils/Include/*'
	end
end
