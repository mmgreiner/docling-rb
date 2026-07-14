# frozen_string_literal: true

require_relative 'docling_rb/version'

# Docling module provides a Ruby wrapper for the Docling Python library.
module DoclingRb
  require 'pycall/import'

  class Converter
    include PyCall::Import
    def initialize
      # see `python_ruby.md` for details on these settings
      ENV["PYTHONWARNINGS"] = "ignore"
      ENV["OMP_NUM_THREADS"] = "1"
      ENV["MKL_NUM_THREADS"] = "1"
      pyimport 'multiprocessing'
      multiprocessing.set_start_method("fork", force: true)
      pyimport 'docling.document_converter', as: :docling
      pyimport 'docling.datamodel.pipeline_options', as: :pipeline_options
    end

    # Convert a document from source format to Docling's internal representation
    # @param sources [String] The source document as a string, or an array of source document paths
    # @return [Docling::ConversionResult] The results of the converted document(s)
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
    def convert(sources)
      converter = docling.DocumentConverter.new
      sources = [sources] unless sources.is_a?(Array)
      results = sources.map do |source|
        converter.convert(source)
      end
      results.length == 1 ? results.first : results
    end
  end
end
