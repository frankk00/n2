class ViewTree
  include Enumerable
  extend Forwardable

  def_delegators :@children, :<<, :[], :[]=, :last, :first, :push

  def initialize key_name, controller
    @key_name = key_name
    @output = self.get
    @view_object = nil
    @children = []
    @controller = controller
    @cache = false
    # Initialize new view tree
    # add children view tree elements for each view object
    # build up render dependency tree
    # add enumerable methods
  end

  def get
    return nil unless @cache
    $redis.get("view-tree:#{@key_name}")
  end

  def each
    @children.each {|child| yield child }
  end
    
  def fetch
    unless @output
      self.load
    end
  end

  def translate locale_key, options = {}
    I18n.translate(locale_key, options)
  end
  alias_method :t, :translate

  def load
    @view_object = ViewObject.load(@key_name)
    unless @view_object
      @output = ''
      return true
    end

    if not Rails.env.development? and @view_object.setting
    	#@cache = @view_object.setting.cache_enabled
    end
    @children = @view_object.edge_children.map {|c| ViewTree.new c.name, @controller }
    @output = []
    unless @view_object.parent.nil? and @view_object.view_object_template.nil?
      @output << %{<div class="box">#{@controller.send(:render_to_string, :partial => "#{@view_object.view_object_template.template}.html", :locals => { :vt => self, :vo => @view_object })}</div>}
    end
    each do |child|
      @output << child.render
    end
    @output = @output.flatten.join('')
    $redis.set("view-tree:#{@key_name}", @output)
  end

  def render
    return @output if @output

    self.fetch

    return @output
  end

	#
	# Class Methods
	#
  def self.render target, controller = nil
    if target.class.name =~ /Controller$/
    	view_object_name = "#{target.controller_name}--#{target.action_name}"
    	controller = target
    else
    	view_object_name = target
    end
    self.fetch view_object_name, controller
  end

  def self.fetch key_name, controller
    view_tree = ViewTree.new key_name, controller
    return view_tree.render
  end

end