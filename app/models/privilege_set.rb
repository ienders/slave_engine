class PrivilegeSet < Hash
  
  def can_access(area)
    self[:master] ? true : self["can_access_#{area}"]
  end  
  
  protected
  def method_missing(meth, *args)
    if meth.to_s =~ /^can_access_/
      return self.send(:can_access, meth.to_s.gsub(/(^can_access_|\?$)/,''))
    else
      super
    end
  end
end