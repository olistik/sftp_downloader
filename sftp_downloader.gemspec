# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sftp_downloader/version'

Gem::Specification.new do |spec|
  spec.name          = "sftp_downloader"
  spec.version       = SftpDownloader::VERSION
  spec.authors       = ["Maurizio De Magnis"]
  spec.email         = ["maurizio.demagnis@gmail.com"]

  spec.summary       = %q{Asynchronous SFTP downloads that respect filename ordering.}
  spec.description   = %q{This is a gem that performs asynchronous SFTP downloads, ensuring that notifications of succesful downloads respect a sequential order.}
  spec.homepage      = "https://github.com/olistik/sftp_downloader"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
  end

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "net-sftp", "~> 2.1.2"
end
