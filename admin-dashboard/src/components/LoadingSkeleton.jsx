// components/LoadingSkeleton.jsx
/**
 * Loading skeleton components untuk better UX
 * Tampilkan placeholder saat data loading
 */

export const TableSkeleton = ({ rows = 5, columns = 5 }) => {
  return (
    <div className="animate-pulse">
      {/* Table Header */}
      <div className="bg-gray-50 p-4 flex gap-4">
        {[...Array(columns)].map((_, i) => (
          <div key={i} className="h-4 bg-gray-200 rounded flex-1"></div>
        ))}
      </div>
      
      {/* Table Rows */}
      {[...Array(rows)].map((_, rowIndex) => (
        <div key={rowIndex} className="p-4 border-b border-gray-200 flex gap-4">
          {[...Array(columns)].map((_, colIndex) => (
            <div key={colIndex} className="h-4 bg-gray-200 rounded flex-1"></div>
          ))}
        </div>
      ))}
    </div>
  );
};

export const CardSkeleton = () => {
  return (
    <div className="bg-white rounded-xl shadow-lg p-6 animate-pulse">
      <div className="h-6 bg-gray-200 rounded w-1/3 mb-4"></div>
      <div className="h-10 bg-gray-200 rounded w-2/3 mb-2"></div>
      <div className="h-4 bg-gray-200 rounded w-1/2"></div>
    </div>
  );
};

export const StatCardSkeleton = () => {
  return (
    <div className="bg-gradient-to-br from-gray-400 to-gray-500 rounded-xl shadow-lg p-6 animate-pulse">
      <div className="flex items-center justify-between">
        <div className="flex-1">
          <div className="h-4 bg-white/30 rounded w-1/2 mb-3"></div>
          <div className="h-8 bg-white/30 rounded w-2/3 mb-2"></div>
          <div className="h-3 bg-white/30 rounded w-1/3"></div>
        </div>
        <div className="w-12 h-12 bg-white/30 rounded-full"></div>
      </div>
    </div>
  );
};

export const ChartSkeleton = () => {
  return (
    <div className="bg-white rounded-xl shadow-lg p-6 animate-pulse">
      <div className="h-6 bg-gray-200 rounded w-1/3 mb-4"></div>
      <div className="h-64 bg-gray-200 rounded"></div>
    </div>
  );
};
