// App.jsx
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { authService } from './services/authService';
import { ToastProvider } from './components/Toast';

import LoginPage from './pages/LoginPage';
import DashboardLayout from './layout/DashboardLayout';
import DashboardHome from './pages/DashboardHome';
import UsersPage from './pages/UsersPage';
import ClaimsPage from './pages/ClaimsPage';
import PoliciesPage from './pages/PoliciesPage';
import DevicesPage from './pages/DevicesPage';
// import WalletsPage from './pages/WalletsPage'; // ❌ REMOVED - Policy balance system
// import TopUpsPage from './pages/TopUpsPage'; // ❌ REMOVED - Policy balance system
// import ManualTopUpPage from './pages/ManualTopUpPage'; // ❌ REMOVED - Policy balance system
import ManualPolicyCreatePage from './pages/ManualPolicyCreatePage';
import AdminClaimCreatePage from './pages/AdminClaimCreatePage';

// Create QueryClient for React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
      staleTime: 30000, // 30 seconds
    },
  },
});

// Protected Route Component
const ProtectedRoute = ({ children }) => {
  return authService.isAuthenticated() ? children : <Navigate to="/login" />;
};

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ToastProvider>
        <BrowserRouter basename="/admin_store">
          <Routes>
            {/* Login Route */}
            <Route path="/login" element={<LoginPage />} />

            {/* Dashboard Routes */}
            <Route
              path="/"
              element={
                <ProtectedRoute>
                  <DashboardLayout />
                </ProtectedRoute>
              }
            >
              <Route index element={<DashboardHome />} />
              <Route path="users" element={<UsersPage />} />
              <Route path="claims" element={<ClaimsPage />} />
              <Route path="policies" element={<PoliciesPage />} />
              <Route path="devices" element={<DevicesPage />} />
              {/* ❌ REMOVED - Policy balance system now used */}
              {/* <Route path="wallets" element={<WalletsPage />} /> */}
              {/* <Route path="topups" element={<TopUpsPage />} /> */}
              {/* <Route path="manual-topup" element={<ManualTopUpPage />} /> */}
              <Route path="manual-policy-create" element={<ManualPolicyCreatePage />} />
              <Route path="admin-claim-create" element={<AdminClaimCreatePage />} />
            </Route>

            {/* Default Redirect */}
            <Route path="*" element={<Navigate to="/" />} />
          </Routes>
        </BrowserRouter>
      </ToastProvider>
    </QueryClientProvider>
  );
}

export default App;
