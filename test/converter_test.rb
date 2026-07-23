# frozen_string_literal: true

require 'test_helper'
require 'pathname'
require 'dotenv/load'

class ConverterTest < Minitest::Test
  Dir.mkdir('tmp') unless Dir.exist?('tmp')
  SAMPLES = ENV['TEST_SAMPLES']&.to_i || 10
  puts "sampling #{SAMPLES} files for testing"
  docx_files = Dir.glob(File.join(Dir.home, 'Downloads', '*.docx')).sample(SAMPLES)
  pdf_files = Dir.glob(File.join(Dir.home, 'Downloads', '*.pdf')).sample(SAMPLES)

  FILES = docx_files + pdf_files

  FILES.each do |file_path|
    fn = File.basename(file_path).gsub(/\W/, "_")
    define_method("test_conversion_of_#{fn}") do
      puts "\n** Reading #{file_path}"
      converter = DoclingRb::Converter.new
      res = converter.convert(file_path)
      md = res.document.export_to_markdown
      out_path = File.join('tmp', "#{File.basename(file_path, '.*')}.md")
      puts "++ writing #{out_path} with markdown #{md[..50].gsub(/\s/, ' ')}"
      File.write(out_path, md)

      refute_nil md
      refute_empty md
    end
  end

  def test_markdown_export
    file = FILES.sample(1).first
    refute_nil file, message: "No sample files found for testing, looking in #{FILES.inspect}"
    puts "\n** Testing markdown export of #{file}"
    converter = DoclingRb::Converter.new
    res = converter.convert(file)
    md = res.document.export_to_markdown
    puts md
    assert %w[# ## * **].any? { |token|
      md.include?(token)
    }, 'Markdown output does not contain expected formatting tokens'
  end

  def test_bulk_conversion
    converter = DoclingRb::Converter.new
    res = converter.convert(FILES.sample(SAMPLES))
    refute_empty res
    res.each do |r|
      refute_nil r.document
      refute_empty r.document.export_to_markdown
    end
  end

  def test_filename_input
    file = FILES.sample
    converter = DoclingRb::Converter.new
    res = converter.convert(file)
    assert_equal File.basename(file), res.input.file.to_s, 'Input file path does not match'
  end

  def test_convert_html_file
    dir = ENV['TEST_HTML_DIR'] || '/Users/mmgreiner/Projects/lu-azure/LuzernConnect-KI/scrapers/news/2025'
    files = Dir.glob(File.join(dir, '*.html'))

    converter = DoclingRb::Converter.new

    files.sample(10).each do |file|
      res = converter.convert(file)
      refute_nil res
      doc = res.document
      refute_nil doc
      refute_empty doc.export_to_markdown
    end
  end

  def test_keyword
    converter = DoclingRb::Converter.new
    begin
      converter.convert(FILES.sample, headers: nil)
      pass
    rescue => e
      flunk "Expected no exception, but got #{e.class}: #{e.message}"
    end
    assert_raises(PyCall::PyError, NameError) do
      convert.convert(Files.sample, stupid: 1)
    end
  end
end
