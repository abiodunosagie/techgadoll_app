import 'package:techgadoll_app/features/products/data/models/product_model.dart';

const validProductJson = {
  'id': 1,
  'title': 'iPhone 15 Pro',
  'description': 'Latest Apple smartphone',
  'category': 'smartphones',
  'price': 1499.99,
  'discountPercentage': 12.5,
  'rating': 4.7,
  'stock': 25,
  'brand': 'Apple',
  'thumbnail': 'https://cdn.dummyjson.com/products/images/1/thumbnail.jpg',
  'images': [
    'https://cdn.dummyjson.com/products/images/1/1.jpg',
    'https://cdn.dummyjson.com/products/images/1/2.jpg',
  ],
  'availabilityStatus': 'In Stock',
};

const missingFieldsProductJson = {
  'id': 2,
  'title': null,
  'description': null,
  'category': null,
  'price': null,
  'discountPercentage': null,
  'rating': null,
  'stock': null,
  'brand': null,
  'thumbnail': null,
  'images': null,
  'availabilityStatus': null,
};

const negativePriceProductJson = {
  'id': 3,
  'title': 'Bad Product',
  'description': 'Has a negative price',
  'category': 'test',
  'price': -50.0,
  'discountPercentage': 0,
  'rating': 3.0,
  'stock': 10,
  'brand': 'TestBrand',
  'thumbnail': 'https://example.com/img.jpg',
  'images': [],
  'availabilityStatus': 'In Stock',
};

const invalidImagesProductJson = {
  'id': 4,
  'title': 'Image Test',
  'description': 'Has invalid image URLs',
  'category': 'test',
  'price': 29.99,
  'discountPercentage': 0,
  'rating': 2.5,
  'stock': 5,
  'brand': 'TestBrand',
  'thumbnail': 'not-a-url',
  'images': ['https://valid.com/img.jpg', 'invalid-url', '', 'https://also-valid.com/img.jpg'],
  'availabilityStatus': 'In Stock',
};

const validProductsResponseJson = {
  'products': [validProductJson],
  'total': 100,
  'skip': 0,
  'limit': 20,
};

const emptyProductsResponseJson = {
  'products': [],
  'total': 0,
  'skip': 0,
  'limit': 20,
};

const validCategoryJson = {
  'slug': 'smartphones',
  'name': 'Smartphones',
  'url': 'https://dummyjson.com/products/category/smartphones',
};

const sampleProduct = ProductModel(
  id: 1,
  title: 'iPhone 15 Pro',
  description: 'Latest Apple smartphone',
  category: 'smartphones',
  price: 1499.99,
  discountPercentage: 12.5,
  rating: 4.7,
  stock: 25,
  brand: 'Apple',
  thumbnail: 'https://cdn.dummyjson.com/products/images/1/thumbnail.jpg',
  images: [
    'https://cdn.dummyjson.com/products/images/1/1.jpg',
    'https://cdn.dummyjson.com/products/images/1/2.jpg',
  ],
  availabilityStatus: 'In Stock',
);

const sampleProductNullPrice = ProductModel(
  id: 2,
  title: 'Untitled Product',
  description: '',
  category: '',
  price: null,
  discountPercentage: 0,
  rating: 0,
  stock: 0,
  brand: null,
  thumbnail: null,
  images: [],
  availabilityStatus: 'Unknown',
);
