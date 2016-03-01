class Admin::CoursesController < ApplicationController
  load_and_authorize_resource
  before_action :load_subjects, only: [:new, :edit]

  def index
    @courses = @courses.recent
  end

  def create
    @course = Course.new course_params
    if @course.save
      @course.create_course_owner current_user
      flash[:success] = flash_message "created"
      redirect_to admin_courses_path
    else
      flash[:failed] = flash_message "not created"
      render :new
    end
  end

  def update
    if @course.update_attributes course_params
      flash[:success] = flash_message "updated"
      redirect_to admin_courses_path
    else
      flash[:failed] = flash_message "not updated"
      render :edit
    end
  end

  def show
    @subjects = @course.subjects
  end

  def update
    if @course.update_attributes course_params
      flash[:success] = flash_message "courses.updated"
      redirect_to admin_courses_path
    else
      flash[:failed] = flash_message "courses.not_updated"
      render :edit
    end
  end

  private

  def course_params
    params.require(:course).permit :name, :description, :start_date,
      :end_date, subject_ids: []
  end

  def load_subjects
    @subjects = Subject.all
  end
end
