import logging
import time
from django.http import JsonResponse
from django.core.cache import cache

logger = logging.getLogger(__name__)

class RequestLoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start_time = time.time()
        response = self.get_response(request)
        duration = time.time() - start_time
        
        logger.info(
            f"Method: {request.method} Path: {request.path} "
            f"Status: {response.status_code} Duration: {duration:.2f}s"
        )
        return response

class GlobalErrorHandlingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        try:
            response = self.get_response(request)
            return response
        except Exception as e:
            import traceback
            tb = traceback.format_exc()
            print(f"DEBUG ERROR: {tb}")
            logger.exception("Global error caught")
            return JsonResponse({
                'error': 'An internal server error occurred.',
                'detail': str(e),
                'traceback': tb if True else None # Always show in this debug phase
            }, status=500)

class SimpleRateLimitMiddleware:
    """Example middleware for rate limiting at the application level."""
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        ip = request.META.get('REMOTE_ADDR')
        key = f"ratelimit_{ip}"
        
        try:
            count = cache.get(key, 0)
            if count >= 500: # Limit to 500 requests per 10 minutes
                 return JsonResponse({'error': 'Too many requests. Please try again later.'}, status=429)
            cache.set(key, count + 1, 600) # 10 minutes
        except Exception:
            # If cache is down, don't block requests
            pass
            
        return self.get_response(request)

class AuthenticationCheckMiddleware:
    """Explicit middleware for logging authentication status."""
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Note: request.user is only populated after django.contrib.auth.middleware.AuthenticationMiddleware
        # and doesn't include DRF JWT auth user at the middleware level usually.
        # But we log whatever is available.
        response = self.get_response(request)
        if hasattr(request, 'user') and request.user.is_authenticated:
            logger.info(f"Authenticated request by: {request.user.email}")
        return response
