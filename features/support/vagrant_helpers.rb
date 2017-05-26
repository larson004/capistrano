require "English"

module VagrantHelpers
  extend self
  require 'open3'

  class VagrantSSHCommandError < RuntimeError; end

  at_exit do
    if ENV["KEEP_RUNNING"]
      puts "Vagrant vm will be left up because KEEP_RUNNING is set."
      puts "Rerun without KEEP_RUNNING set to cleanup the vm."
    else
      vagrant_cli_command("destroy -f")
    end
  end

  def vagrant_cli_command(command, return_output = false)
    puts "[vagrant] #{command}"

    stdout, stderr, status = Dir.chdir(VAGRANT_ROOT) do 
      Open3.capture3 "#{VAGRANT_BIN} #{command}"
    end
    
    (stdout + stderr).split('\n').each { |line| puts "[vagrant] #{line}" }

    return_output ? stdout : status
  end

  def run_vagrant_command(command)
    status = vagrant_cli_command("ssh -c #{command.inspect}")
    return true if status.success?
    raise VagrantSSHCommandError, status
  end
end

World(VagrantHelpers)
