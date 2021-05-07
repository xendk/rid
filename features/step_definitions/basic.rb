# frozen_string_literal: true

require 'English'
require 'etc'
require 'fileutils'

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

When('I type {string}') do |command|
  run command
end

When('I type {string} in {string}') do |command, dir|
  old_dir = Dir.pwd
  Dir.chdir File.join(TESTHOME, dir)
  run command
  Dir.chdir old_dir
end

Then('it runs {string} with:') do |string, table|
  raise "Last command failed, output \"#{@output}\", stderr \"#{@stderr}\"" unless @rc.success?

  line = File.read(LOGFILE).strip
  orig_line = line.dup
  line.gsub!(/^#{Regexp.escape(string)}/, '') or raise 'Wrong command.'

  table.rows.each do |arg,|
    arg = replace_placeholders(arg)

    line.gsub!(/(?<=\s|^)#{Regexp.escape(arg)}(?=\s|$)/, '') or
      raise "Argument #{arg} not found in command run: \"#{line}\""
  end

  # Ignore env variables. Doing this last in case the command arg
  # contains some "-e something" we look for above. Also allows us to
  # check for the variables above.
  ['HOME', 'USERNAME', 'LOGNAME', 'USER'].each do |var|
    line.gsub!(/-e #{var}/, '')
  end

  line.strip!
  raise "Unexpected argument(s) \"#{line}\"" unless line == ''
end

Then('it should exit with a {string} error') do |string|
  raise "Command didn't error, output \"#{@output}\", stderr \"#{@stderr}\"" if @rc.success?
  raise "Unexpected output \"#{@stderr}\"" unless string == @stderr.strip
end

def replace_placeholders(string)
  replacements = {
    '<user name>' => Etc.getlogin,
    '<user uid>' => Process.uid,
    '<user gid>' => Process.gid,
    '<user home>' => TESTHOME,
    '<rid cache>' => File.join(TESTHOME, '.cache', 'rid')
  }

  string.gsub(/<[^>]+>/) do |match|
    replacements.include?(match) ? replacements[match] : match
  end
end
