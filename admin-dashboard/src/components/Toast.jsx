// components/Toast.jsx
// Custom toast notification component for admin dashboard

import { useState, useEffect, createContext, useContext, useCallback } from 'react';

// Toast Context
const ToastContext = createContext(null);

// Toast types
const TOAST_TYPES = {
    success: {
        bg: 'bg-green-500',
        icon: '✅',
    },
    error: {
        bg: 'bg-red-500',
        icon: '❌',
    },
    warning: {
        bg: 'bg-orange-500',
        icon: '⚠️',
    },
    info: {
        bg: 'bg-blue-500',
        icon: 'ℹ️',
    },
};

// Single Toast Component
const ToastItem = ({ id, message, type, onClose }) => {
    const config = TOAST_TYPES[type] || TOAST_TYPES.info;

    useEffect(() => {
        const timer = setTimeout(() => {
            onClose(id);
        }, 4000);
        return () => clearTimeout(timer);
    }, [id, onClose]);

    return (
        <div
            className={`${config.bg} text-white px-4 py-3 rounded-lg shadow-lg flex items-center gap-3 min-w-[300px] max-w-md animate-slide-in`}
            style={{
                animation: 'slideIn 0.3s ease-out',
            }}
        >
            <span className="text-xl">{config.icon}</span>
            <p className="flex-1 text-sm font-medium">{message}</p>
            <button
                onClick={() => onClose(id)}
                className="text-white/80 hover:text-white transition"
            >
                ✕
            </button>
        </div>
    );
};

// Toast Container Component
const ToastContainer = ({ toasts, removeToast }) => {
    return (
        <div className="fixed top-4 right-4 z-[100] flex flex-col gap-2">
            {toasts.map((toast) => (
                <ToastItem
                    key={toast.id}
                    id={toast.id}
                    message={toast.message}
                    type={toast.type}
                    onClose={removeToast}
                />
            ))}
        </div>
    );
};

// Toast Provider
export const ToastProvider = ({ children }) => {
    const [toasts, setToasts] = useState([]);

    const addToast = useCallback((message, type = 'info') => {
        const id = Date.now() + Math.random();
        setToasts((prev) => [...prev, { id, message, type }]);
    }, []);

    const removeToast = useCallback((id) => {
        setToasts((prev) => prev.filter((t) => t.id !== id));
    }, []);

    const toast = {
        success: (message) => addToast(message, 'success'),
        error: (message) => addToast(message, 'error'),
        warning: (message) => addToast(message, 'warning'),
        info: (message) => addToast(message, 'info'),
    };

    return (
        <ToastContext.Provider value={toast}>
            {children}
            <ToastContainer toasts={toasts} removeToast={removeToast} />
            <style>{`
        @keyframes slideIn {
          from {
            transform: translateX(100%);
            opacity: 0;
          }
          to {
            transform: translateX(0);
            opacity: 1;
          }
        }
      `}</style>
        </ToastContext.Provider>
    );
};

// Hook to use toast
export const useToast = () => {
    const context = useContext(ToastContext);
    if (!context) {
        throw new Error('useToast must be used within a ToastProvider');
    }
    return context;
};

export default ToastProvider;
