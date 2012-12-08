module Subtle
  class CLI
    def initialize(argv)
      repl # Just start the REPL for now
    end

    def repl
      require "readline"
      prompt = "> "

      evaluator = Evaluator.new
      loop do
        line = Readline::readline(prompt)

        if line.nil? or line.empty?
          puts if line.nil?
          puts "Bye!"
          exit 0
        end

        Readline::HISTORY << line

        begin
          p evaluator.eval line
        rescue Exception => e
          puts e.message
          puts e.backtrace
        end
      end
    end
  end
end
