# frozen_string_literal: true

# Check for Python
abort 'Python 3 is required but not found in PATH' unless system('python3 --version > /dev/null 2>&1')

`python3 -c "import sys; print('.'.join(map(str, sys.version_info[:3])))"`.strip

# abort "Python 3.10 is required (found Python #{python_version})" unless python_version.start_with?("3.10")

# Check for pip
abort 'pip3 is required but not found in PATH' unless system('pip3 --version > /dev/null 2>&1')

# Install Python dependencies
%w[docling opencv-python].each do |package|
  abort "Failed to install Python dependency #{package}" unless system("pip3 install #{package}")
end

# Create dummy Makefile (required by RubyGems)
File.open('Makefile', 'w') do |f|
  f.puts "install:\n\t@echo 'Python dependencies installed'"
  f.puts "clean:\n\t@echo 'Nothing to clean'"
end
