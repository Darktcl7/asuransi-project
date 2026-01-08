// services/adminService.js
import axios from '../api/axios';

export const adminService = {
  // ===== DASHBOARD =====
  async getDashboardStats() {
    const response = await axios.get('/admin/dashboard/');
    return response.data;
  },

  // ===== USERS =====
  async getUsers(params = {}) {
    const response = await axios.get('/admin/users/', { params });
    return response.data;
  },

  async getUser(userId) {
    const response = await axios.get(`/admin/users/${userId}/`);
    return response.data;
  },

  async updateUser(userId, data) {
    const response = await axios.put(`/admin/users/${userId}/`, data);
    return response.data;
  },

  async exportUsers() {
    const response = await axios.get('/admin/users/export_excel/', {
      responseType: 'blob' // Important for file download
    });
    return response.data;
  },

  // ===== CLAIMS =====
  async getClaims(params = {}) {
    const response = await axios.get('/admin/claims/', { params });
    return response.data;
  },

  async getClaimNotifications() {
    const response = await axios.get('/admin/claims/notifications/');
    return response.data;
  },

  async approveClaim(claimId, data) {
    const response = await axios.post(`/admin/claims/${claimId}/approve/`, data);
    return response.data;
  },

  async rejectClaim(claimId, data) {
    const response = await axios.post(`/admin/claims/${claimId}/reject/`, data);
    return response.data;
  },

  async setClaimInProgress(claimId, data) {
    const response = await axios.post(`/admin/claims/${claimId}/set_in_progress/`, data);
    return response.data;
  },

  async setClaimCompleted(claimId, data) {
    const response = await axios.post(`/admin/claims/${claimId}/set_completed/`, data);
    return response.data;
  },

  async exportClaims() {
    const response = await axios.get('/admin/claims/export_excel/', {
      responseType: 'blob' // Important for file download
    });
    return response.data;
  },

  // ===== POLICIES =====
  async getPolicies(params = {}) {
    const response = await axios.get('/admin/policies/', { params });
    return response.data;
  },

  async exportPolicies() {
    const response = await axios.get('/admin/policies/export_excel/', {
      responseType: 'blob' // Important for file download
    });
    return response.data;
  },

  // ===== WALLETS =====
  async getWallets(params = {}) {
    const response = await axios.get('/admin/wallets/', { params });
    return response.data;
  },

  async getWalletStats() {
    const response = await axios.get('/admin/wallets/stats/');
    return response.data;
  },

  // ===== TOP-UPS =====
  async getTopUps(params = {}) {
    const response = await axios.get('/admin/topups/', { params });
    return response.data;
  },

  async approveTopUp(topupId) {
    const response = await axios.post(`/admin/topups/${topupId}/approve/`);
    return response.data;
  },

  // ===== DEVICES =====
  async getDevices(params = {}) {
    const response = await axios.get('/admin/devices/', { params });
    return response.data;
  },

  async getDeviceCategories() {
    const response = await axios.get('/admin/devices/categories/');
    return response.data;
  },

  async createDevice(data) {
    const response = await axios.post('/admin/devices/', data);
    return response.data;
  },

  async updateDevice(deviceId, data) {
    const response = await axios.put(`/admin/devices/${deviceId}/`, data);
    return response.data;
  },

  async deleteDevice(deviceId) {
    const response = await axios.delete(`/admin/devices/${deviceId}/`);
    return response.data;
  },
};
