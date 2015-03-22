# SFTP Downloader

This is a gem that performs asynchronous SFTP downloads, ensuring that notifications of succesful downloads respect a sequential order.

For example, this means that if you download the following files:

- /my/files/a.txt
- /my/files/b.txt
- /my/files/c.txt

from the remote host, all downloads will start concurrently but the notification related to `b.txt` will happen only after the notification related to `a.txt`.
This is especially useful when you need to import and parse files respecting the remote filename ordering.

You can also specify if the downloaded files should be removed from the remote location once the downloads are completed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sftp_downloader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sftp_downloader

## Usage

### Command line

```bash
sftp_downloader --help
```

### Ruby

```ruby
require 'sftp_downloader'
require 'logger'

logger = Logger.new(STDOUT)

credentials = {
  host: 'INSERT_FTP_HOST_HERE',
  username: 'INSERT_FTP_USERNAME_HERE',
  password: 'INSERT_FTP_PASSWORD_HERE',
}

downloader = SftpDownloader::Client.new(
  credentials: credentials,         # required
  download_path: './tmp/downloads', # default: './'
  remote_path: '/out/',             # default: '/'
  file_pattern: /.+\.csv/,          # default: /.*\..*/
  logger: logger,                   # default: nil (doesn't log debugging info)
  remove_after_download: true,      # default: false
)

downloader.perform do |local_path|
  puts "dealing with #{local_path}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec sftp_downloader` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## To do

- add some tests (duh!)
- allow the *"classic mode"* in which files are downloaded regardless their naming order

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sftp_downloader/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
