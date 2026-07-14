# frozen_string_literal: true

# Check for Python
abort 'Python 3 is required but not found in PATH' unless system('python3 --version > /dev/null 2>&1')

python_version = `python3 -c "import sys; print('.'.join(map(str, sys.version_info[:3])))"`.strip

minor_version = python_version.split('.')[1].to_i
abort "Python 3.10..14 is required (found Python #{python_version})" unless (10..14).include?(minor_version)

# Check for pip
abort 'pip3 is required but not found in PATH' unless system('pip3 --version > /dev/null 2>&1')

# Install Python dependencies
%w[docling opencv-python].each do |package|
  abort "Failed to install Python dependency #{package}" unless system("pip3 install #{package}")
end

# Verify installations
system('python3 -c "import docling; print(docling.__file__)"')
# Create dummy Makefile (required by RubyGems)
File.open('Makefile', 'w') do |f|
  f.puts "install:\n\t@echo 'Python dependencies installed'"
  f.puts "clean:\n\t@echo 'Nothing to clean'"
end
