# admin_api/performance.py
"""
Performance utilities for handling millions of records
"""

from django.core.cache import cache
from functools import wraps
import hashlib


def cache_dashboard_stats(timeout=60):
    """
    Cache decorator for dashboard statistics.
    Cache key includes user ID and store ID for proper isolation.
    
    Args:
        timeout: Cache timeout in seconds (default 60s)
    """
    def decorator(func):
        @wraps(func)
        def wrapper(self, request, *args, **kwargs):
            user = request.user
            store_id = str(user.store_id) if user.store else 'all'
            
            # Create unique cache key based on user role and store
            cache_key = f"dashboard_stats_{user.role}_{store_id}"
            
            # Try to get from cache
            cached_data = cache.get(cache_key)
            if cached_data is not None:
                return cached_data
            
            # Execute function and cache result
            result = func(self, request, *args, **kwargs)
            cache.set(cache_key, result, timeout)
            return result
        return wrapper
    return decorator


def invalidate_dashboard_cache(store_id=None):
    """
    Invalidate dashboard cache when data changes.
    Call this after creating/updating policies, claims, etc.
    
    Args:
        store_id: Specific store ID to invalidate, or None for all
    """
    if store_id:
        # Invalidate specific store cache
        cache.delete(f"dashboard_stats_store_admin_{store_id}")
        cache.delete(f"dashboard_stats_store_staff_{store_id}")
    
    # Always invalidate super admin cache
    cache.delete("dashboard_stats_super_admin_all")


def get_optimized_queryset(model, select_fields=None, prefetch_fields=None, **filters):
    """
    Create an optimized queryset with select_related and prefetch_related.
    
    Args:
        model: Django model class
        select_fields: List of fields for select_related (ForeignKey, OneToOne)
        prefetch_fields: List of fields for prefetch_related (Many, reverse FK)
        **filters: Additional filters to apply
    
    Returns:
        Optimized QuerySet
    """
    qs = model.objects.filter(**filters)
    
    if select_fields:
        qs = qs.select_related(*select_fields)
    
    if prefetch_fields:
        qs = qs.prefetch_related(*prefetch_fields)
    
    return qs


class QueryCounter:
    """
    Context manager to count database queries (for debugging performance).
    
    Usage:
        with QueryCounter() as qc:
            # your code here
        print(f"Queries: {qc.count}")
    """
    def __init__(self):
        self.count = 0
        self.queries = []
    
    def __enter__(self):
        from django.db import connection
        self._initial_queries = len(connection.queries)
        return self
    
    def __exit__(self, *args):
        from django.db import connection
        self.count = len(connection.queries) - self._initial_queries
        self.queries = connection.queries[self._initial_queries:]


# Batch processing utilities
def batch_process(queryset, batch_size=1000, callback=None):
    """
    Process large querysets in batches to avoid memory issues.
    
    Args:
        queryset: Django QuerySet to process
        batch_size: Number of records per batch
        callback: Function to call for each batch
    
    Yields:
        Batches of records
    """
    total = queryset.count()
    for offset in range(0, total, batch_size):
        batch = queryset[offset:offset + batch_size]
        if callback:
            callback(batch)
        yield batch


def bulk_update_optimized(model, objects, fields, batch_size=500):
    """
    Optimized bulk update for large datasets.
    
    Args:
        model: Django model class
        objects: List of model instances to update
        fields: List of field names to update
        batch_size: Number of records per batch
    """
    for i in range(0, len(objects), batch_size):
        batch = objects[i:i + batch_size]
        model.objects.bulk_update(batch, fields, batch_size=batch_size)
