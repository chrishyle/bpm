require 'execjs'

# The following is backported from ExecJS master (post 1.2.4)
# Once 1.2.5 is released, we can remove this

module ExecJS
  module Runtimes
    remove_const :JavaScriptCore
    JavaScriptCore = ExternalRuntime.new(
      :name        => "JavaScriptCore",
      :command     => ["/System/Library/Frameworks/JavaScriptCore.framework/Versions/A/Resources/jsc", "jsc"],
      :runner_path => ExecJS.root + "/support/jsc_runner.js"
    )

    remove_const :JScript
    JScript = ExternalRuntime.new(
      :name        => "JScript",
      :command     => "cscript //E:jscript //Nologo //U",
      :runner_path => ExecJS.root + "/support/jscript_runner.js",
      :encoding    => 'UTF-16LE' # CScript with //U returns UTF-16LE
    )
  end

  class ExternalRuntime
    def initialize(options)
      @name        = options[:name]
      @command     = options[:command]
      @runner_path = options[:runner_path]
      @test_args   = options[:test_args]
      @test_match  = options[:test_match]
      @encoding    = options[:encoding]
      @binary      = locate_binary
    end

    def exec_runtime(filename)
      output = sh("#{@binary} #{filename} 2>&1")
      if $?.success?
        output
      else
        raise RuntimeError, output
      end
    end

    protected

      def which(command)
        Array(command).each do |name|
          name, args = name.split(/\s+/, 2)
          result = if ExecJS.windows?
            `"#{ExecJS.root}/support/which.bat" #{name}`
          else
            `command -v #{name} 2>/dev/null`
          end

          if path = result.strip.split("\n").first
            return args ? "#{path} #{args}" : path
          end
        end
        nil
      end

      if "".respond_to?(:force_encoding)
        def sh(command)
          output, options = nil, {}
          options[:external_encoding] = @encoding if @encoding
          IO.popen(command, options) { |f| output = f.read }
          output
        end
      else
        require "iconv"

        def sh(command)
          output = nil
          IO.popen(command) { |f| output = f.read }

          if @encoding
            Iconv.new('UTF-8', @encoding).iconv(output)
          else
            output
          end
        end
      end
  end
end