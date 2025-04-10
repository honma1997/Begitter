class Public::PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]
  
  # 投稿一覧
  def index
    @posts = Post.includes(:user, :tags).order(created_at: :desc).page(params[:page]).per(10)
  end

  # 投稿詳細
  def show
    @comment = Comment.new
  end

  # 新規投稿フォーム
  def new
    @post = Post.new
    @tags = Tag.all
  end

  # 投稿作成処理
  def create
    @post = current_user.posts.new(post_params)
    
    if @post.save
      # タグの関連付け
      save_tags if params[:post][:tag_ids].present?
      
      redirect_to post_path(@post), notice: "投稿が完了しました"
    else
      @tags = Tag.all
      render :new
    end
  end

  # 投稿編集フォーム
  def edit
    @tags = Tag.all
    @selected_tag_ids = @post.tags.pluck(:id)
  end

  # 投稿更新処理
  def update
    if @post.update(post_params)
      # 既存のタグをすべて削除
      @post.post_tags.destroy_all
      
      # タグの関連付けを更新
      save_tags if params[:post][:tag_ids].present?
      
      redirect_to post_path(@post), notice: "投稿を更新しました"
    else
      @tags = Tag.all
      @selected_tag_ids = params[:post][:tag_ids] || []
      render :edit
    end
  end

  # 投稿削除処理
  def destroy
    if @post.destroy
      redirect_to posts_path, notice: "投稿を削除しました"
    else
      flash[:alert] = "投稿の削除に失敗しました"
      redirect_to post_path(@post)
    end
  end

  
  private
  
  # 投稿を取得するメソッド
  def set_post
    @post = Post.find_by(id: params[:id])
    unless @post
      redirect_to posts_path, alert: "その投稿はすでに削除されています。"
    end
  end

  # 投稿者本人かチェックするメソッド
  def ensure_correct_user
    unless @post.user == current_user
      redirect_to posts_path, alert: "他のユーザーの投稿は編集・削除できません"
    end
  end
  
  # ストロングパラメータ
  def post_params
    params.require(:post).permit(:title, :body, :image, tag_ids: [])
  end
  
  # タグを保存するメソッド
  def save_tags
    # ブランクでないタグIDを取得
    valid_tag_ids = params[:post][:tag_ids].reject(&:blank?)
    
    # タグがあれば処理
    return if valid_tag_ids.empty?
    
    # タグを関連付け
    valid_tag_ids.each do |tag_id|
      @post.post_tags.create(tag_id: tag_id)
    end
  end
end