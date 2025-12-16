# frozen_string_literal: true

require_relative 'lib/docling/version'

Gem::Specification.new do |spec|
  spec.name = 'ruby-docling'
  spec.version = RubyDocling::VERSION
  spec.authors = ['mmgreiner']
  spec.email = ['mmgreiner@bluewin.ch']

  spec.summary = 'Wrapper for Docling.'
  spec.description = 'Simple Wrapper for Docling. "Docling turns messy PDFs, DOCX, and slides into clean, structured data—ready for RAG, GenAI apps, or anything downstream."'
  spec.homepage = 'https://github.com/mmgreiner/ruby-docling'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}.git"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .standard.yml])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # python extension
  spec.extensions << 'ext/extconf.rb'

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency 'fiddle', '~> 0.7.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
