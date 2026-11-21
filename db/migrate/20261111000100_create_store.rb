class CreateStore < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :admin, null: false, default: false
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps
    end
    add_index :categories, :slug, unique: true

    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false
      t.integer :price_cents, null: false
      t.integer :stock, null: false, default: 0
      t.string :image_name, null: false, default: "serum"
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :products, [:active, :category_id]

    create_table :reviews do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :body, null: false
      t.timestamps
    end
    add_index :reviews, [:user_id, :product_id], unique: true

    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :customer_name, null: false
      t.string :phone, null: false
      t.string :city, null: false
      t.string :address, null: false
      t.string :shipping_method, null: false
      t.string :payment_method, null: false
      t.string :status, null: false, default: "placed"
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :shipping_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :product_name, null: false
      t.integer :quantity, null: false
      t.integer :price_cents, null: false
      t.timestamps
    end

    create_table :contact_messages do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :subject, null: false
      t.text :message, null: false
      t.timestamps
    end
  end
end
