# Class: Proton::CLI
# Command line runner.

class Proton
class CLI < Shake
  autoload :Helpers, "#{PREFIX}/proton/cli/helpers"

  extend  Helpers
  include Defaults

  task(:create) do
    wrong_usage  unless params.size == 1
    template = File.expand_path('../../../data/new_site', __FILE__)
    target   = params.first

    if target == '.'
      pass "This is already a Proton project."  if @protonfile
      FileUtils.cp_r File.join(template, 'Protonfile'), target
      say_status :create, 'Protonfile'
      pass
    end

    pass "Error: target directory already exists."  if File.directory?(target)

    puts "Creating files in #{target}:"
    puts

    FileUtils.cp_r template, target
    Dir[File.join(target, '**', '*')].sort.each do |f|
      say_status :create, f  if File.file?(f)
    end

    puts ""
    puts "Done! You've created a new project in #{target}."
    puts "Get started now:"
    puts ""
    puts "  $ cd #{target}"
    puts "  $ #{executable} start"
    puts ""
    puts "Or build the HTML files:"
    puts ""
    puts "  $ #{executable} build"
    puts ""
  end

  task.description = "Starts a new Proton project"
  task.usage = "create NAME"
  task.category = :create

  task(:build) do
    pre = project.config.output_path

    project.build { |page|
      c, handler = if page.tilt?
        [ 33, "#{page.tilt_engine_name.downcase}" ]
      else
        [ 30, '*' ]
      end

      puts ("\033[0;#{c}m%10s\033[0;32m  #{pre}\033[0;m%s" % [ handler, page.path ]).strip
    }
    project.send :build_cleanup
  end

  task.description = "Builds the current project"
  task.category = :project

  task(:start) do
    project

    port   = (params.extract('-p') || 4833).to_i
    host   = (params.extract('-o') || '0.0.0.0')
    daemon = (!! params.delete('-D'))

    require 'proton/server'

    if daemon
      pid = fork { Proton::Server.run! :Host => host, :Port => port, :quiet => true }
      sleep 2
      puts
      puts "Listening on #{host}:#{port} on pid #{pid}."
      puts "To stop: kill #{pid}"
    else
      Proton::Server.run! :Host => host, :Port => port
    end
  end

  task.description = "Starts the server"
  task.category = :project
  task.help = %{
    Usage:

        #{executable} start [-p PORT] [-o HOST] [-D]
    
    Starts an HTTP server so you may rapidly test your project locally.

    If the -p and/or -o is specified, it will listen on the specified HOST:PORT.
    Otherwise, the default is 0.0.0.0:4833.

    If -D is specified, it goes into daemon mode.
  }.gsub(/^ {4}/, '').strip.split("\n")

  task(:rack) do
    project

    from  = File.expand_path("#{PREFIX}/../data/rack/*")
    files = Dir[from]

    files.each do |f|
      FileUtils.cp f, '.'
      say_status :create, File.basename(f)
    end

    err ""
    err "Done! Your project is now Rack-compatible."
    err "Test it out locally by:"
    err ""
    err "  $ rackup"
    err ""
    err "You may now use your project as-is in a Rack-compatible environment,"
    err "such as Pow, Heroku or a host that supports Passenger."
  end

  task.description = "Makes a project Rack-compatible."
  task.category = :project

  task(:version) do
    puts "Proton #{Proton::VERSION}"
  end

  task.description = "Shows the current version"
  task.category = :misc

  task(:help) do
    show_help_for(params.first) and pass  if params.any?

    show_task = Proc.new { |name, t| err "  %-20s %s" % [ t.usage || name, t.description ] }

    err "Usage: #{executable} <command>"

    unless project?
      err "\nCommands:"
      tasks_for(:create).each &show_task
    end

    if project?
      err "\nProject commands:"
      tasks_for(:project).each &show_task
    end

    if other_tasks.any?
      err "\nOthers:"
      other_tasks.each &show_task
    end
    err "\nMisc commands:"
    tasks_for(:misc).each &show_task

    unless project?
      err
      err "Get started by typing:"
      err "  $ #{executable} create my_project"
    end
    err
    err "Type `#{executable} help COMMAND` for additional help on a command."
  end

  task.description = "Shows help for a given command"
  task.usage = "help [COMMAND]"
  task.category = :misc

  invalid do
    task = task(command)
    if task
      err "Invalid usage."
      err "Try: #{executable} #{task.usage}"
      err
      err "Type `#{executable} help` for more info."
    else
      err "Invalid command: #{command}"
      err "Type `#{executable} help` for more info."
    end
  end

  def self.run(*argv)
    return invoke(:version)  if argv == ['-v'] || argv == ['--version']
    trace = (!!argv.delete('--trace'))


    begin
      super *argv

    rescue SyntaxError => e
      raise e  if trace
      err
      say_error e.message.split("\n").last
      err
      say_error "You have a syntax error."
      say_info "Use --trace for more info."

    # Convert 'can't load redcloth' to a friendly 'please gem install RedCloth'
    rescue LoadError => e
      raise e  if trace
      show_needed_gem gem_name(e)

    # Print generic errors as something friendlier
    rescue => e
      raise e  if trace

      # Can't assume that HAML is always available.
      if Object.const_defined?(:Haml) && e.is_a?(Haml::Error)
        # Convert HAML's "Can't run XX filter; required 'yy'" messages
        # to something friendlier
        needed = %w(rdiscount stringio sass/plugin redcloth)
        needed.detect { |what| show_needed_gem(what) && true  if e.message.include?(what) }
      else
        err
        say_error "#{e.class}: #{e.message}"
        say_info "#{e.backtrace.first}"
        err
        say_error "Oops! An error occured."
        say_info "Use --trace for more info."
      end
    end
  end

  def self.find_config_file
    Proton::CONFIG_FILES.inject(nil) { |a, fname| a ||= find_in_project(fname) }
  end

  def self.run!(options={})
    @config_file = options[:file] || find_config_file
    Proton::Project.new rescue nil
    super *[]
  end
end
end
