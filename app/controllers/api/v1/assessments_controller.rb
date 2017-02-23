class Api::V1::AssessmentsController < Api::V1::BaseApiController

  before_action :set_assessment, except: [:index]

  def index
    asmts = @course.assessments.ordered
    allowed = [:name, :display_name, :description, :start_at, :due_at, :end_at, :updated_at, :max_grace_days, :handout, :writeup, :max_submissions, :disable_handins, :category_name, :group_size, :has_scoreboard, :has_autograder]
    if @cud.student?
      asmts = asmts.released
    else
      allowed += [:visible_at, :grading_deadline]
    end

    results = []
    asmts.each do |asmt|
      result = asmt.attributes.symbolize_keys
      result.merge!(:has_scoreboard => asmt.has_scoreboard?)
      result.merge!(:has_autograder => asmt.has_autograder?)
      results << result
    end

    respond_with results, only: allowed
  end

  # endpoint for obtaining details about all problems of an assessment
  def problems
    problems = @assessment.problems

    respond_with problems, only: [:name, :description, :max_score, :optional]
  end

end