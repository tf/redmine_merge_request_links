class TokenController < ApplicationController
  helper_method :get_token
  before_action :find_project
  before_action :load_token, except: [:index]

  def index
    @providers = RedmineMergeRequestLinks.providers
  end

  def view
    @editing = @token != nil
    if @editing == false
      @action = 'create'
      @token = ProjectsMergeRequestToken.new(:provider => @provider, :project => @project)
    else
      @action = 'edit'
    end
  end

  def create
    if @token != nil
      flash[:error] = 'Token for this provider already exists.'
      redirect_to :action => 'index'
    end

    ProjectsMergeRequestToken.create(
        :token => params[:projects_merge_request_token][:token],
        :subprojects => params[:projects_merge_request_token][:subprojects],
        :provider => @provider,
        :project => @project
    )

    flash[:notice] = "Token created."
    redirect_to :action => 'index'
  end

  def edit
    if @token == nil
      flash[:error] = 'Token for this provider does not exists.'
      redirect_to :action => 'index'
    end
    @token[:token] = params[:projects_merge_request_token][:token]
    @token[:subprojects] = params[:projects_merge_request_token][:subprojects]
    @token.save
    flash[:notice] = "Token saved."
    redirect_to :action => 'index'
  end

  def delete
    if @token == nil
      flash[:error] = 'Token for this provider does not exists.'
      redirect_to :action => 'index'
    end
    @token.delete
    flash[:notice] = "Token for provider #{@token.provider} deleted."
    redirect_to :action => 'index'
  end

  def get_token(provider)
    ProjectsMergeRequestToken.find_by :project => @project, :provider => provider
  end

  protected

  def load_token
    @provider = params[:provider]
    unless RedmineMergeRequestLinks::providers.include?(@provider.to_sym)
      return head :bad_request
    end
    @token = get_token(@provider)
  end
end