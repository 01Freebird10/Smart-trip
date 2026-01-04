from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TripViewSet, ItineraryItemViewSet, PollViewSet, ExpenseViewSet, BookingViewSet

router = DefaultRouter()
router.register(r'trips', TripViewSet, basename='trip')
router.register(r'itinerary', ItineraryItemViewSet, basename='itinerary')
router.register(r'polls', PollViewSet, basename='poll')
router.register(r'expenses', ExpenseViewSet, basename='expense')
router.register(r'bookings', BookingViewSet, basename='booking')

urlpatterns = [
    path('', include(router.urls)),
]
