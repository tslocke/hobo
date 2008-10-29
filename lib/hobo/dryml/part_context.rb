module Hobo

  module Dryml

    # Raised when the part context fails its integrity check.
    class PartContext

      class TamperedWithPartContext < StandardError; end

      class TypedId < String; end

      class << self
        attr_accessor :secret, :digest
      end
      self.digest = 'SHA1'


      def self.client_side_storage(contexts, session)
        return "" if contexts.empty?

        contexts.map do |dom_id, context|
          code = context.marshal(session).split("\n").map{|line| "'#{line}\\n'"}.join(" +\n    ")
          "hoboParts['#{dom_id}'] = (#{code});\n"
        end.join
      end
      
      
      def self.pre_marshal(x)
        if x.is_a?(ActiveRecord::Base) && x.respond_to?(:typed_id)
          TypedId.new(x.typed_id)
        else
          x
        end
      end


      def self.for_call(part_name, environment, locals)
        new do |c|
          c.part_name       = part_name
          c.locals          = locals.map { |l| pre_marshal(l) }
          c.this_id         = environment.typed_id
          c.form_field_path = environment.form_field_path
        end
      end
      
      
      def self.for_refresh(encoded_context, page_this, session)
        new do |c|
          c.unmarshal(encoded_context, page_this, session)
        end
      end
      
      
      def initialize
        yield self
      end
      
      attr_accessor :part_name, :locals, :this, :this_field, :this_id, :form_field_path


      def marshal(session)
        context = [@part_name, @this_id, @locals]
        context << form_field_path if form_field_path
        data = Base64.encode64(Marshal.dump(context)).strip
        digest = generate_digest(data, session)
        "#{data}--#{digest}"
      end


      # Unmarshal part context to a hash and verify its integrity.
      def unmarshal(client_store, page_this, session)
        data, digest = CGI.unescape(client_store).strip.split('--')

        raise TamperedWithPartContext unless digest == generate_digest(data, session)

        context = Marshal.load(Base64.decode64(data))
        
        part_name, this_id, locals, form_field_path = context

        RAILS_DEFAULT_LOGGER.info "Call part: #{part_name}. this-id = #{this_id}, locals = #{locals.inspect}"
        RAILS_DEFAULT_LOGGER.info "         : form_field_path = #{form_field_path.inspect}" if form_field_path
        
        self.part_name             = part_name
        self.this_id               = this_id
        self.locals                = restore_locals(locals)
        self.form_field_path       = form_field_path
        
        parse_this_id(page_this)        
      end


      # Generate the HMAC keyed message digest. Uses SHA1 by default.
      def generate_digest(data, session)
        secret = self.class.secret || ActionController::Base.cached_session_options.first[:secret]
        key = secret.respond_to?(:call) ? secret.call(session) : secret
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new(self.class.digest), key, data)
      end



      def parse_this_id(page_this)
        if this_id == "this"
          self.this = page_this
        elsif this_id =~ /^this:(.*)/
          self.this = page_this
          self.this_field = $1
        elsif this_id == "nil"
          nil
        else
          parts = this_id.split(':')
          if parts.length == 3
            self.this       = Hobo::Model.find_by_typed_id("#{parts[0]}:#{parts[1]}")
            self.this_field = parts[2]
          else
            self.this = Hobo::Model.find_by_typed_id(this_id)
          end
        end
      end


      def restore_locals(locals)
        locals.map do |l|
          if l.is_a?(TypedId)
            Hobo::Model.find_by_typed_id(this_id)
          else
            l
          end
        end
      end

    end

  end

end
