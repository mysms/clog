Pod::Spec.new do |spec|

  spec.name         = 'CLog'
  spec.version      = '1.1.2'
  spec.summary      = 'Logging wrapper that is used in mysms project'
  spec.homepage     = 'http://www.mysms.com'
  spec.author       = { 'Christoph Lückler' => 'christoph.lueckler@ut11.net' }
  spec.source       = { :git => 'git://github.com/mysms/clog.git', :tag => '1.1.2' }

  spec.source_files   = 'CLog/Classes/Logger/'
  
  spec.dependency 'CocoaLumberjack', '~> 1.9'
  spec.dependency 'objective-zip', '~> 0.8'

end