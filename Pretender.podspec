Pod::Spec.new do |s|
  s.platform = :ios, '8.0'
  s.name = 'Pretender'
  s.version = '0.0.1'
  s.summary = 'A Swift wrapper for OHHTTPStubs in the spirit of pretender.js'
  s.homepage = 'http://mine.nyc'
  s.author = {
    'Yusef Napora' => 'yusef@napora.org'
  }
  s.source = {
    :git => 'https://github.com/yusefnapora/pretender.git',
    :tag => s.version.to_s
  }

  s.subspec 'Core' do |core|
    core.source_files = 'Pretender/Core/*.{h,m,swift}'
    core.dependency 'Quick', '~> 0.2.2'
  end


end