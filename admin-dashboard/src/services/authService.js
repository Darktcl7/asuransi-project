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

      // Store user info including role
      if (response.data.user) {
        localStorage.setItem('admin_user', JSON.stringify(response.data.user));
      }
    }

    return response.data;
  },

  // Logout
  logout() {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_user');
  },

  // Check if user is authenticated
  isAuthenticated() {
    return !!localStorage.getItem('admin_token');
  },

  // Get stored token
  getToken() {
    return localStorage.getItem('admin_token');
  },

  // Get stored user info
  getUser() {
    const userStr = localStorage.getItem('admin_user');
    if (userStr) {
      try {
        return JSON.parse(userStr);
      } catch {
        return null;
      }
    }
    return null;
  },

  // Get user role
  getRole() {
    const user = this.getUser();
    return user?.role || 'store_admin'; // Default to store_admin for backward compatibility
  },

  // Check if user is Super Admin
  isSuperAdmin() {
    return this.getRole() === 'super_admin';
  },

  // Check if user is Store Admin
  isStoreAdmin() {
    return this.getRole() === 'store_admin';
  },

  // Check if user can manage stores (Super Admin only)
  canManageStores() {
    return this.isSuperAdmin();
  },

  // Check if user can manage devices (Super Admin only)
  canManageDevices() {
    return this.isSuperAdmin();
  },

  // Check if user can manage policy tiers (Super Admin only)
  canManagePolicyTiers() {
    return this.isSuperAdmin();
  },

  // Get user's store info
  getStore() {
    const user = this.getUser();
    return user?.store || null;
  },
};

