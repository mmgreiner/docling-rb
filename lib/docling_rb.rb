# frozen_string_literal: true

require_relative 'docling_rb/version'

# Docling module provides a Ruby wrapper for the Docling Python library.
module DoclingRb
  require 'pycall/import'

  class Converter
    include PyCall::Import
    def initialize
      abort 'need to set PYTHON' unless ENV['PYTHON']
      # see `python_ruby.md` for details on these settings
      ENV['PYTHONWARNINGS'] = 'ignore'
      ENV['OMP_NUM_THREADS'] = '1'
      ENV['MKL_NUM_THREADS'] = '1'
      pyimport 'multiprocessing'
      multiprocessing.set_start_method('fork', force: true)
      pyimport 'docling.document_converter', as: :docling
      pyimport 'docling.datamodel.pipeline_options', as: :pipeline_options
    end

    # Convert one document fetched from a file path, URL, or DocumentStream.
    #
    # @param source [Pathname, String, DocumentStream, HttpSource] source of input
    #   document given as file path, URL, DocumentStream, or HttpSource (a URL
    #   bundled with its own headers)
    # @param headers [Hash<String, String>, nil] optional headers given as a hash
    #   of string key-value pairs, in case of URL input source (default: nil)
    # @param raises_on_error [Boolean] whether to raise an error on the first
    #   conversion failure (default: true)
    # @param max_num_pages [Integer] maximum number of pages accepted per
    #   document (default: unlimited)
    # @param max_file_size [Integer] maximum file size to convert, in bytes
    #   (default: unlimited)
    # @param page_range [PageRange] range of pages to convert (default: all pages)
    # @return [ConversionResult] the conversion result, which contains a
    #   DoclingDocument in the +document+ attribute, and metadata about the
    #   conversion process
    #
    # Example:
    #   converter = Docling::Converter.new
    #   result = converter.convert("myfile.docx")
    #   puts result.document.export_to_markdown
    #
    # The `ConversionResult` is described in @see https://docling-project.github.io/docling/reference/document_converter/
    # It contains:
    # - document - The converted DoclingDocument (the main structured representation)
    # - input - InputDocument object containing metadata about the input file (includes file, document_hash, format, filesize, page_count)
    # - status - ConversionStatus enum (SUCCESS, FAILURE, PARTIAL_SUCCESS, PENDING, STARTED, SKIPPED)
    # - errors - List of ErrorItem objects for any errors encountered
    # - pages - Dictionary of page-level information and predictions
    # - legacy_document - Deprecated Docling v1 document representation
    # - assembled - Assembled unit information
    # - confidence - Confidence scores
    # - timestamp - Conversion timestamp
    # - timings - Timing information
    # - version - Version information
    def convert(sources, **kwargs)
      converter = docling.DocumentConverter.new
      if sources.is_a? Array
        results = PyCall.builtins.list.call(converter.convert_all(sources, **kwargs))
        results.to_a
      else
        converter.convert(sources, **kwargs)
      end
    end
  end
end
