class Course < ActiveRecord::Base
  include PublicActivity::Model
  include InitUserSubject

  QUERY = "users.id in (SELECT user_id FROM user_roles WHERE role_id = (SELECT
    id FROM roles WHERE roles.name = :role_name))"

  tracked only: [:finish_course, :start_course],
    owner: ->(controller, model) {controller.current_user}
  has_many :activities, as: :trackable, class_name: "PublicActivity::Activity", dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  validate :check_day_present, on: [:create, :update]
  validate :check_end_date, on: [:create, :update]

  has_many :course_subjects, dependent: :destroy
  has_many :user_subjects, dependent: :destroy
  has_many :user_courses, dependent: :destroy
  has_many :subjects, through: :course_subjects

  has_many :course_trainees, class_name: UserCourse.name,
                            dependent: :destroy,
                            foreign_key: :course_id,
                            inverse_of: :course
  has_many :trainees, -> {where QUERY, role_name: "trainee"}, through:
   :course_trainees, source: "user"

  has_many :course_trainers, class_name: UserCourse.name,
                            dependent: :destroy,
                            foreign_key: :course_id,
                            inverse_of: :course

  has_many :trainers, -> {where QUERY, role_name: "trainer"}, through:
   :course_trainers, source: "user"

  enum status: [:init, :progress, :finish]

  scope :recent, ->{order created_at: :desc}

  def create_user_subjects_when_start_course
    create_user_subjects user_courses, course_subjects, id, false
  end

  def create_course_owner user
    UserCourse.create course_id: id, user_id: user.id
  end

  def check_day_present
    self.errors.add :start_date, I18n.t("error.wrong_date") if
      self.start_date.to_date < Date.today
  end

  def check_end_date
    errors.add :end_date, I18n.t("error.wrong_end_date") if
      self.end_date < self.start_date
  end
end
