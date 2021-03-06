class IdeaSweeper < ActionController::Caching::Sweeper
  observe Idea

  def after_save(idea)
    clear_idea_cache(idea)
  end

  def after_destroy(record)
    clear_idea_cache(idea)
  end

  def clear_idea_cache(idea)
    ['top_ideas', 'newest_ideas', 'featured_ideas', "#{idea.cache_key}_who_liked" ].each do |fragment|
      expire_fragment "#{fragment}_html"
    end
    ['', 'page_1_', 'page_2_'].each do |page|
      expire_fragment "ideas_list_#{page}html"
    end
    NewscloudSweeper.expire_instance(idea)
  end

  def self.expire_idea_all idea
    controller = ActionController::Base.new
    ['top_ideas', 'newest_ideas', 'featured_ideas'].each do |fragment|
      controller.expire_fragment "#{fragment}_html"
    end
    ['', 'page_1_', 'page_2_'].each do |page|
      controller.expire_fragment "ideas_list_#{page}html"
    end
    NewscloudSweeper.expire_instance(idea)
  end

end
