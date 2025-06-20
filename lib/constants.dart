// Base URLs
const bool isProduction = false; // Ganti ke true untuk production

// API Configuration
const String localBaseUrl = 'http://127.0.0.1:8000/api';
const String productionBaseUrl = 'http://192.168.45.72:8000/api';

// Image URLs
const String localGambarUrl = 'http://127.0.0.1:8000';
const String productionGambarUrl = 'http://192.168.45.72:8000';

// Export based on environment
const String baseUrl = isProduction ? productionBaseUrl : localBaseUrl;
const String gambarUrl = isProduction ? productionGambarUrl : localGambarUrl;
