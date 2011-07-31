class Proton
  # Module: Cache
  module Cacheable
    def self.enable!
      @enabled = true
    end

    def self.disable!
      @enabled = false
    end

    def self.enabled?()
      !! @enabled
    end
    
    # Enable by default
    enable!

    def self.cache(*args)
      if enabled?
        @cache ||= Hash.new
        args   = args.map { |s| s.to_s }.join('-')
        @cache[args] ||= yield
      else
        yield
      end
    end

    def cache_method(*methods)
      methods.each do |method|
        alias_method :"real_#{method}", method

        class_eval do
          define_method(method) { |*args|
            Cacheable.cache self.class, method, self.path do
              send :"real_#{method}", *args
            end
          }
        end
      end
    end
  end
end
