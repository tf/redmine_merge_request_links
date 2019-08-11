class TokenController < ApplicationController
  helper_method :get_token
  before_action :find_project, :load_token

  def index
    @providers = [
        :github,
        :gitlab,
        :gitea
    ]
  end

  def view
    @editing = @token != nil
    if @editing == false
      @action = 'create_post'
      @token = ProjectsMergeRequestToken.new(:provider => @provider, :project => @project)
    else
      @action = 'edit_post'
    end
  end

  def create_post
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

  def edit_post
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
    @token = get_token(@provider)
  end
end