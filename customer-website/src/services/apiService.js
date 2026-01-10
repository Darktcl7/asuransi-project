// services/apiService.js
import axios from '../api/axios';

export const apiService = {
    // ===== USER PROFILE =====
    async getUserProfile() {
        const response = await axios.get('/users/me/');
        return response.data;
    },

    async updateProfile(data) {
        const response = await axios.patch('/users/me/', data);
        return response.data;
    },

    // ===== POLICIES =====
    async getPolicies() {
        const response = await axios.get('/policies/');
        return response.data;
    },

    async getPolicyDetail(id) {
        const response = await axios.get(`/policies/${id}/`);
        return response.data;
    },

    // ===== CLAIMS =====
    async getClaims() {
        const response = await axios.get('/claims/');
        return response.data;
    },

    async submitClaim(formData) {
        const response = await axios.post('/claims/', formData, {
            headers: {
                'Content-Type': 'multipart/form-data',
            },
        });
        return response.data;
    },

    async getClaimDetail(id) {
        const response = await axios.get(`/claims/${id}/`);
        return response.data;
    },

    // ===== NOTIFICATIONS =====
    async getNotifications() {
        const response = await axios.get('/notifications/');
        return response.data;
    },

    async markNotificationAsRead(id) {
        const response = await axios.patch(`/notifications/${id}/`, { is_read: true });
        return response.data;
    },

    async markAllNotificationsAsRead() {
        const response = await axios.post('/notifications/mark-all-read/');
        return response.data;
    },

    async getUnreadNotificationCount() {
        const response = await axios.get('/notifications/unread-count/');
        return response.data.count || 0;
    },

    // ===== WALLET =====
    async getWalletBalance() {
        const response = await axios.get('/wallet/');
        return response.data;
    },

    // ===== DEVICES =====
    async getDevices() {
        const response = await axios.get('/devices/');
        return response.data;
    },

    // ===== POLICY TIERS =====
    async getPolicyTiers() {
        const response = await axios.get('/policy-tiers/');
        return response.data;
    },
};
