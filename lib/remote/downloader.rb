class Remote::Downloader
  def fetch(provider)
    headless = nil
    if Rails.env.production?
      headless = Headless.new
      headless.start
    end

    result = provider.fetch

    if Rails.env.production?
      headless.destroy
    end

    result
  end
end