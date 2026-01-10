// services/authService.js
import axios from '../api/axios';

export const authService = {
  // Login admin
  async login(email, password) {
    const response = await axios.post('/login/', {
      identifier: email,  // Support email or phone
      password: password,
    });

    if (response.data.token) {
      localStorage.setItem('admin_token', response.data.token);
    }

    return response.data;
  },

  // Logout
  logout() {
    localStorage.removeItem('admin_token');
  },

  // Check if user is authenticated
  isAuthenticated() {
    return !!localStorage.getItem('admin_token');
  },

  // Get stored token
  getToken() {
    return localStorage.getItem('admin_token');
  },
};
