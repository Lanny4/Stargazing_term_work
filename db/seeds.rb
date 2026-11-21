
# Демонстраційний каталог. Повторний запуск db:seed не створює дублікати
# й зберігає існуючі замовлення, оскільки не видаляє записи товарів.
categories = {
  "Обличчя" => "face", "Тіло" => "body", "Волосся" => "hair",
  "Макіяж" => "makeup", "Сонцезахист" => "sun", "Ритуали турботи" => "wellness"
}
categories.each do |name, slug|
  category = Category.find_or_initialize_by(slug: slug)
  category.name = name
  category.save! if category.changed?
end

# [попередня назва, українська назва, категорія, опис, ціна в копійках, залишок, код фото]
products = [
  ["Зволожувальна сироватка Glow", "Зволожувальна сироватка «Сяйво»", "face", "Легка сироватка для щоденного зволоження шкіри обличчя.", 58900, 18, "face-serum"],
  ["Крем для обличчя Soft Care", "Крем для обличчя «Ніжність»", "face", "М’який крем для щоденного догляду та відчуття комфорту.", 44900, 21, "face-cream"],
  ["Пінка для вмивання Pure Clean", "Очищувальна пінка «Чистота»", "face", "Делікатний засіб для очищення шкіри від щоденних забруднень.", 32900, 17, "face-cleanser"],
  ["Очищувальна маска Green Ritual", "Очищувальна маска «Зелений ритуал»", "face", "Кремова маска для приємного домашнього ритуалу догляду.", 39500, 16, "face-mask"],
  ["Сонцезахисний крем Sun Day SPF 50", "Сонцезахисний крем SPF 50", "sun", "Сонцезахисний косметичний засіб для щоденного використання згідно з інструкцією.", 51500, 24, "sun-spf"],
  ["Бальзам для губ Rose Bloom", "Блиск для губ Rhode", "makeup", "Косметичний засіб для губ із глянцевим фінішем. Надає блиску та доповнює повсякденний макіяж.", 19900, 32, "makeup-balm"],
  ["Помада Satin Rose", "Помада «Сатинова троянда»", "makeup", "Помада із сатиновим фінішем для повсякденного макіяжу.", 33900, 25, "makeup-lipstick"],
  ["Маска для волосся Silk Touch", "Маска для волосся «Шовковий дотик»", "hair", "Косметична маска для м’якості та легкого розчісування волосся.", 46500, 18, "hair-mask"],
  ["Шампунь Gentle Roots", "Шампунь «Дбайливе очищення»", "hair", "Делікатний шампунь для регулярного очищення волосся та шкіри голови.", 37500, 16, "hair-shampoo"],
  ["Молочко для тіла Vanilla Cloud", "Молочко для тіла «Ванільна хмаринка»", "body", "Легке молочко для зволоження шкіри тіла після душу.", 41900, 20, "body-lotion"],
  ["Скраб для тіла Cozy Peach", "Скраб для тіла «Персикова ніжність»", "body", "Косметичний скраб для догляду за тілом із приємною текстурою.", 35900, 14, "body-scrub"],
  ["Міст для обличчя Besoma", "Міст для обличчя «Besoma»", "face", "Освіжувальний косметичний спрей для відчуття комфорту протягом дня.", 26900, 19, "face-mist"],
  ["Нічний крем Moon Ritual", "Нічний крем «Місячний ритуал»", "face", "Крем для вечірнього догляду за шкірою обличчя.", 55900, 12, "night-cream"],
  ["Олійка для волосся Golden Drop", "Олійка для волосся «Золота крапля»", "hair", "Косметична олійка для догляду за довжиною волосся.", 48500, 20, "hair-oil"],
  ["Маска для обличчя Calm Mood", "Маска для обличчя «Спокій»", "face", "Кремова маска для домашнього відпочинку та догляду.", 29900, 10, "calm-mask"],
  ["Missha Perfect Cover BB", "BB-крем Missha Perfect Cover", "makeup", "BB-крем для обличчя з тонувальним покриттям. Допомагає візуально вирівняти тон шкіри під час щоденного макіяжу.", 18900, 26, "hand-cream"],
  ["Масажна олійка Lunar Calm", "Масажна олійка «Місячний спокій»", "wellness", "Косметична олійка для масажу з приємною текстурою.", 47900, 12, "massage-oil"]
]
products.each do |old_name, name, slug, description, price, stock, photo|
  category = Category.find_by!(slug: slug)
  product = Product.find_by(image_name: photo) || Product.find_by(name: name) || Product.find_by(name: old_name) || Product.new
  if product.new_record?
    product.assign_attributes(name: name, category: category, description: description,
                              price_cents: price, stock: stock, image_name: photo, active: true)
  else
    # Не змінюємо складські залишки, ціни та ідентифікатори вже існуючих товарів.
    product.assign_attributes(name: name, category: category, description: description, image_name: photo)
  end
  product.save! if product.changed?
end

# Адміністратора НЕ створюємо з публічним типовим паролем.
if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].to_s.length >= 12
  user = User.find_or_initialize_by(email: ENV.fetch("ADMIN_EMAIL").downcase)
  user.assign_attributes(name: "Адміністратор Stargazing", admin: true,
                         password: ENV.fetch("ADMIN_PASSWORD"),
                         password_confirmation: ENV.fetch("ADMIN_PASSWORD"))
  user.save!
  puts "Адміністратор готовий: #{user.email}"
else
  puts "Адміністратора не створено: задайте ADMIN_EMAIL та ADMIN_PASSWORD (мінімум 12 символів)."
end
puts "Категорій: #{Category.count}; товарів: #{Product.count}"
