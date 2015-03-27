Pod::Spec.new do |s|
  s.platform = :ios, '8.0'
  s.name = 'Pretender'
  s.version = '0.0.1'
  s.summary = 'A Swift wrapper for OHHTTPStubs in the spirit of pretender.js'
  s.homepage = 'http://mine.nyc'
  s.license = 'MIT' #  shut up pod spec lint
  s.author = {
    'Yusef Napora' => 'yusef@napora.org'
  }
  s.source = {
    :git => 'https://github.com/yusefnapora/pretender.git',
    :tag => s.version.to_s
  }

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'Pretender/Core/*.{h,m,swift}'
    core.dependency 'OHHTTPStubs', '~> 3.1.11'
    core.dependency 'SwiftyJSON', '2.1.3'
  end

  s.subspec 'AlamofireManager' do |af|
    af.source_files = 'Pretender/AlamofireManager/*.swift'
    af.dependency 'Pretender/Core'
    af.dependency 'Alamofire', '1.1.3'
  end
  
end