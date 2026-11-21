#!/usr/bin/env ruby
# Завантажує справжні фотографії косметичних засобів у локальні ресурси Rails.
# Повторний запуск пропускає вже завантажені файли.
require "json"
require "net/http"
require "uri"
require "fileutils"

root = File.expand_path("..", __dir__)
photos = JSON.parse(File.read(File.join(root, "config", "product_photos.json")))
dir = File.join(root, "app", "assets", "images", "products", "photos")
FileUtils.mkdir_p(dir)
failed = []
photos.each do |key, details|
  target = File.join(dir, "#{key}.jpg")
  if File.file?(target) && File.size(target) > 10_000
    puts "✓ Уже є: #{key}"
    next
  end
  id = details.fetch("photo_id")
  url = URI("https://images.pexels.com/photos/#{id}/pexels-photo-#{id}.jpeg?auto=compress&cs=tinysrgb&w=900")
  begin
    response = Net::HTTP.start(url.host, url.port, use_ssl: true, open_timeout: 20, read_timeout: 50) do |http|
      http.get(url.request_uri, { "User-Agent" => "Stargazing course project/1.0" })
    end
    raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
    raise "Відповідь не містить зображення" unless response["content-type"].to_s.start_with?("image/")
    File.binwrite(target, response.body)
    puts "✓ Завантажено: #{key} (#{File.size(target)} байт)"
  rescue StandardError => e
    File.delete(target) if File.exist?(target) && File.size(target) < 10_000
    failed << "#{key}: #{e.message}"
    warn "✗ #{key}: #{e.message}"
  end
end
puts "Готово! Завантажено або знайдено #{photos.size - failed.size}/#{photos.size} фото."
warn "Не вдалося: #{failed.join('; ')}" if failed.any?
exit(failed.empty? ? 0 : 1)
