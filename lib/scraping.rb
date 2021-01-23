class Scraping
  attr_reader :driver, :wait, :is_next_page, :current_loop_times, :max_loop_times, :url

  def initialize(args={})
    @driver = Selenium::WebDriver.for :chrome
    Selenium::WebDriver.logger.output    = File.join("#{Rails.root}/log/", "selenium.log")
    Selenium::WebDriver.logger.level     = :warn
    driver.manage.timeouts.implicit_wait = args[:wait_time] || default_wait_time
    timeout                              = args[:time_out]  || default_time_out
    @wait                                = Selenium::WebDriver::Wait.new(timeout: timeout)
    # ここまでseleniumの初期化
    @current_loop_times = 0
    @max_loop_times     = args[:max_loop_times] || default_max_loop_times
    @url                = args[:url]            || default_url
  end

  def execute
    data_hash_lists = []
    driver.get(url)
    begin
      while (true)
        data_hash_lists += scrape
        parse_next_link.click
        avoid_infinite_loop
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
    # このエラーが出れば成功
      selenium_warn_log("スクレイピング成功")
    rescue => error
      selenium_warn_log(error)
    end
    driver.quit
    return data_hash_lists
  end

  private

  def default_url
    "https://atcoder.jp/contests/archive?ratedType=1&category=0&keyword="
  end

  def scrape
    wait.until { driver.find_element(:xpath, "//*[@id='main-container']/div[1]/div[3]/div[2]/div/table/tbody/tr").displayed? }
    documents = driver.find_elements(:xpath, "//*[@id='main-container']/div[1]/div[3]/div[2]/div/table/tbody/tr")
    return parse_node(documents)
  end
  
  def parse_node(documents)
    documents.map{|node| optimize_to_hash(node)}
  end

  def optimize_to_hash(node)
    {
      name: node.find_element(:xpath, "./td[2]/a").text,
      url:  node.find_element(:xpath, "./td[2]/a").attribute('href')
    }
  end

  def parse_next_link
    case current_loop_times
    when 0 then
      driver.find_element(:xpath, "//*[@id='main-container']/div[1]/div[3]/div[1]/ul/li[2]/a")
    when 1 then
      driver.find_element(:xpath, "//*[@id='main-container']/div[1]/div[3]/div[1]/ul/li[3]/a") 
    when 2 then
      driver.find_element(:xpath, "//*[@id='main-container']/div[1]/div[3]/div[1]/ul/li[4]/a")
    else
      nil
    end
  end

  def default_wait_time
    3
  end

  def default_time_out
    6
  end
  
  def default_max_loop_times
    20
  end

  def avoid_infinite_loop
    @current_loop_times += 1
    if current_loop_times >= max_loop_times
      selenium_warn_log('無限ループ')
      exit
    end
  end

  def selenium_warn_log(error)
    Selenium::WebDriver.logger.warn(error)
  end
end