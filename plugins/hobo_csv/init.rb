require 'csv'

module HoboCsv
  
  def render_csv(*args)
    options = args.extract_options!
    
    filename = (options[:filename] || @member_class.name.pluralize.underscore) +".csv"    
    
    # We have to jump through hoops to get IE to work? How surprising
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma']              = options[:pragma] || 'public'
      headers["Content-type"]        = options[:content_type] || "text/plain" 
      headers['Cache-Control']       = options[:cache_control] || 
        'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
      headers['Expires']             = options[:expires] || "0" 
    else
      headers["Content-Type"]        = options[:content_type] || 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end

    render :text => (proc do |response, output|
      CSV::Writer.generate(output, ',') do |csv|
        if block_given?
          yield(csv)
        else
          cols = args.blank? ? @member_class.content_columns.every(:name) : args
          csv << cols.map(&it.to_s.titleize)
          @this.each { |record| csv << cols.map { |col| record.send(col) } }
        end
      end
    end)
  end
  
end

::Hobo::ModelController.send(:include, HoboCsv)
