module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Spliddit"
    if page_title.empty?
      base_title
    else
      "#{page_title} - #{base_title}"
    end
  end

  def full_description(description)
    if description.empty?
      "Fair division calculators to share rent and assign rooms when moving into an apartment with roommates, divide goods and assets in inheritance and divorce cases, and assign credit for a project or research paper."
    else
      description
    end
  end

  def include_javascript(file)
    s = "<script type=\"text/javascript\">" + render(:file => Rails.root.join('app/views/javascripts/'+file+'.erb'), :formats => :js) + "</script>"
    content_for(:scripts, raw(s))
  end
end