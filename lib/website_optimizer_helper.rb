module WebsiteOptimizerHelper

  mattr_accessor :account_id

  def gwo_multivariate(tracker_id, description, &block)
    require_account_id
    multivariate_controll_script(tracker_id)
    multivariate_tracking_script(tracker_id)
    multivariate_section_script(description, &block)
  end

  # Control/Tracking Script for A/B control page
  #
  def gwo_ab_control(tracker_id)
    require_account_id
    ab_controll_script(tracker_id)
    ab_tracking_script(tracker_id)
  end

  # Tracking Script for A/B variation pages
  #
  def gwo_ab_variation(tracker_id)
    require_account_id
    ab_tracking_script(tracker_id)
  end

  # Conversion Script: Will be included at the end of the conversion
  # page's source code
  #
  def gwo_conversion_script(tracker_id)
    require_account_id
    google_analytics_tracking_script(tracker_id, "/#{tracker_id}/goal")
  end


  private


  def require_account_id
    raise "You must set a Google Website Optimizer Account ID" if WebsiteOptimizerHelper.account_id.blank?
  end

  def multivariate_section_script(description, &block)
    if block_given?
      content = capture(&block)
      concat(content_tag('script', "utmx_section(\"#{description}\")", :type => 'text/javascript'), block.binding)
      concat(content, block.binding)
      concat("</noscript>", block.binding)
    else
      raise(ArgumentError, "No block provided")
    end
  end

  def multivariate_tracking_script(tracker_id)
    google_analytics_tracking_script(tracker_id, "/#{tracker_id}/test")
  end

  def multivariate_controll_script(tracker_id)
    content_for(:head) { content_tag('script', "function utmx_section(){}function utmx(){}(function(){var k='#{tracker_id}',d=document,l=d.location,c=d.cookie;function f(n){if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return c.substring(i+n.length+1,j<0?c.length:j)}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;d.write('<sc'+'ript src=\"'+'http'+(l.protocol=='https:'?'s://ssl':'://www')+'.google-analytics.com'+'/siteopt.js?v=1&utmxkey='+k+'&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='+new Date().valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+'\" type=\"text/javascript\" charset=\"utf-8\"></sc'+'ript>')})();", :type => 'text/javascript') }
  end

  def ab_controll_script(tracker_id)
    multivariate_controll_script(tracker_id)
    content_for(:head) { content_tag('script', "utmx(\"url\",'A/B');", :type => 'text/javascript') }
  end

  def ab_tracking_script(tracker_id)
    google_analytics_tracking_script(tracker_id, "/#{tracker_id}/test")
  end

  # For Local Validation Only
  #
  def google_analytics_include
    "<script type=\"text/javascript\">
    if(typeof(_gat)!='object')document.write('<sc'+'ript src=\"http'+
    (document.location.protocol=='https:'?'s://ssl':'://www')+
    '.google-analytics.com/ga.js\"></sc'+'ript>')</script>
    "
  end
  
  def google_analytics_tracking_script(tracker_id, tracker)
    tracker_name = RAILS_ENV == 'development' ? 'pageTracker' : 'websiteOptimizerTracker' + tracker_id
    content_for(:website_optimizer_tracking) { google_analytics_include } if RAILS_ENV == 'development'
    content  = "try {"
    content << "var #{tracker_name}=_gat._getTracker(\"#{account_id}\");"
    content << "#{tracker_name}._trackPageview(\"#{tracker}\");"
    content << "}catch(err){}"
    content_for(:website_optimizer_tracking) { content_tag('script', content, :type => "text/javascript") }
  end

end
