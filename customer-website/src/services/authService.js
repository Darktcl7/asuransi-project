// services/authService.js
import axios from '../api/axios';

export const authService = {
    // Login user
    async login(identifier, password) {
        const response = await axios.post('/login/', {
            identifier: identifier,  // Support email or phone
            password: password,
        });

        if (response.data.token) {
            localStorage.setItem('user_token', response.data.token);
            localStorage.setItem('user_data', JSON.stringify(response.data.user));
        }

        return response.data;
    },

    // Register user
    async register(data) {
        // Split full_name into first_name and last_name
        const nameParts = data.full_name.trim().split(' ');
        const firstName = nameParts[0] || '';
        const lastName = nameParts.slice(1).join(' ') || '';

        const response = await axios.post('/users/register/', {
            email: data.email,
            password: data.password,
            password_confirm: data.password,
            first_name: firstName,
            last_name: lastName,
            phone_number: data.phone_number,
            store_code: data.store_code,
        });
        return response.data;
    },

    // Logout
    logout() {
        localStorage.removeItem('user_token');
        localStorage.removeItem('user_data');
    },

    // Check if user is authenticated
    isAuthenticated() {
        return !!localStorage.getItem('user_token');
    },

    // Get stored token
    getToken() {
        return localStorage.getItem('user_token');
    },

    // Get user data
    getUserData() {
        const data = localStorage.getItem('user_data');
        return data ? JSON.parse(data) : null;
    },
};
