from django.db import models
from django.conf import settings

class Trip(models.Model):
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    destination = models.CharField(max_length=255)
    start_date = models.DateField()
    end_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='owned_trips')
    image = models.ImageField(upload_to='trips/', null=True, blank=True)
    budget = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)

    def __str__(self):
        return self.title

class Expense(models.Model):
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='expenses')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    name = models.CharField(max_length=255)
    category = models.CharField(max_length=100)
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name}: {self.amount}"

class Collaborator(models.Model):
    ROLE_CHOICES = (
        ('editor', 'Editor'),
        ('viewer', 'Viewer'),
    )
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='collaborators')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='collaborations')
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='viewer')
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('trip', 'user')

class ItineraryItem(models.Model):
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='itinerary_items')
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    location = models.CharField(max_length=255, blank=True)
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    order = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['order', 'start_time']

class Poll(models.Model):
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='polls')
    question = models.CharField(max_length=255)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

class PollOption(models.Model):
    poll = models.ForeignKey(Poll, on_delete=models.CASCADE, related_name='options')
    text = models.CharField(max_length=255)

class Vote(models.Model):
    option = models.ForeignKey(PollOption, on_delete=models.CASCADE, related_name='votes')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('option', 'user')

class DestinationPlace(models.Model):
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='bucket_list')
    name = models.CharField(max_length=255)
    is_visited = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('trip', 'name')
class Booking(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='bookings')
    destination = models.CharField(max_length=255)
    adults = models.IntegerField(default=1)
    children = models.IntegerField(default=0)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    status = models.CharField(max_length=20, default='pending') # pending, accepted
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.email} booking for {self.destination} (${self.total_amount})"
