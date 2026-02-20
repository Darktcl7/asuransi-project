// layout/DashboardLayout.jsx
import { useState, useEffect } from 'react';
import { Outlet, Link, useLocation, useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';
import NotificationBell from '../components/NotificationBell';

const DashboardLayout = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [userRole, setUserRole] = useState('store_admin');
  const [userInfo, setUserInfo] = useState(null);

  useEffect(() => {
    // Get user info on mount
    const user = authService.getUser();
    if (user) {
      setUserInfo(user);
      setUserRole(user.role || 'store_admin');
    }
  }, []);

  const handleLogout = () => {
    authService.logout();
    navigate('/login');
  };

  // Store Admin menu items (for managing store operations)
  const storeAdminMenuItems = [
    { path: '/', icon: '📊', label: 'Dashboard', exact: true },
    { path: '/users', icon: '👥', label: 'Users' },
    { path: '/claims', icon: '🎫', label: 'Claims' },
    { path: '/policies', icon: '📋', label: 'Policies' },
    { path: '/manual-policy-create', icon: '🛡️', label: 'Create Policy' },
    { path: '/admin-claim-create', icon: '🆘', label: 'Assist Claim' },
  ];

  // Super Admin menu items (for managing stores and global settings)
  const superAdminMenuItems = [
    { path: '/', icon: '📊', label: 'Dashboard', exact: true },
    { path: '/stores', icon: '🏪', label: 'Stores' },
    { path: '/devices', icon: '📱', label: 'Devices' },
    { path: '/activity-logs', icon: '📜', label: 'Activity Logs' },
    { path: '/reports', icon: '📈', label: 'Analytics' },
    { path: '/claims', icon: '🎫', label: 'Claims' }, // Added for Super Admin
    { path: '/policies', icon: '📋', label: 'Policies' }, // Added for Super Admin
    { path: '/users', icon: '👥', label: 'Users' }, // Super Admin can still manage all users
    // Future: Policy Tiers management
    { path: '/policy-tiers', icon: '⭐', label: 'Policy Tiers' },
  ];

  // Get menu based on role
  const getMenuItems = () => {
    if (userRole === 'super_admin') {
      return superAdminMenuItems;
    }
    // Store Admin: Full store operations menu
    return storeAdminMenuItems;
  };

  const menuItems = getMenuItems();

  const isActive = (path, exact = false) => {
    if (exact) {
      return location.pathname === path;
    }
    return location.pathname.startsWith(path);
  };

  // Get display name
  const displayName = userInfo?.first_name || userInfo?.email?.split('@')[0] || 'Admin';
  const displayEmail = userInfo?.email || 'admin@smile.com';
  const roleLabel = userRole === 'super_admin' ? 'Super Admin' :
    userRole === 'store_admin' ? 'Store Admin' :
      userRole === 'store_staff' ? 'Store Staff' : 'Admin';

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <aside className={`bg-gradient-to-b from-orange-500 to-orange-600 text-white transition-all duration-300 ${sidebarOpen ? 'w-64' : 'w-20'}`}>
        {/* Logo */}
        <div className="p-4 border-b border-white/20">
          <div className="flex items-center justify-between">
            {sidebarOpen && (
              <div className="flex items-center gap-2">
                <span className="text-2xl">😊</span>
                <div>
                  <h1 className="text-xl font-bold">Smile by SPC</h1>
                  {userInfo?.store?.registration_code && userRole !== 'super_admin' && (
                    <p className="text-xs text-white/90 font-mono bg-white/20 px-2 py-0.5 rounded mt-1 inline-block">
                      {userInfo.store.registration_code}
                    </p>
                  )}
                </div>
              </div>
            )}
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="p-2 rounded-lg hover:bg-white/10 transition"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
          </div>
        </div>

        {/* Role Badge */}
        {sidebarOpen && (
          <div className="px-4 py-2">
            <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${userRole === 'super_admin'
              ? 'bg-purple-100 text-purple-800'
              : 'bg-blue-100 text-blue-800'
              }`}>
              {userRole === 'super_admin' ? '👑' : '🏪'} {roleLabel}
            </span>
          </div>
        )}

        {/* Menu */}
        <nav className="p-4 space-y-2">
          {menuItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={`flex items-center gap-3 px-4 py-3 rounded-lg transition ${isActive(item.path, item.exact)
                ? 'bg-white/20 text-white shadow-lg'
                : 'text-white/80 hover:bg-white/10 hover:text-white'
                }`}
            >
              <span className="text-2xl">{item.icon}</span>
              {sidebarOpen && (
                <span className="font-medium">
                  {item.label}
                  {item.superAdminOnly && (
                    <span className="ml-1 text-xs opacity-70">★</span>
                  )}
                </span>
              )}
            </Link>
          ))}
        </nav>

        {/* User Profile */}
        <div className={`absolute bottom-0 p-4 border-t border-white/20 ${sidebarOpen ? 'w-64' : 'w-20'}`}>
          {sidebarOpen ? (
            // Full sidebar mode
            <>
              <div className="flex items-center gap-3 mb-3">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 border-white/30 ${userRole === 'super_admin' ? 'bg-purple-500' : 'bg-white/20'
                  }`}>
                  <span className="text-lg font-bold">
                    {userRole === 'super_admin' ? '👑' : displayName.charAt(0).toUpperCase()}
                  </span>
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium">{displayName}</p>
                  <p className="text-xs text-white/70 truncate">{displayEmail}</p>
                </div>
              </div>
              <button
                onClick={handleLogout}
                className="w-full bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition flex items-center justify-center gap-2"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
                Logout
              </button>
            </>
          ) : (
            // Collapsed sidebar mode
            <div className="flex flex-col items-center gap-3">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 border-white/30 ${userRole === 'super_admin' ? 'bg-purple-500' : 'bg-white/20'
                }`}>
                <span className="text-lg font-bold">
                  {userRole === 'super_admin' ? '👑' : displayName.charAt(0).toUpperCase()}
                </span>
              </div>
              <button
                onClick={handleLogout}
                className="w-10 h-10 bg-red-600 hover:bg-red-700 text-white rounded-lg flex items-center justify-center transition"
                title="Logout"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
              </button>
            </div>
          )}
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1 overflow-auto">
        {/* Top Navbar */}
        <header className="bg-white shadow-sm">
          <div className="flex items-center justify-between px-6 py-4">
            <div>
              <h2 className="text-2xl font-bold text-gray-800">
                {menuItems.find(item => isActive(item.path, item.exact))?.label || 'Dashboard'}
              </h2>
              <p className="text-sm text-gray-500">Manage your insurance platform</p>
            </div>
            <div className="flex items-center gap-4">
              {/* Store Badge for Store Admin */}
              {userRole !== 'super_admin' && userInfo?.store && (
                <span className="px-3 py-1 bg-orange-100 text-orange-800 rounded-full text-sm font-medium">
                  🏪 {userInfo.store.name || 'My Store'}
                </span>
              )}
              {userRole !== 'super_admin' && <NotificationBell />}
            </div>
          </div>
        </header>

        {/* Page Content */}
        <main className="p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default DashboardLayout;

