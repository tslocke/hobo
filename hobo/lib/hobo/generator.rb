require 'find'
require "rails_generator"

class Hobo::Generator < Rails::Generator::Base

  def with_source_in(path)
    root = source_path(path)
    Find.find(root) do |f|
      Find.prune if File.basename(f) == ".svn"
      full_path = f[(source_root.length)..-1]
      rel_path = f[(root.length)..-1]
      yield full_path, rel_path
    end
  end

  def create_all(m, src, dest)
    with_source_in(src) do |full, rel|
      if File.directory?(source_path(full))
        m.directory File.join(dest, rel)
      else
        m.file full, File.join(dest, rel)
      end
    end
  end

end
