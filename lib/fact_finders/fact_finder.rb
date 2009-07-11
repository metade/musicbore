class FactFinder
  
  def name
  end
  
  def gender
  end
  
  def group?
  end
  
  def statements
  
  
  end
  
  protected
  
  def tidy_url(url)
    url_s = url.uri.to_s 
    url_s = $1 if url_s =~ %r[http://www.(.*)]
    url_s
  end
end
