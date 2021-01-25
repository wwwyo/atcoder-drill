class Cron
  attr_reader :question

  def initialize
    @question = Question.select_new_question
  end

  def drill_cron
    if question.blank?
      create_error_messages
    else 
      add_check_today_question
    end
    post_slack_bot
  end

  def post_slack_bot
    res = Net::HTTP.post_form(
      URI.parse('https://slack.com/api/chat.postMessage'),
      {
        'token': ENV['DRILL_APP_SLACK'],
        'channel': '#毎日１問',
        'text': "<!channel> おはようございます！今日も頑張りましょう！！ \n
                [難易度: abc]#{question.name} \n
                <#{question.url}>"
      }
    )
  end

  def create_error_messages
    @question.name = "問題が存在しません"
    @question.url  = ""
  end

  def add_check_today_question
    Question.add_check(question.id)
  end
end