require "bundler/gem_tasks"

task :pry do
  prelude = "include Subtle; pa = Parser.new; t = Transform.new;" +
    "e = Evaluator.new;"
  system "pry -Ilib -rsubtle -e '#{prelude}; puts \"#{prelude}\"'"
end

task default: :pry
