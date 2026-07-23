# Ruby::Docling

This is a tiny ruby wrapper on [docling].


[docling]: https://www.docling.ai/

## Installation



Install the gem and add to the application's Gemfile by executing:

```bash
bundle add docling-rb --github mmgreiner/docling-rb
```

If bundler is not being used to manage dependencies, we need [specific_install](https://github.com/rdp/specific_install) to install the gem from github:

```bash
gem install specific_install
gem specific_install https://github.com/mmgreiner/docling-rb.git
```

### Install issues

Sometimes, the python installs cause problems. You can install the python packages manually:

```bash
pip3 install docling
pip3 install opencv-python
```

## Usage

**IMPORTANT**: This uses [pycall](https://github.com/red-data-tools/pycall.rb) to wrap the [docling] python library.
You have to set `PYTHON` in the environment:

```bash
export PYTHON=$(which python)
```

Then in ruby, do:

```ruby
require 'docling_rb'
converter = DoclingRb::Converter.new
result = converter.convert("myfile.docx")
puts result.document.export_to_markdown
```

You can also convert an array of files:

```ruby
converter = DoclingRb::Converter.new
results = converter.convert(["file.pdf", "file_b.docx"])
results.each do |result|
  puts result.document.export_to_markdown
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mmgreiner/ruby-docling.
