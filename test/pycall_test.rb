# frozen_string_literal: true

# test/pycall_test.rb
require 'test_helper'

class PyCallTest < Minitest::Test
  def test_python_import
    require 'pycall/import'
    #  include PyCall::Import

    sys = PyCall.import_module :sys
    # pyimport :sys
    refute_nil sys.version
  end
end
