# frozen_string_literal: true

require 'fileutils'
require 'open3'

# Setup test environment.
TESTROOT = '/tmp/rid'
TESTBIN = File.join(TESTROOT, 'bin')
TESTHOME = File.join(TESTROOT, 'home')
TESTRIDHOME = File.join(TESTROOT, 'home/dev')
LOGFILE = File.join(TESTBIN, 'exec.log')

Dir.mkdir(TESTROOT)
Dir.mkdir(TESTHOME)
Dir.mkdir(TESTRIDHOME)
Dir.mkdir(TESTBIN)

# Link rid into the bin dir.
FileUtils.symlink(File.join(File.dirname(File.dirname(__dir__)), 'rid'), File.join(TESTBIN, 'rid'))

RID = File.join(TESTBIN, 'rid')

# Create a fake docker that'll just log the commands.
DOCKERSTUB = File.join(TESTBIN, 'docker')

FileUtils.copy(File.join(__dir__, 'docker'), TESTBIN, preserve: true)

# Set $HOME to our test dir and add our bin dir to the path.
ENV['HOME'] = TESTHOME

# Let's run with our own username.
ENV['USER'] = 'rid-test'

# These might not all be set in CI, so ensure they are.
ENV['USERNAME'] = 'rid-test'
ENV['LOGNAME'] = 'rid-test'

ENV['PATH'] = "#{TESTBIN}:#{ENV['PATH']}"

# Clean up after tests.
at_exit do
  FileUtils.rm_rf(TESTROOT)
end

Before do
  @old_cwd = Dir.getwd
  # Change current working directory to be in the fake test users home dir.
  Dir.chdir TESTHOME
  # Initialize scenario variables.
  @stdout = @stderr = ''
  @rc = 0
  @delete_files = []
end

After do
  # Restore current working directory to not confuse cucumber.
  Dir.chdir @old_cwd
  @stdout = @stderr = ''
  @rc = 0
  # Clean up.
  FileUtils.rm(LOGFILE) if File.exist? LOGFILE
  FileUtils.rm_rf(File.join(TESTHOME, '.config')) if File.exist? File.join(TESTHOME, '.config')
  @delete_files.each do |file|
    FileUtils.rm_rf(file) if File.exist? file
  end

  @delete_files = []
end

def run(command)
  args = command.split(' ')

  @stdout, @stderr, @rc = Open3.capture3(*args)
  @rc
end
