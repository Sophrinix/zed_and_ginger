require 'rake/clean'
require 'redcloth'

APP = "zed_and_ginger"
require_relative "lib/version"

RELEASE_VERSION = ZedAndGinger::VERSION
SOURCE_FOLDERS = %w[bin lib media build]

EXECUTABLE = "#{APP}.exe"

SOURCE_FOLDER_FILES = FileList[SOURCE_FOLDERS.map {|f| "#{f}/**/*"}]
EXTRA_SOURCE_FILES = %w[.gitignore Rakefile README.textile Gemfile Gemfile.lock]

RELEASE_FOLDER = 'pkg'
RELEASE_FOLDER_BASE = File.join(RELEASE_FOLDER, "#{APP}_v#{RELEASE_VERSION.gsub(/\./, '_')}")
RELEASE_FOLDER_WIN32 = "#{RELEASE_FOLDER_BASE}_WIN32"
RELEASE_FOLDER_SOURCE = "#{RELEASE_FOLDER_BASE}_SOURCE"

README_TEXTILE = "README.textile"
README_HTML = "README.html"

CHANGELOG = "CHANGELOG.txt"

CLEAN.include("*.log")
CLOBBER.include("doc/**/*", EXECUTABLE, RELEASE_FOLDER, README_HTML)

require_relative 'build/rake_osx_package'

desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end

# Making a release.
file EXECUTABLE => :ocra

desc "Use Ocra to generate #{EXECUTABLE} (Windows only) v#{RELEASE_VERSION}"
task ocra: SOURCE_FOLDER_FILES do
  system "ocra bin/#{APP}.rbw --windows --icon media/icon.ico lib/**/*.* media/**/*.* config/**/*.* bin/**/*.*"
end

# Making a release.

def compress(package, folder, option = '')
  puts "Compressing #{package}"
  rm package if File.exist? package
  cd 'pkg'
  puts File.basename(package)
  puts %x[7z a #{option} "#{File.basename(package)}" "#{File.basename(folder)}"]
  cd '..'
end

desc "Create release packages v#{RELEASE_VERSION} (Not OSX)"
task release: [:release_source, :release_win32]

desc "Create source releases v#{RELEASE_VERSION}"
task release_source: [:source_zip, :source_7z]

desc "Create win32 releases v#{RELEASE_VERSION}"
task release_win32:  [:win32_zip] # No point making a 7z, since it is same size.

# Create folders for release.
file RELEASE_FOLDER_WIN32 => [EXECUTABLE, README_HTML] do
  mkdir_p RELEASE_FOLDER_WIN32
  cp EXECUTABLE, RELEASE_FOLDER_WIN32
  cp CHANGELOG, RELEASE_FOLDER_WIN32
  cp README_HTML, RELEASE_FOLDER_WIN32
end

file RELEASE_FOLDER_SOURCE => README_HTML do
  mkdir_p RELEASE_FOLDER_SOURCE
  SOURCE_FOLDERS.each {|f| cp_r f, RELEASE_FOLDER_SOURCE }
  cp EXTRA_SOURCE_FILES, RELEASE_FOLDER_SOURCE
  cp CHANGELOG, RELEASE_FOLDER_SOURCE
  cp README_HTML, RELEASE_FOLDER_SOURCE
end

{ "7z" => '', :zip => '-tzip' }.each_pair do |compression, option|
  { source: RELEASE_FOLDER_SOURCE, win32: RELEASE_FOLDER_WIN32}.each_pair do |name, folder|
    package = "#{folder}.#{compression}"
    desc "Create #{package}"
    task :"#{name}_#{compression}" => package
    file package => folder do
      compress(package, folder, option)
    end
  end
end

# Generate a friendly readme
file README_HTML => :readme
desc "Convert readme to HTML"
task :readme => README_TEXTILE do
  puts "Converting readme to HTML"
  File.open(README_HTML, "w") do |file|
    file.write RedCloth.new(File.read(README_TEXTILE)).to_html
  end
end

desc "Run all our tests"
task :test do
  begin
    ruby File.expand_path("test/run_all.rb", File.dirname(__FILE__))
  rescue
    exit 1
  end
end


