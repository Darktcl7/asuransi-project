// utils/hooks.js
/**
 * Custom hooks untuk optimasi performance
 * Handle jutaan data dengan debouncing, memoization, etc
 */

import { useState, useEffect, useMemo, useCallback } from 'react';
import { debounce } from 'lodash';

/**
 * useDebounce - Debounce value untuk prevent excessive API calls
 * Usage: const debouncedSearch = useDebounce(searchValue, 500);
 */
export function useDebounce(value, delay = 500) {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}

/**
 * useDebouncedCallback - Debounce callback function
 * Usage: const debouncedFn = useDebouncedCallback(myFunction, 500);
 */
export function useDebouncedCallback(callback, delay = 500) {
  return useCallback(
    debounce(callback, delay),
    [callback, delay]
  );
}

/**
 * usePagination - Handle pagination state
 * Usage: const { page, setPage, resetPage } = usePagination();
 */
export function usePagination(initialPage = 1) {
  const [page, setPage] = useState(initialPage);

  const nextPage = useCallback(() => {
    setPage(prev => prev + 1);
  }, []);

  const prevPage = useCallback(() => {
    setPage(prev => Math.max(1, prev - 1));
  }, []);

  const resetPage = useCallback(() => {
    setPage(initialPage);
  }, [initialPage]);

  return { page, setPage, nextPage, prevPage, resetPage };
}

/**
 * useFilter - Handle filter state dengan reset
 * Usage: const { filters, updateFilter, resetFilters } = useFilter(initialFilters);
 */
export function useFilter(initialFilters = {}) {
  const [filters, setFilters] = useState(initialFilters);

  const updateFilter = useCallback((key, value) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  }, []);

  const resetFilters = useCallback(() => {
    setFilters(initialFilters);
  }, [initialFilters]);

  return { filters, updateFilter, resetFilters, setFilters };
}
