module ProductsHelper
  def product_illustration(product, class_name: "product-image", loading: "lazy")
    product_photo(product.image_name, alt: "Фотографія засобу для категорії «#{product.name}»", class_name: class_name, loading: loading)
  end

  def product_photo(key, alt:, class_name: "product-image", loading: "lazy")
    key = Product::PHOTO_INFO.key?(key.to_s) ? key.to_s : "face-serum"
    details = Product::PHOTO_INFO.fetch(key)
    local_photo = "products/photos/#{key}.jpg"
    local_file = Rails.root.join("app/assets/images", local_photo)
    image_source = if File.file?(local_file)
      local_photo
    else
      id = details.fetch("photo_id")
      "https://images.pexels.com/photos/#{id}/pexels-photo-#{id}.jpeg?auto=compress&cs=tinysrgb&w=900"
    end
    image_tag(image_source, alt: alt, class: "#{class_name} real-product-photo", loading: loading,
              decoding: "async", referrerpolicy: "no-referrer")
  end
end
