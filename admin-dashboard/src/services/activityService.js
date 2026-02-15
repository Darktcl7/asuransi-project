// services/activityService.js
/**
 * Activity Log Service - For Super Admin
 */
import axios from '../api/axios';

export const activityService = {
    // Get activity logs with filters
    async getLogs(params = {}) {
        const response = await axios.get('/admin/activity-logs/', { params });
        return response.data;
    },
};
