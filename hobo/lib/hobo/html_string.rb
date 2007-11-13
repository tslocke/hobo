class Hobo::HtmlString < String
  
  COLUMN_TYPE = :text

end

Hobo.field_types[:html] = Hobo::HtmlString
