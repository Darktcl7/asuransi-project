// api/axios.js
import axios from 'axios';

// Base URL untuk backend Django
// Development: localhost:8000
// Production: server IP (auto-detected)
const API_BASE_URL = import.meta.env.DEV
    ? 'http://localhost:8000/api'     // Local development
    : 'http://148.230.97.130/api';    // Production server

// Create axios instance
const axiosInstance = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Request interceptor - add token to every request
axiosInstance.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('user_token');
        if (token) {
            config.headers.Authorization = `Token ${token}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

// Response interceptor - handle errors globally
axiosInstance.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            // Token invalid/expired - redirect to login
            localStorage.removeItem('user_token');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);

export default axiosInstance;
