# frozen_string_literal: true

require 'English'
require 'etc'
require 'fileutils'
require 'singleton'

Given('I have a global config file:') do |config|
  begin
    Dir.mkdir(File.join(TESTHOME, '.config'))
    Dir.mkdir(File.join(TESTHOME, '.config/rid'))
  rescue Errno::EEXIST
    nil
  end
  File.write(File.join(TESTHOME, '.config/rid/config.yml'), replace_placeholders(config))
end

Given('I have a {string} config file:') do |dir, config|
  begin
    FileUtils.mkdir_p(File.join(TESTHOME, dir))
    @delete_files << File.join(TESTHOME, File.split(dir)[0])
  rescue Errno::EEXIST
    nil
  end
  File.write(File.join(TESTHOME, dir, '.rid.yml'), replace_placeholders(config))
end

Given('I have a {string} symlink') do |string|
  FileUtils.symlink(RID, File.join(TESTBIN, string))
  @delete_files << File.join(TESTBIN, string)
end

Given('I have a {string} file in {string}') do |file, dir|
  begin
    FileUtils.mkdir_p(File.join(TESTHOME, dir))
    @delete_files << File.join(TESTHOME, File.split(dir)[0])
  rescue Errno::EEXIST
    nil
  end
  FileUtils.touch(File.join(TESTHOME, dir, file))
end

Given('{string} has modification time {string}') do |file, mtime|
  FileUtils.touch file, mtime: DateTime.parse(mtime).to_time
end

Given('I have set the following environment variables:') do |table|
  table.rows.each do |var, |
    ENV[var] = 'some value'
    @env << var
  end
end

When('I type {string}') do |command|
  run command
end

When('I type {string} in {string}') do |command, dir|
  # Ensure the directory exists. You can't run a command in a non-existent directory.
  FileUtils.mkdir_p(dir)

  old_dir = Dir.pwd
  Dir.chdir File.join(TESTHOME, dir)
  run replace_placeholders(command)
  Dir.chdir old_dir
end

Then('it runs {string} with:') do |string, table|
  raise "Last command failed, output \"#{@stdout}\", stderr \"#{@stderr}\"" unless @rc.success?

  case DockerRuns.instance.num_runs(string)
  when 0
    raise "Command not run"
  when proc { |x| x > 1 }
    raise "Command run multiple times"
  end

  check_output(string, DockerRuns.instance.run(string).command, table)
end

Then ('it should not run {string}') do |command|
  raise "#{command} was run" if DockerRuns.instance.num_runs(command).positive?
end

Then('it runs {string} in {string} with:') do |command, dir, table|
  raise "Last command failed, output \"#{@stdout}\", stderr \"#{@stderr}\"" unless @rc.success?

  case DockerRuns.instance.num_runs(command)
  when 0
    raise "Command not run"
  when proc { |x| x > 1 }
    raise "Command run multiple times"
  end

  p DockerRuns.instance.run(command)
  unless DockerRuns.instance.run(command).cwd == File.join(TESTHOME, dir)
    raise "Command run in wrong directory: #{DockerRuns.instance.run(command).cwd}"
  end

  check_output(command, DockerRuns.instance.run(command).command, table)
end


Then('it should exit with a {string} error') do |string|
  raise "Command didn't error, output \"#{@stdout}\", stderr \"#{@stderr}\"" if @rc.success?

  raise "Unexpected output \"#{@stderr}\"" unless replace_placeholders(string) == @stderr.strip
end

Then('it should output:') do |string|
  raise "Command errored, output \"#{@stdout}\", stderr \"#{@stderr}\"" unless @rc.success?

  raise "Unexpected output \"#{@stdout}\"" unless replace_placeholders(string) == @stdout.strip
end

Then('it should output nothing') do
  raise "Command errored, output \"#{@stdout}\", stderr \"#{@stderr}\"" unless @rc.success?

  raise "Unexpected output \"#{@stdout}\"" unless @stdout.strip == ""
end

def replace_placeholders(string)
  replacements = {
    '<user name>' => Etc.getlogin,
    '<user uid>' => Process.uid,
    '<user gid>' => Process.gid,
    '<user home>' => TESTHOME,
    '<rid cache>' => File.join(TESTHOME, '.cache', 'rid'),
  }

  string.gsub(/<[^>]+>/) do |match|
    replacements.include?(match) ? replacements[match] : match
  end
end

def check_output(string, command, table)
  orig_line = command.dup
  command.gsub!(/^#{Regexp.escape(string)}/, '') or raise 'Wrong command.'

  table.rows.each do |arg,|
    arg = replace_placeholders(arg)
    command.gsub!(/(?<=\s|^)#{Regexp.escape(arg)}(?=\s|$)/, '') or
      raise "Argument #{arg} not found in command run: \"#{orig_line}\""
  end

  # Ignore env variables. Doing this last in case the command arg
  # contains some "-e something" we look for above. Also allows us to
  # check for the variables above.
  %w[HOME USERNAME LOGNAME USER].each do |var|
    command.gsub!(/--env #{var}/, '')
  end

  command.strip!
  raise "Unexpected argument(s) \"#{command}\"" unless command == ''
end

class DockerRun
  attr_reader :command, :cwd

  def initialize(string)
    (@command, @cwd) = string.split("\t")
  end
end

class DockerRuns
  include Singleton

  def runs_with_cwd
    File.read(LOGFILE).strip.lines(chomp: true).map { |line| DockerRun.new line }
  end

  def runs(command)
    runs_with_cwd.filter do |run|
      run.command =~ /^#{Regexp.escape(command)}/
    end
  end

  def num_runs(string)
    runs(string).length
  end

  def run(command)
    runs(command).pop
  end

end
