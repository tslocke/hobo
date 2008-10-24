# --- Fix pp dumps - these break sometimes without this --- #
require 'pp'
module PP::ObjectMixin

  alias_method :orig_pretty_print, :pretty_print
  def pretty_print(q)
    orig_pretty_print(q)
  rescue
    "[#PP-ERROR#]"
  end

end

