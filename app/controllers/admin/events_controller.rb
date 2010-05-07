class Admin::EventsController < AdminController

  def index
    render :partial => 'shared/admin/index_page', :layout => 'new_admin', :locals => {
    	:items => DashboardMessage.paginate(:page => params[:page], :per_page => 20, :order => "created_at desc"),
    	:model => DashboardMessage,
    	:fields => [:prefix, :title, :url, :created_at],
    	:paginate => true
    }
  end

  def new
    render :partial => 'shared/admin/new_page', :layout => 'new_admin', :locals => {
    	:model => DashboardMessage,
    	:fields => [:prefix, :title, :details, :url, :type]
    }
  end

  def edit
    @DashboardMessage = DashboardMessage.find(params[:id])
    render :partial => 'shared/admin/edit_page', :layout => 'new_admin', :locals => {
    	:item => @DashboardMessage,
    	:model => DashboardMessage,
    	:fields => [:prefix, :title, :details, :url, :type]
    }
  end

  def update
    @DashboardMessage = DashboardMessage.find(params[:id])
    if @DashboardMessage.update_attributes(params[:DashboardMessage])
      flash[:success] = "Successfully updated your DashboardMessage."
      redirect_to [:admin, @DashboardMessage]
    else
      flash[:error] = "Could not update your DashboardMessage as requested. Please try again."
      render :edit
    end
  end

  def show
    render :partial => 'shared/admin/show_page', :layout => 'new_admin', :locals => {
    	:item => DashboardMessage.find(params[:id]),
    	:model => DashboardMessage,
    	:fields => [:prefix, :title, :details, :url, :type,:created_at]
    }
  end

  def create
    @DashboardMessage = DashboardMessage.new(params[:DashboardMessage])
    if @DashboardMessage.save
      flash[:success] = "Successfully created your new DashboardMessage!"
      redirect_to [:admin, @DashboardMessage]
    else
      flash[:error] = "Could not create your DashboardMessage, please try again"
      render :new
    end
  end

  def destroy
    @DashboardMessage = DashboardMessage.find(params[:id])
    @DashboardMessage.destroy

    redirect_to admin_DashboardMessages_path
  end

  private

  def set_current_tab
    @current_tab = 'events';
  end

end
