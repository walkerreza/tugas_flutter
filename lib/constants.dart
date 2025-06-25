// Base URLs
const bool isProduction = true; // Ganti ke true untuk production

// API Configuration
const String localBaseUrl = 'http://127.0.0.1:8000/api';
const String productionBaseUrl = 'http://192.168.137.209:8000/api';

// Image URLs
const String localGambarUrl = 'http://127.0.0.1:8000/storage';
const String productionGambarUrl = 'http://192.168.137.209:8000/storage';

// Export based on environment
const String baseUrl = isProduction ? productionBaseUrl : localBaseUrl;
const String gambarUrl = isProduction ? productionGambarUrl : localGambarUrl;
