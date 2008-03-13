require 'csv'

module HoboCsv
  
  def render_csv(*args)
    options = args.extract_options!
    fields = args.empty? ? @member_class.content_columns.*.name : args
    
    filename = (options[:filename] || params[:action]) +".csv"    
    
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

    response_proc = proc do |response, output|
      CSV::Writer.generate(output, ',') do |csv|
        if block_given?
          yield(csv)
        else
          # Generate and write out titles
          titles = fields.map do |field|
            if field.is_a?(String)
              field.split('.').map(&its.titleize).join(' ')
            else
              field.to_s.titleize
            end
          end.flatten
          csv << titles
          
          @this.each do |record|
            # Generate and write out one row
            values = fields.map do |field| 
              if field.is_a?(String)
                field.split('.').inject(record) {|r,f|r.send(f)}
              else
                record.send(field)
              end
            end.flatten
            csv << values
          end
        end
      end
    end
    render :text => response_proc
  end
  
end

::Hobo::ModelController.send(:include, HoboCsv)
