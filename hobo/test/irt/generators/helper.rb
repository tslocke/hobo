irt_at_exit{git_reset_app}

def invoke(*args)
  Rails::Generators.invoke *args
end

def files_exist?(paths)
  missing = paths.reject{|f| File.exists?(f)}
  missing.empty? || missing
end

def file_include?(path, *strings)
  file_content path, :select, *strings
end

def file_exclude?(path, *strings)
  file_content path, :reject, *strings
end

def file_content(path, action, *strings)
  f = File.read(path)
  wrong = strings.send(action) do |s|
            re = s.is_a?(Regexp) ? s : /#{Regexp.escape(s)}/
            !(f =~ re)
          end
  wrong.empty? || wrong
end

def git_reset_app
  system %(cd #{Hobo.root} && rake test:prepare_testapp -q)
end
