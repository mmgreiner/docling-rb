# frozen_string_literal: true

require_relative 'docling/version'


module Docling
  require 'pycall/import'

  class Converter
    include PyCall::Import
    def initialize
      pyimport 'cv2', as: :cv2
      pyimport 'docling.document_converter', as: :docling
      pyimport 'docling.datamodel.pipeline_options', as: :pipeline_options
    end

    # Convert a document from source format to Docling's internal representation
    # @param source [String] The source document as a string
    # @return [Docling::Document] The converted document
    # 
    # Example:
    #   converter = Docling::Converter.new
    #   document = converter.convert("myfile.docx")
    #   puts document.export_to_markdown
    def convert(source)
      converter = docling.DocumentConverter.new
      result = converter.convert(source)
      result.document
    end
  end
end
