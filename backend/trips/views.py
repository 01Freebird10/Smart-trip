from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q
from .models import Trip, Collaborator, ItineraryItem, Poll, PollOption, Vote, Expense, Booking
from .serializers import TripSerializer, CollaboratorSerializer, ItineraryItemSerializer, PollSerializer, PollOptionSerializer, ExpenseSerializer, BookingSerializer

class TripViewSet(viewsets.ModelViewSet):
    serializer_class = TripSerializer
    
    def get_queryset(self):
        user = self.request.user
        if not user.is_authenticated:
            return Trip.objects.none()
        try:
            return Trip.objects.filter(Q(owner=user) | Q(collaborators__user=user)).distinct().order_by('-created_at')
        except Exception as e:
            print(f"ERROR in TripViewSet.get_queryset: {e}")
            return Trip.objects.none()

    def perform_create(self, serializer):
        trip = serializer.save(owner=self.request.user)
        
        # Notify site owner/admin about the new plan (as requested)
        from django.core.mail import send_mail
        from django.conf import settings
        
        admin_email = "info@remoteward.com"
        subject = f"New Trip Planned: {trip.title}"
        message = (
            f"User {self.request.user.email} has just planned a new trip!\n\n"
            f"Destination: {trip.destination}\n"
            f"Title: {trip.title}\n"
            f"Dates: {trip.start_date} to {trip.end_date}\n"
            f"Budget: ${trip.budget}\n"
        )
        
        try:
            send_mail(
                subject,
                message,
                settings.DEFAULT_FROM_EMAIL,
                [admin_email],
                fail_silently=True,
            )
        except Exception as e:
            print(f"FAILED TO NOTIFY ADMIN: {e}")

    @action(detail=True, methods=['post'])
    def invite(self, request, pk=None):
        trip = self.get_object()
        email = request.data.get('email')
        role = request.data.get('role', 'viewer')
        
        if not email:
            return Response({'error': 'Email is required'}, status=status.HTTP_400_BAD_REQUEST)

        # In a real app, send actual email here
        from django.core.mail import send_mail
        from django.conf import settings
        from users.models import User
        
        # Create user if doesn't exist (mocking the "invite to join" flow)
        user, created = User.objects.get_or_create(email=email)
        Collaborator.objects.get_or_create(trip=trip, user=user, role=role)
        
        # Send Email
        subject = f"You've been invited to plan a trip: {trip.title}"
        message = (
            f"Hello!\n\n"
            f"{request.user.first_name or request.user.email} invited you to join the trip "
            f"'{trip.title}' to {trip.destination}.\n\n"
            f"Dates: {trip.start_date} to {trip.end_date}\n\n"
            f"Log in to Smart Planner to start collaborating!\n\n"
            f"Happy Travels,\nThe Smart Planner Team"
        )
        
        try:
            send_mail(
                subject,
                message,
                settings.DEFAULT_FROM_EMAIL,
                [email],
                fail_silently=False,
            )
        except Exception as e:
            print(f"FAILED TO SEND EMAIL: {e}")
            # Still return success because collaborator was created, but log error
        
        return Response({'status': 'invited', 'email': email})

    @action(detail=True, methods=['post'])
    def remove_collaborator(self, request, pk=None):
        trip = self.get_object()
        user_id = request.data.get('user_id')
        
        if not user_id:
            return Response({'error': 'User ID is required'}, status=status.HTTP_400_BAD_REQUEST)
            
        # Only owner can remove collaborators
        if trip.owner != request.user:
            return Response({'error': 'Only trip owner can remove collaborators'}, status=status.HTTP_403_FORBIDDEN)
            
        try:
            collaborator = Collaborator.objects.get(trip=trip, user_id=user_id)
            collaborator.delete()
            return Response({'status': 'removed'})
        except Collaborator.DoesNotExist:
            return Response({'error': 'Collaborator not found'}, status=status.HTTP_404_NOT_FOUND)

class ItineraryItemViewSet(viewsets.ModelViewSet):
    serializer_class = ItineraryItemSerializer

    def get_queryset(self):
        trip_id = self.request.query_params.get('trip_id')
        if not trip_id:
            return ItineraryItem.objects.none()
        return ItineraryItem.objects.filter(trip_id=trip_id)

    @action(detail=False, methods=['post'])
    def reorder(self, request):
        items = request.data.get('items', [])
        for index, item_id in enumerate(items):
            ItineraryItem.objects.filter(id=item_id).update(order=index)
        return Response({'status': 'reordered'})

class PollViewSet(viewsets.ModelViewSet):
    serializer_class = PollSerializer

    def get_queryset(self):
        trip_id = self.request.query_params.get('trip_id')
        if not trip_id:
            return Poll.objects.none()
        return Poll.objects.filter(trip_id=trip_id)

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

    @action(detail=True, methods=['post'])
    def vote(self, request, pk=None):
        option_id = request.data.get('option_id')
        option = PollOption.objects.get(id=option_id, poll_id=pk)
        
        # Remove existing votes for this poll by this user
        Vote.objects.filter(option__poll_id=pk, user=request.user).delete()
        Vote.objects.create(option=option, user=request.user)
        
        return Response({'status': 'voted'})

class ExpenseViewSet(viewsets.ModelViewSet):
    serializer_class = ExpenseSerializer

    def get_queryset(self):
        trip_id = self.request.query_params.get('trip_id')
        if not trip_id:
            return Expense.objects.none()
        return Expense.objects.filter(trip_id=trip_id).order_by('-timestamp')

class BookingViewSet(viewsets.ModelViewSet):
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        trip_id = self.request.query_params.get('trip_id')
        if trip_id:
            return Booking.objects.filter(trip_id=trip_id)
        return Booking.objects.filter(Q(trip__owner=self.request.user) | Q(user=self.request.user))

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def accept(self, request, pk=None):
        booking = self.get_object()
        # Only owner can accept
        if booking.trip.owner != request.user:
            return Response({'error': 'Only trip owner can accept bookings'}, status=status.HTTP_403_FORBIDDEN)
        
        booking.status = 'accepted'
        booking.save()
        return Response({'status': 'accepted'})
