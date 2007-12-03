module Hobo
  
  module Dryml
    
    # Raised when the part context fails its integrity check.
    class PartContext
      
      class TamperedWithPartContext < StandardError; end
    
      class Id < String; end
      
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
      
      
      def initialize(part_name, this_id, locals)
        @part_name = part_name
        @this_id = this_id
        @locals = locals.map { |l| pre_marshal(l) }
      end
      
      
      def pre_marshal(x)
        if x.is_a?(ActiveRecord::Base) && x.respond_to?(:typed_id)
          Id.new(x.typed_id)
        else
          x
        end
      end
      
      
      def marshal(session)
        context = [@part_name, @this_id, @locals]
        data = Base64.encode64(Marshal.dump(context)).strip
        digest = self.class.generate_digest(data, session)
        "#{data}--#{digest}"
      end
        

      class << self
        
        # Generate the HMAC keyed message digest. Uses SHA1 by default.
        def generate_digest(data, session)
          secret = self.secret || ActionController::Base.cached_session_options.first[:secret]
          key = secret.respond_to?(:call) ? secret.call(session) : secret
          OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new(digest), key, data)
        end
        
        
        # Unmarshal part context to a hash and verify its integrity.
        def unmarshal(client_store, this, session)
          data, digest = CGI.unescape(client_store).strip.split('--')

          raise TamperedWithPartContext unless digest == generate_digest(data, session)

          part_name, this_id, locals = Marshal.load(Base64.decode64(data))
          RAILS_DEFAULT_LOGGER.info("Call part: #{part_name}. this-id = #{this_id}, locals = #{locals.inspect}")

          [part_name, restore_part_this(this_id, this), restore_locals(locals)]
        end
      
        def restore_part_this(this_id, this)
          if this_id == "this" or this_id.blank?
            this
          elsif this_id == "nil"
            nil
          else
            Hobo.object_from_dom_id(this_id)
          end          
        end
        
        
        def restore_locals(locals)
          locals.map do |l|
            if l.is_a?(Id)
              Hobo.object_from_dom_id(l)
            else
              l
            end
          end
        end
        
      end
      
    end
    
  end 
  
end
