// services/storeService.js
/**
 * Store Management Service - For Super Admin
 */
import axios from '../api/axios';

export const storeService = {
    // Get all stores
    async getStores(params = {}) {
        const response = await axios.get('/admin/stores/', { params });
        return response.data;
    },

    // Get single store
    async getStore(id) {
        const response = await axios.get(`/admin/stores/${id}/`);
        return response.data;
    },

    // Create new store
    async createStore(data) {
        const response = await axios.post('/admin/stores/', data);
        return response.data;
    },

    // Update store
    async updateStore(id, data) {
        const response = await axios.put(`/admin/stores/${id}/`, data);
        return response.data;
    },

    // Delete (deactivate) or destroy (permanent) store
    // Delete (deactivate) or destroy (permanent) store
    async deleteStore(id, permanent = false, password = '') {
        const params = { password };
        if (permanent) params.permanent = 'true';

        const response = await axios.delete(`/admin/stores/${id}/`, { params });
        return response.data;
    },

    // Reset store data (clear customers, policies, claims)
    async resetStoreData(id, password = '') {
        const response = await axios.post(`/admin/stores/${id}/reset-data/`, { password });
        return response.data;
    },

    // Get store statistics
    async getStoreStats(id, params = {}) {
        const response = await axios.get(`/admin/stores/${id}/stats/`, { params });
        return response.data;
    },

    // Get store admins
    async getStoreAdmins(id) {
        const response = await axios.get(`/admin/stores/${id}/admins/`);
        return response.data;
    },

    // Get my store (for Store Admin)
    async getMyStore() {
        const response = await axios.get('/admin/my-store/');
        return response.data;
    },

    // Get my store stats (for Store Admin)
    async getMyStoreStats() {
        const response = await axios.get('/admin/my-store/stats/');
        return response.data;
    },
};
