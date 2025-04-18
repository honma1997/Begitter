class User < ApplicationRecord
  # Deviseの認証機能（ログイン・登録・パスワードリセットなど）
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #=========================================================
  # 関連付け（このユーザーと関連するデータ）
  #=========================================================
  
  # プロフィール画像のアタッチメント
  has_one_attached :profile_image
  
  # ユーザーの投稿（ユーザーが削除されたら関連する投稿も削除される）
  has_many :posts, dependent: :destroy
  
  # ユーザーのコメント（ユーザーが削除されたら関連するコメントも削除される）
  has_many :comments, dependent: :destroy
  
  # ユーザーのいいね（ユーザーが削除されたら関連するいいねも削除される）
  has_many :likes, dependent: :destroy

  # フォロー関係（自分がフォローしているユーザー一覧を取得するための関連付け）
  has_many :relationships, foreign_key: :follower_id, dependent: :destroy
  has_many :followings, through: :relationships, source: :followed

  # フォロワー関係（自分をフォローしているユーザー一覧を取得するための関連付け）
  has_many :reverse_relationships, class_name: 'Relationship', foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  #=========================================================
  # バリデーション（入力データの検証ルール）
  #=========================================================
  
  # ユーザー名は必須、最大20文字まで
  validates :name, presence: true, length: { maximum: 20 }

  #=========================================================
  # 列挙型（学習フェーズの種類を定義）
  #=========================================================
  
  # 学習フェーズの定義（数値で保存されるが、シンボルで扱える）
  # 0: 基礎学習中, 1: 個人開発中, 2: 就職活動中
  enum phase: { basic_learning: 0, personal_dev: 1, job_hunting: 2 }
  
  #=========================================================
  # 追加機能（便利なメソッド）
  #=========================================================
  
  # 学習フェーズを日本語で表示するメソッド
  def phase_in_japanese
    case phase
    when 'basic_learning' then '基礎学習中'
    when 'personal_dev' then '個人開発中'
    when 'job_hunting' then '就職活動中'
    else '未設定'
    end
  end
  
  # 特定のユーザーをフォローしているかチェックするメソッド
  def following?(user)
    followings.include?(user)
  end
  
  # 特定のユーザーをフォローするメソッド
  def follow(user)
    relationships.find_or_create_by(followed_id: user.id) unless self == user
  end
  
  # 特定のユーザーのフォローを解除するメソッド
  def unfollow(user)
    relationships.find_by(followed_id: user.id)&.destroy
  end
end