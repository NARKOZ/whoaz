class String
  unless method_defined? :ascii_only?
    def ascii_only?
      !(self =~ /[^\x00-\x7f]/)
    end
  end
end
