# frozen_string_literal: true

require 'test_helper'
require 'pathname'
require 'dotenv/load'

class ConverterTest < Minitest::Test
  Dir.mkdir("tmp") unless Dir.exist?("tmp")
  samples = (ENV["SAMPLES"] || "2").to_i
  puts "sampling #{samples} files for testing"
  docx_files = Dir.glob(File.join(Dir.home, 'Downloads', '*.docx')).sample(samples)
  pdf_files = Dir.glob(File.join(Dir.home, 'Downloads', '*.pdf')).sample(samples)
  FILES = docx_files + pdf_files

  FILES.each do |file_path|
    define_method("test_conversion_of_#{File.basename(file_path)}") do
      puts "\n** Testing conversion of #{file_path}"
      converter = Docling::Converter.new
      res = converter.convert(file_path)
      md = res.document.export_to_markdown
      out_path = File.join("tmp", "#{File.basename(file_path, '.*')}.md")
      puts "++ writing #{out_path} with markdown #{md[..50].gsub(/\s/, " ")}"
      File.write(out_path, md)

      refute_nil md
      refute_empty md
    end
  end

  def test_markdown_export
    file = FILES.sample(1).first
    refute_nil file, message: "No sample files found for testing, looking in #{FILES.inspect}"
    puts "\n** Testing markdown export of #{file}"
    converter = Docling::Converter.new
    res = converter.convert(file)
    md = res.document.export_to_markdown
    puts md
    assert %w[# ## * **].any? { |token|
      md.include?(token)
    }, 'Markdown output does not contain expected formatting tokens'
  end

  def test_bulk_conversion
    converter = Docling::Converter.new
    docs = converter.convert(FILES.take(2)).map(&:document)
    docs.each do |d|
      refute_nil d
      assert_respond_to d, :export_to_markdown
    end
  end

  def test_filename_input
    file = FILES.sample
    converter = Docling::Converter.new
    res = converter.convert(file)
    assert_equal File.basename(file), res.input.file.to_s, "Input file path does not match"
  end
end
