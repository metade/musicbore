class Array
  def rand
    self[Kernel.rand(self.size)]
  end
end
