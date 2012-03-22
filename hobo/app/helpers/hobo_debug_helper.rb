module HoboDebugHelper
  extend HoboHelperBase
  protected
    def abort_with(*args)
      raise args.*.pretty_inspect.join("-------\n")
    end

    def log_debug(*args)
      return if not logger
      logger.debug("\n### DRYML Debug ###")
      logger.debug(args.*.pretty_inspect.join("-------\n"))
      logger.debug("DRYML THIS = #{this.typed_id rescue this.inspect}")
      logger.debug("###################\n")
      args.first unless args.empty?
    end
end
