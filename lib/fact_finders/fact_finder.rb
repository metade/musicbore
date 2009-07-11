class Fact
  attr_accessor :subject
  
  def to_s
    
  end
end

class FactFinder
  
  def name
  end
  
  def gender
  end
  
  def group?
  end
  
  def statements
    list = list_statements
    list[0] = "#{name} #{list[0]}"
    list[1,].each do |s|
      "They #{s}"
    end
    list
  end
  
  protected
  
  def tidy_url(url)
    return nil if url.nil?
    url_s = url.uri.to_s 
    url_s = $1 if url_s =~ %r[http://www.(.*)]
    url_s
  end
end
