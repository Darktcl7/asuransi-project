// pages/ReportsPage.jsx
import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { adminService } from '../services/adminService';

const ReportsPage = () => {
    const [dateRange, setDateRange] = useState({
        startDate: '',
        endDate: ''
    });

    const { data: reports, isLoading, refetch } = useQuery({
        queryKey: ['reports', dateRange],
        queryFn: () => adminService.getReports({
            start_date: dateRange.startDate,
            end_date: dateRange.endDate
        }),
    });

    const handleExport = async () => {
        try {
            const blob = await adminService.exportReports({
                start_date: dateRange.startDate,
                end_date: dateRange.endDate
            });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            // Native JS date formatting YYYYMMDD
            const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
            a.download = `store_report_${dateStr}.xlsx`;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
        } catch (error) {
            console.error('Export failed:', error);
            alert('Gagal export laporan');
        }
    };

    const formatCurrency = (val) => new Intl.NumberFormat('id-ID', {
        style: 'currency', currency: 'IDR', minimumFractionDigits: 0
    }).format(val || 0);

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center bg-white p-4 rounded-xl shadow-sm border border-gray-100">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Laporan & Analitik</h1>
                    <p className="text-gray-500">Monitoring performa toko dan finansial</p>
                </div>
                <div className="flex gap-3">
                    <input
                        type="date"
                        className="px-3 py-2 border rounded-lg"
                        value={dateRange.startDate}
                        onChange={(e) => setDateRange({ ...dateRange, startDate: e.target.value })}
                    />
                    <span className="self-center text-gray-400">to</span>
                    <input
                        type="date"
                        className="px-3 py-2 border rounded-lg"
                        value={dateRange.endDate}
                        onChange={(e) => setDateRange({ ...dateRange, endDate: e.target.value })}
                    />
                    <button
                        onClick={() => refetch()}
                        className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition"
                    >
                        Filter
                    </button>
                    <button
                        onClick={handleExport}
                        className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition flex items-center gap-2"
                    >
                        📤 Export Excel
                    </button>
                </div>
            </div>

            {/* Main Table */}
            <div className="bg-white rounded-xl shadow-lg border border-gray-100 overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead className="bg-gray-50 text-gray-600 font-medium border-b">
                            <tr>
                                <th className="p-4">Toko</th>
                                <th className="p-4">Lokasi</th>
                                <th className="p-4 text-right">Polis Terjual</th>
                                <th className="p-4 text-right">Premi Masuk</th>
                                <th className="p-4 text-right">Total Klaim</th>
                                <th className="p-4 text-right">Klaim Dibayar</th>
                                <th className="p-4 text-center">Loss Ratio</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {isLoading ? (
                                <tr><td colSpan="7" className="p-8 text-center">Memuat data...</td></tr>
                            ) : reports?.map((store) => (
                                <tr key={store.id} className="hover:bg-gray-50 transition">
                                    <td className="p-4">
                                        <div className="font-medium text-gray-800">{store.name}</div>
                                        <div className="text-xs text-gray-500">{store.code}</div>
                                    </td>
                                    <td className="p-4 text-gray-600">{store.location || '-'}</td>
                                    <td className="p-4 text-right font-medium">{store.sales?.count}</td>
                                    <td className="p-4 text-right font-medium text-green-600">
                                        {formatCurrency(store.sales?.revenue)}
                                    </td>
                                    <td className="p-4 text-right">{store.claims?.count}</td>
                                    <td className="p-4 text-right font-medium text-red-600">
                                        {formatCurrency(store.claims?.amount)}
                                    </td>
                                    <td className="p-4 text-center">
                                        <span className={`px-2 py-1 rounded-full text-xs font-bold ${store.loss_ratio > 70 ? 'bg-red-100 text-red-700' :
                                            store.loss_ratio > 40 ? 'bg-yellow-100 text-yellow-700' :
                                                'bg-green-100 text-green-700'
                                            }`}>
                                            {store.loss_ratio}%
                                        </span>
                                    </td>
                                </tr>
                            ))}
                            {reports?.length === 0 && (
                                <tr><td colSpan="7" className="p-8 text-center text-gray-500">Tidak ada data untuk periode ini.</td></tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
};

export default ReportsPage;
