class ArticlesController < ApplicationController
  before_filter :user_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :find_article, :authorized_users_only, :only => [:edit, :update, :destroy]

  def index
    @articles = Article.includes(:author).order("id desc").page(params[:page])
    respond_to do |format|
      format.html
      format.rss { render :layout => false }
      format.json do
        json_articles = @articles.map do |article|
          {
            :title       => article.title,
            :body        => article.body,
            :author      => "#{article.author.email} (#{article.author.name})",
            :created_at  => article.created_at,
            :id          => article.id,
            :url         => article.url,
            :html        => render_to_string(:partial => 'show.html.haml',
                              :locals => {:article => article})
          }
        end

        render :json => json_articles.to_json      
      end
    end
  end

  def new
    @article = build_article
  end

  def edit
  end

  def create
    @article = build_article(params[:article])

    if @article.save
      redirect_to(root_path, :notice => 'Article was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    if @article.update_attributes(params[:article])
      redirect_to(root_path, :notice => 'Article was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @article.destroy
    redirect_to(root_path, :notice => 'Article was successfully destroyed.')
  end

  private

  def authorized_users_only
    unless @article.editable_by?(current_user)
      redirect_to root_path,
        :alert => "You are not authorized to edit other user's articles!"
    end
  end

  def build_article(attributes={})
    current_user.articles.build(attributes.merge(:created_at => Time.current))
  end

  def find_article
    @article = Article.find(params[:id])
  end
end
